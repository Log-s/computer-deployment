# Pentest Installer

An Ansible + bash installer for setting up a pentesting environment on **Debian 13 (Trixie)**.

It supports **profiles**: a common **base**, plus optional **perso** (desktop environment) and **work** (remote-app capabilities).

## Features

- **Profile-based installation**: base / perso / work
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

Optionally specify a profile (default is base) and verbosity. Some examples:

```bash
./install.sh --profile perso <user>
./install.sh --profile work <user>

./install.sh -v --profile perso <user>
./install.sh -vv --profile base <user>
```

For full CLI help, run:

```bash
./install.sh -h
```

## Profiles

### Base Profile

The base profile installs the core tools + configurations. It also:
- Adds the target user to **sudo**, **docker**, and **podman** groups
- Sets up **zsh + oh-my-zsh** (including plugins) and ensures pipx apps are on PATH
- Generates an **ed25519 SSH keypair** for the user (no passphrase)

### Personal Profile (perso)

Extends the base profile with:
- A graphical environment (Regolith) with its configuration
- Desktop/user apps (e.g. Discord, flameshot)

### Work Profile (work)

Extends the base profile with:
- xpra (remote application capabilities)
- Work-specific tools and configurations

## Where things go

- **Git-cloned tools**: `~/Tools/<category>/<name>` (example: `~/Tools/ad/krbrelayx`)
- **Configs shipped by this repo**: `configs/` (copied into the user’s home)
- **tmux**: `~/.tmux.conf` and `~/.tmux/plugins/tpm`
- **zsh**: `~/.zshrc` (oh-my-zsh lives in `~/.oh-my-zsh`)

## Project Structure

```
pentest-installer/
├── install.sh                 # Main installer script
├── ansible/
│   ├── ansible.cfg           # Ansible configuration
│   ├── playbooks/            # Playbook files
│   │   ├── base.yml
│   │   ├── perso.yml
│   │   └── work.yml
│   ├── roles/                # Ansible roles
│   │   ├── base/             # Base role
│   │   ├── perso/            # Personal profile role
│   │   └── work/             # Work profile role
│   └── group_vars/
│       └── all.yml           # Common variables
└── configs/                  # Configuration templates
    ├── tmux/
    ├── zsh/
    ├── terminator/
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

# For perso role
perso_apt_packages:
  - your-perso-package

# For work role
work_apt_packages:
  - your-work-package
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
