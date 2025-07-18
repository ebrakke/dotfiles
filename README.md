# Dotfiles

Personal dotfiles for easy configuration management across machines.

## What's Included

### Common (All OS)
- **tmux.conf** - Tmux configuration
- **zprofile** - Zsh profile settings
- **nvim/** - Neovim configuration

### macOS Only
- **aerospace.toml** - Aerospace window manager config

### Linux Only
- *(none currently)*

## Quick Setup

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
make install
```

## Commands

| Command | Description |
|---------|-------------|
| `make install` | Install dotfiles (creates symlinks, backs up existing) |
| `make update` | Pull latest changes and reinstall |
| `make backup` | Backup existing dotfiles to `~/.dotfiles_backup` |
| `make clean` | Remove symlinks and restore backups |
| `make help` | Show available commands |

## How It Works

- Detects your OS (macOS/Linux) and installs appropriate configs
- Creates symlinks from your home directory to files in this repo
- Automatically backs up existing dotfiles before installation
- Easy to update across machines with `make update`
- Safe to remove with `make clean`

## Usage on New Machine

1. Clone this repo
2. Run `make install`
3. Your dotfiles are now active!

## Adding New Dotfiles

### Common Files (All OS)
1. Copy the file to this directory
2. Add to `COMMON_FILES` in Makefile
3. Commit and push changes

### OS-Specific Files
1. Copy the file to this directory
2. Add to `MACOS_FILES` or `LINUX_FILES` in Makefile
3. Add OS-specific install/backup/clean logic if needed
4. Commit and push changes