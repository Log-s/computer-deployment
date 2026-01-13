# Computer setup

An Ansible + bash installer for setting up a pentesting environment on **Debian 13 (Trixie)**.

It supports **profiles**: a common **base**, plus optional **graphical** (desktop environment).

## Features

- **Profile-based installation**: base / graphical
- **Multiple installation methods**: apt, pipx, and git clones
- **Configuration management**: deploys dotfiles and app configs into the target user’s home
- **Idempotent**: Safe to run multiple times
- **Extensible**: Easy to add new tools and configurations

## Prerequisites

- Debian 13 (Trixie)
- Ansible
- Python 3

## Quick Start

1. Clone or download this repository
2. Run the installer (USER is required):

```bash
./install.sh <user>
```

**About the USER parameter**: This is the main user account on the computer. The user can already exist on the system. If the user doesn't exist, it will be automatically created with a password set to the username.

Optionally specify a profile (default is base) and verbosity. Some examples:

```bash
./install.sh --profile graphical <user>

./install.sh -v --profile graphical <user>
./install.sh -vv --profile base <user>
```

For full CLI help, run:

```bash
./install.sh -h
```

## Profiles

### Base Profile

The base profile installs a comprehensive set of tools and configurations for penetration testing and development. It includes:

**System & Development Tools:**
- Essential system utilities (git, curl, wget, zip, gpg, sudo)
- Programming languages: **Go**, **Python 3** (with pip, venv), **Ruby** (with gems), **Rust** (via rustup), **Node.js** (npm)
- Build tools: build-essential, composer
- Containerization: **Docker** and **Podman**

**Security & Penetration Testing Tools:**
- Network tools: **Wireshark**, **tcpdump**, **netcat-traditional**, **proxychains4**
- Security tools: **sqlmap**, **hashcat**
- APT repositories for: **VS Code**, **Bruno** (API client)
- pipx packages: **impacket**, **Responder**, **mitmproxy**, **updog**
- Source installations: **krbrelayx**, **impacket_pub**, **linux-wifi-hotspot**, **semgrep-rules**
- **WPScan** (Ruby gem for WordPress security scanning)

**Terminal & Editor:**
- **Kitty** terminal emulator (with configuration)
- **tmux** with TPM (plugin manager)
- **zsh** with **oh-my-zsh** (including plugins)
- **Neovim** (latest release) with dependencies

**User Setup:**
- Adds the target user to **sudo**, **docker**, and **podman** groups
- Sets up **zsh + oh-my-zsh** (including plugins) and ensures pipx apps are on PATH
- Generates an **ed25519 SSH keypair** for the user (no passphrase)
- Creates home directories: `Documents`, `Downloads`, `Tools`
- Deploys configuration files: **tmux**, **zsh**, **kitty**, **nvim**

**And more...**

### Graphical Profile

Extends the base profile with:
- A graphical environment (Regolith) with its configuration
- Desktop/user apps (e.g. Discord)

## Where things go

- **Git-cloned tools**: `~/Tools/<category>/<name>` (example: `~/Tools/ad/krbrelayx`)
- **Configs shipped by this repo**: `configs/` (copied into the user’s home)
- **tmux**: `~/.tmux.conf` and `~/.tmux/plugins/tpm`
- **zsh**: `~/.zshrc` (oh-my-zsh lives in `~/.oh-my-zsh`)

## Project Structure

```
computer-deployment/
├── install.sh                 # Main installer script
├── ansible/
│   ├── ansible.cfg           # Ansible configuration
│   ├── playbooks/            # Playbook files
│   │   ├── base.yml
│   │   └── graphical.yml
│   ├── roles/                # Ansible roles
│   │   ├── base/             # Base role
│   │   └── graphical/        # Graphical profile role
│   └── group_vars/
│       └── all.yml           # Common variables
└── configs/                  # Configuration templates
    ├── tmux/
    ├── zsh/
    ├── kitty/
    ├── nvim/
    ├── regolith3/
    └── README.md
```

## Adding New Tools

### Adding APT Packages

Edit the appropriate role's `defaults/main.yml`:

```yaml
# For base role
base_apt_packages:
  - git
  - your-new-package

# For graphical role
graphical_apt_packages:
  - your-graphical-package
```

### Adding pipx Packages

Edit the appropriate role's `defaults/main.yml`:

```yaml
base_pipx_packages:
  - black
  - your-new-tool
```

### Adding Source Installations

Edit the appropriate role's `defaults/main.yml`:

```yaml
base_source_installs:
  - repo: "https://github.com/user/tool.git"
    category: "category"
    name: "tool"
    build_commands:
      - "./configure"
      - "make"
      - "make install"
```

## Adding New Configurations

1. Create a subdirectory in `configs/` for your configuration (e.g., `configs/vim/`)
2. Place your configuration file(s) in that directory
3. Update the role's `defaults/main.yml`:

```yaml
base_configs:
  - name: vimrc
    src: "{{ configs_dir }}/vim/vimrc"
    dest: "{{ user_home }}/.vimrc"
```

See `configs/README.md` for more details.

## Creating a New Profile

1. Create a new role directory:
   ```bash
   mkdir -p ansible/roles/newprofile/{tasks,defaults}
   ```

2. Create `ansible/roles/newprofile/defaults/main.yml`:
   ```yaml
   ---
   newprofile_apt_packages: []
   newprofile_pipx_packages: []
   newprofile_source_installs: []
   newprofile_configs: []
   ```

3. Create `ansible/roles/newprofile/tasks/main.yml`:
   ```yaml
   ---
   - name: Include base role
     include_role:
       name: base
   
   - name: Install newprofile packages
     # Add your tasks here
   ```

4. Create a new playbook `ansible/playbooks/newprofile.yml`:
   ```yaml
   ---
   - name: New Profile Installation
     hosts: localhost
     connection: local
     gather_facts: yes
     
     roles:
       - newprofile
   ```

5. Update `install.sh` to accept the new profile (argument parsing + help output).
