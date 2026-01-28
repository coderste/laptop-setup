#!/bin/bash

set -e

readonly NC='\033[0m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly RED='\033[0;31m'

log_info() {
    echo -e "${CYAN}$1${NC}"
}

log_success() {
    echo -e "${GREEN}$1${NC}"
}

log_warning() {
    echo -e "${YELLOW}$1${NC}"
}

log_error() {
    echo -e "${RED}$1${NC}"
}

main() {
    log_info "Backing up system configuration files to repo..."
    echo ""

    if [[ ! -f "setup.sh" ]]; then
        log_error "This script must be run from the root of the laptop-setup repository!"
        exit 1
    fi

    local config_dir="./config"
    local backed_up=0
    local skipped=0

    mkdir -p "$config_dir"

    local files=(".zprofile" ".zshrc" ".gitconfig" ".gitconfig-personal" ".gitignore" ".aliases")

    for file in "${files[@]}"; do
        if [[ -f "$HOME/$file" ]]; then
            log_info "Backing up $file..."
            cp "$HOME/$file" "$config_dir/"
            ((backed_up++))
        else
            log_warning "$file not found in home directory, skipping..."
            ((skipped++))
        fi
    done

    if [[ -d "$HOME/.git-hooks" ]]; then
        log_info "Backing up .git-hooks directory..."
        rm -rf .git-hooks
        cp -R "$HOME/.git-hooks" .
        ((backed_up++))
    else
        log_warning ".git-hooks directory not found, skipping..."
        ((skipped++))
    fi

    if [[ -f "$HOME/.aws/config" ]]; then
        log_info "Backing up AWS config..."
        cp "$HOME/.aws/config" "$config_dir/.aws"
        ((backed_up++))
    else
        log_warning "AWS config not found, skipping..."
        ((skipped++))
    fi

    echo ""
    log_success "Backup complete!"
    log_info "Files backed up: $backed_up"
    log_info "Files skipped: $skipped"
    echo ""
    log_warning "Don't forget to commit and push your changes!"
    log_info "Run: git add . && git commit -m 'backup: updated config files' && git push"
}

main "$@"
