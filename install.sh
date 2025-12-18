#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="${SCRIPT_DIR}/ansible"

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1" >&2
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Ensure a local user exists; if not, create it with password=username
ensure_user_exists() {
    local target_user="$1"

    if id "$target_user" &>/dev/null; then
        return 0
    fi

    print_warn "User '$target_user' does not exist; creating it (password=username)"

    # Need root privileges to create users / set passwords
    local SUDO=""
    if [ "$EUID" -ne 0 ]; then
        if command -v sudo &>/dev/null; then
            SUDO="sudo"
        else
            print_error "Cannot create user without root privileges or sudo installed"
            exit 1
        fi
    fi

    # Ensure user-management tools exist (minimal images may not include them)
    # user management commands often live in /usr/sbin (not always on PATH)
    local USERADD_BIN="/usr/sbin/useradd"
    local ADDUSER_BIN="/usr/sbin/adduser"
    local CHPASSWD_BIN="/usr/sbin/chpasswd"

    if [ ! -x "$USERADD_BIN" ] && [ ! -x "$ADDUSER_BIN" ]; then
        print_warn "useradd/adduser not found; installing required packages (adduser, passwd)"
        $SUDO apt-get update -y
        $SUDO apt-get install -y adduser passwd
    fi

    if [ ! -x "$CHPASSWD_BIN" ]; then
        print_warn "chpasswd not found; installing required package (passwd)"
        $SUDO apt-get update -y
        $SUDO apt-get install -y passwd
    fi

    # Create user with home directory
    if [ -x "$USERADD_BIN" ]; then
        $SUDO "$USERADD_BIN" -m -s /bin/bash "$target_user"
    elif [ -x "$ADDUSER_BIN" ]; then
        # Debian-friendly helper
        $SUDO "$ADDUSER_BIN" --disabled-password --gecos "" "$target_user"
    else
        print_error "User creation tools still not available (expected $USERADD_BIN or $ADDUSER_BIN)"
        exit 1
    fi

    # Set password to username
    if [ -x "$CHPASSWD_BIN" ]; then
        echo "${target_user}:${target_user}" | $SUDO "$CHPASSWD_BIN"
    else
        print_error "Password tool not available (expected $CHPASSWD_BIN)"
        exit 1
    fi

    # Verify user exists now
    if ! getent passwd "$target_user" >/dev/null; then
        print_error "User '$target_user' still not found after creation attempt"
        exit 1
    fi
}

# Function to show help message
show_help() {
    echo -e "${GREEN}Pentest Installer${NC} - Ansible-based installer for penetration testing tools"
    echo ""
    echo -e "${YELLOW}USAGE:${NC}"
    echo "    $0 [OPTIONS] USER"
    echo ""
    echo -e "${YELLOW}ARGUMENTS:${NC}"
    echo "    USER                    ${RED}(REQUIRED)${NC} Username to configure (will be added to sudo, docker, podman groups)"
    echo ""
    echo -e "${YELLOW}OPTIONS:${NC}"
    echo "    -h, --help              Show this help message and exit"
    echo "    -v                      Show Ansible task details"
    echo "    -vv                     Show task details and underlying commands (apt logs, etc.)"
    echo "    --profile PROFILE       Select installation profile (base, perso, or work)"
    echo "                            Default: base"
    echo ""
    echo -e "${YELLOW}PROFILES:${NC}"
    echo -e "    ${GREEN}base${NC}   Base installation profile with essential tools and configurations"
    echo ""
    echo -e "    ${GREEN}perso${NC}  Personal profile (extends base)"
    echo "            - Adds graphical environment (Regolith desktop) and personal applications"
    echo ""
    echo -e "    ${GREEN}work${NC}   Work profile (extends base)"
    echo "            - Adds remote application capabilities (xpra)"
    echo ""
    echo -e "${YELLOW}EXAMPLES:${NC}"
    echo "    $0 myuser                           # Install base profile for myuser"
    echo "    $0 --profile perso myuser            # Install perso profile for myuser"
    echo "    $0 --profile work myuser             # Install work profile for myuser"
    echo "    $0 -v --profile perso myuser         # Install with verbose output"
    echo "    $0 -vv --profile base myuser         # Install with very verbose output (shows apt logs, etc.)"
    echo "    $0 -h                                # Show this help message"
    echo ""
    echo -e "${YELLOW}PREREQUISITES:${NC}"
    echo "    - Debian 13 (Trixie) or compatible Debian-based distribution"
    echo "    - Ansible (will be checked before installation)"
    echo "    - Python 3 (will be checked before installation)"
    echo "    - sudo access (or run as root; sudo will be installed if missing)"
    echo ""
    echo -e "${YELLOW}NOTES:${NC}"
    echo "    - The installer is idempotent and can be run multiple times safely"
    echo "    - All installations require sudo/root privileges"
    echo "    - The specified user will be added to sudo, docker, and podman groups"
    echo "    - Configuration files will be deployed to the specified user's home directory"
    echo ""
    echo "For more information, see the README.md file."
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    local missing_deps=()
    
    # Check for ansible
    if ! command -v ansible-playbook &> /dev/null; then
        missing_deps+=("ansible")
    fi
    
    # Check for python3
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    # Check for sudo (unless running as root, in which case we'll install it)
    if ! command -v sudo &> /dev/null && [ "$EUID" -ne 0 ]; then
        missing_deps+=("sudo")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing prerequisites: ${missing_deps[*]}"
        print_info "Please install them first:"
        print_info "  sudo apt update && sudo apt install -y ${missing_deps[*]}"
        exit 1
    fi
    
    print_info "All prerequisites met"
}

