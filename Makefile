.PHONY: install update backup clean help

DOTFILES_DIR := $(shell pwd)
BACKUP_DIR := $(HOME)/.dotfiles_backup
UNAME := $(shell uname)

# OS-specific file lists
COMMON_FILES := .tmux.conf .zprofile
MACOS_FILES := .aerospace.toml
LINUX_FILES := 

# Determine which files to install based on OS
ifeq ($(UNAME), Darwin)
	INSTALL_FILES := $(COMMON_FILES) $(MACOS_FILES)
else
	INSTALL_FILES := $(COMMON_FILES) $(LINUX_FILES)
endif

help:
	@echo "Dotfiles Management"
	@echo "==================="
	@echo "make install  - Install dotfiles (creates symlinks)"
	@echo "make update   - Pull latest changes and reinstall"
	@echo "make backup   - Backup existing dotfiles"
	@echo "make clean    - Remove symlinks and restore backups"
	@echo "make help     - Show this help message"

backup:
	@echo "Creating backup directory..."
	@mkdir -p $(BACKUP_DIR)
	@echo "Backing up existing dotfiles for $(UNAME)..."
	@[ -f $(HOME)/.tmux.conf ] && cp $(HOME)/.tmux.conf $(BACKUP_DIR)/ || true
	@[ -f $(HOME)/.zprofile ] && cp $(HOME)/.zprofile $(BACKUP_DIR)/ || true
ifeq ($(UNAME), Darwin)
	@[ -f $(HOME)/.aerospace.toml ] && cp $(HOME)/.aerospace.toml $(BACKUP_DIR)/ || true
endif
	@[ -d $(HOME)/.config/nvim ] && [ ! -L $(HOME)/.config/nvim ] && cp -r $(HOME)/.config/nvim $(BACKUP_DIR)/ || true
	@echo "Backup complete: $(BACKUP_DIR)"

install: backup
	@echo "Installing dotfiles for $(UNAME)..."
	@mkdir -p $(HOME)/.config
	@ln -sf $(DOTFILES_DIR)/.tmux.conf $(HOME)/.tmux.conf
	@ln -sf $(DOTFILES_DIR)/.zprofile $(HOME)/.zprofile
ifeq ($(UNAME), Darwin)
	@ln -sf $(DOTFILES_DIR)/.aerospace.toml $(HOME)/.aerospace.toml
endif
	@rm -rf $(HOME)/.config/nvim
	@ln -sf $(DOTFILES_DIR)/nvim $(HOME)/.config/nvim
	@echo "Dotfiles installed successfully!"

update:
	@echo "Updating dotfiles..."
	@git pull origin main
	@make install
	@echo "Update complete!"

clean:
	@echo "Removing symlinks..."
	@rm -f $(HOME)/.tmux.conf $(HOME)/.zprofile
ifeq ($(UNAME), Darwin)
	@rm -f $(HOME)/.aerospace.toml
endif
	@rm -rf $(HOME)/.config/nvim
	@echo "Restoring backups..."
	@[ -f $(BACKUP_DIR)/.tmux.conf ] && cp $(BACKUP_DIR)/.tmux.conf $(HOME)/ || true
	@[ -f $(BACKUP_DIR)/.zprofile ] && cp $(BACKUP_DIR)/.zprofile $(HOME)/ || true
ifeq ($(UNAME), Darwin)
	@[ -f $(BACKUP_DIR)/.aerospace.toml ] && cp $(BACKUP_DIR)/.aerospace.toml $(HOME)/ || true
endif
	@[ -d $(BACKUP_DIR)/nvim ] && cp -r $(BACKUP_DIR)/nvim $(HOME)/.config/ || true
	@echo "Cleanup complete!"