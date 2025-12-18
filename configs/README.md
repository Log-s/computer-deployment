# Configuration Files

This directory contains configuration templates that will be deployed to your home directory during installation.

## Structure

Each configuration should be placed in its own subdirectory:
- `tmux/` - tmux configuration files
- `zsh/` - zsh configuration files (if needed)
- `vim/` - vim configuration files (if needed)
- etc.

## Adding New Configurations

To add a new configuration:

1. Create a subdirectory for your config (e.g., `vim/`)
2. Place your config file(s) in that directory
3. Update the role's `defaults/main.yml` to include the config in the appropriate list:

```yaml
base_configs:
  - name: myconfig
    src: "{{ configs_dir }}/vim/vimrc"
    dest: "{{ user_home }}/.vimrc"
```

The configs will be automatically deployed when the role runs.