# Function to parse command line arguments
parse_args() {
    local profile="base"  # Default to base
    local target_user=""
    local verbosity=""
    local positional_args=()
    
    # Parse options first
    while [[ $# -gt 0 ]]; do
        case $1 in
            --profile)
                profile="$2"
                shift 2
                ;;
            -v)
                verbosity="v"
                shift
                ;;
            -vv)
                verbosity="vv"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            --)
                shift
                positional_args+=("$@")
                break
                ;;
            -*)
                print_error "Unknown option: $1"
                echo "Use -h or --help for usage information"
                exit 1
                ;;
            *)
                # Collect positional arguments
                positional_args+=("$1")
                shift
                ;;
        esac
    done
    
    # Get user from positional arguments (should be the last one)
    if [ ${#positional_args[@]} -eq 0 ]; then
        print_error "Missing required argument: USER"
        echo ""
        echo "Usage: $0 [OPTIONS] USER"
        echo "Use -h or --help for more information"
        exit 1
    fi
    
    # User is the last positional argument
    target_user="${positional_args[-1]}"
    
    # Ensure user exists (create if missing)
    ensure_user_exists "$target_user"
    
    # Validate profile
    if [[ "$profile" != "base" && "$profile" != "perso" && "$profile" != "work" ]]; then
        print_error "Invalid profile: $profile"
        echo "Valid profiles are: base, perso, work"
        exit 1
    fi
    
    # Return user, profile, and verbosity (separated by |)
    echo "${target_user}|${profile}|${verbosity}"
}

# Function to validate profile
validate_profile() {
    local profile=$1
    local playbook="${ANSIBLE_DIR}/playbooks/${profile}.yml"
    
    if [ ! -f "$playbook" ]; then
        print_error "Profile '$profile' not found. Playbook does not exist: $playbook"
        exit 1
    fi
    
    echo "$playbook"
}

# Main execution
main() {
    # Check for help flag first (before any other operations)
    for arg in "$@"; do
        if [[ "$arg" == "-h" ]] || [[ "$arg" == "--help" ]]; then
            show_help
            exit 0
        fi
    done
    
    print_info "Starting pentest installer..."
    
    # Check prerequisites
    check_prerequisites
    
    # Parse arguments and get user, profile, and verbosity
    local result
    result=$(parse_args "$@")
    
    # Split result into user, profile, and verbosity
    local target_user="${result%%|*}"
    local remaining="${result#*|}"
    local profile="${remaining%%|*}"
    local verbosity="${remaining#*|}"
    
    # Validate profile
    local playbook
    playbook=$(validate_profile "$profile")
    
    print_info "Target user: $target_user"
    print_info "Installing profile: $profile"
    print_info "Running playbook: $playbook"
    
    if [ -n "$verbosity" ]; then
        print_info "Verbosity level: ${#verbosity} (${verbosity})"
    fi
    
    # Get user's home directory
    local user_home
    user_home="$(getent passwd "$target_user" | cut -d: -f6)"
    if [ -z "$user_home" ]; then
        print_error "Could not determine home directory for user '$target_user'"
        exit 1
    fi
    
    # Change to ansible directory and run playbook
    cd "$ANSIBLE_DIR"
    
    # Build ansible-playbook command
    local ansible_cmd="ansible-playbook -i localhost, -c local playbooks/${profile}.yml"
    ansible_cmd="${ansible_cmd} -e target_user=${target_user}"
    ansible_cmd="${ansible_cmd} -e target_user_home=${user_home}"
    
    # Add verbosity if specified
    if [ -n "$verbosity" ]; then
        ansible_cmd="${ansible_cmd} -${verbosity}"
    fi
    
    if eval "$ansible_cmd"; then
        print_info "Installation completed successfully!"
    else
        print_error "Installation failed. Please check the errors above."
        exit 1
    fi
}

# Run main function
main "$@"

