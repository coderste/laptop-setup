# My macOS setup script
#!/bin/bash

# Exit on any error
set -e

# Color definitions
readonly NC='\033[0m'       # Text Reset
readonly RED='\033[0;31m'   # Red
readonly GREEN='\033[0;32m' # Green
readonly YELLOW='\033[0;33m' # Yellow
readonly BLUE='\033[0;34m'  # Blue
readonly PURPLE='\033[0;35m' # Purple
readonly CYAN='\033[0;36m'  # Cyan
readonly WHITE='\033[1;37m' # Bold White

# Helper functions
log_info() {
    echo -e "${WHITE}$1${NC}"
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

log_section() {
    echo -e "\n${PURPLE}$1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

app_exists() {
    [[ -d "/Applications/${1}.app" ]]
}

# Main functions
install_homebrew() {
    log_section "Setting up Homebrew"
    
    if command_exists brew; then
        log_info "Homebrew already installed. Updating..."
        brew update && brew upgrade
    else
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for both Intel and Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    log_success "Homebrew setup complete"
}

install_applications() {
    log_section "Installing macOS Applications"
    
    if [[ ! -f "apps.txt" ]]; then
        log_error "apps.txt file not found!"
        return 1
    fi
    
    while IFS='=' read -r app brew_name || [[ -n "$app" ]]; do
        # Skip empty lines and comments
        [[ -z "$app" || "$app" =~ ^#.*$ ]] && continue
        
        if app_exists "$app"; then
            log_info "${app} is already installed"
        else
            log_info "Installing ${app}..."
            if brew install --cask "$brew_name"; then
                log_success "${app} installed successfully"
            else
                log_error "Failed to install ${app}"
            fi
        fi
    done < apps.txt
}

install_developer_tools() {
    log_section "Installing Developer Tools"
    
    if [[ ! -f "tools.txt" ]]; then
        log_error "tools.txt file not found!"
        return 1
    fi
    
    while IFS='=' read -r name tool || [[ -n "$name" ]]; do
        # Skip empty lines and comments
        [[ -z "$name" || "$name" =~ ^#.*$ ]] && continue
        
        if brew list "$tool" &>/dev/null; then
            log_info "${name} is already installed"
        else
            log_info "Installing ${name}..."
            if brew install "$tool"; then
                log_success "${name} installed successfully"
            else
                log_error "Failed to install ${name}"
            fi
        fi
    done < tools.txt
}

setup_zsh() {
    log_section "Setting up Zsh and Oh My Zsh"
    
    # Install Oh My Zsh if not present
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh..."
        RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        log_info "Oh My Zsh already installed"
    fi
    
    # Install custom plugins
    local plugin_dir="$HOME/.oh-my-zsh/custom/plugins"
    mkdir -p "$plugin_dir"
    
    if [[ -d "oh-my-zsh/plugins/zsh-autosuggestions" ]]; then
        log_info "Installing zsh-autosuggestions plugin..."
        cp -R oh-my-zsh/plugins/zsh-autosuggestions "$plugin_dir/"
    fi
    
    if [[ -d "oh-my-zsh/plugins/zsh-syntax-highlighting" ]]; then
        log_info "Installing zsh-syntax-highlighting plugin..."
        cp -R oh-my-zsh/plugins/zsh-syntax-highlighting "$plugin_dir/"
    fi
    
    log_success "Zsh setup complete"
}

setup_neovim() {
    log_section "Setting up Neovim Configuration"
    
    # Check if Neovim is installed
    if ! command_exists nvim; then
        log_info "Installing Neovim via Homebrew..."
        brew install neovim
    fi
    
    local nvim_config_dir="$HOME/.config/nvim"
    
    # Backup existing config if it exists
    if [[ -d "$nvim_config_dir" ]]; then
        local backup_dir="${nvim_config_dir}.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "Backing up existing Neovim config to $backup_dir"
        mv "$nvim_config_dir" "$backup_dir"
    fi
    
    # Clone your Neovim configuration
    log_info "Cloning Neovim configuration..."
    mkdir -p "$HOME/.config"
    if git clone https://github.com/coderste/neovim-config.git "$nvim_config_dir"; then
        log_success "Neovim configuration cloned successfully"
        
        # Run Neovim once to install plugins (headless mode)
        log_info "Installing Neovim plugins..."
        nvim --headless +qa 2>/dev/null || true
        log_success "Neovim plugins installation initiated"
    else
        log_error "Failed to clone Neovim configuration"
    fi
}

setup_ghostty() {
    log_section "Setting up Ghostty Configuration"
    
    local ghostty_config_dir="$HOME/.config/ghostty"
    local ghostty_config_file="$ghostty_config_dir/config"
    
    # Create Ghostty config directory if it doesn't exist
    mkdir -p "$ghostty_config_dir"
    
    # Backup existing config if it exists
    if [[ -f "$ghostty_config_file" ]]; then
        local backup_file="${ghostty_config_file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "Backing up existing Ghostty config to $backup_file"
        mv "$ghostty_config_file" "$backup_file"
    fi
    
    # Copy Ghostty configuration
    if [[ -f "config/ghostty/config" ]]; then
        log_info "Copying Ghostty configuration..."
        cp "config/ghostty/config" "$ghostty_config_file"
        log_success "Ghostty configuration copied successfully"
    else
        log_warning "Ghostty config file not found at config/ghostty/config, skipping..."
    fi
}

copy_config_files() {
    log_section "Copying configuration files"
    
    local config_files=(".zshrc" ".gitconfig" ".gitignore" ".aliases")
    
    for file in "${config_files[@]}"; do
        if [[ -f "config/$file" ]]; then
            log_info "Copying $file to home directory..."
            cp "config/$file" "$HOME/"
        else
            log_warning "Config file $file not found, skipping..."
        fi
    done
    
    # Copy AWS config
    if [[ -f "config/.aws" ]]; then
        log_info "Copying AWS configuration..."
        mkdir -p "$HOME/.aws"
        cp "config/.aws" "$HOME/.aws/config"
    fi
    
    log_success "Configuration files copied"
}

authenticate_github() {
    log_section "GitHub Authentication"
    
    if command_exists gh; then
        log_info "Authenticating with GitHub CLI..."
        if gh auth status &>/dev/null; then
            log_info "Already authenticated with GitHub"
        else
            log_info "Please authenticate with GitHub CLI..."
            gh auth login
        fi
    else
        log_warning "GitHub CLI not installed, skipping authentication"
    fi
}

create_directories() {
    log_section "Creating development directories"
    
    local directories=("$HOME/code" "$HOME/code/work" "$HOME/code/personal")
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_info "Creating directory: $dir"
            mkdir -p "$dir"
        else
            log_info "Directory already exists: $dir"
        fi
    done
    
    log_success "Development directories created"
}

print_manual_tasks() {
    log_section "Manual Tasks Remaining"
    
    echo -e "${YELLOW}The following tasks require manual completion:${NC}"
    echo "• Install Dank Mono font manually (licensing restrictions)"
    echo "• Enter licensing keys for Alfred"
    echo "• Sign into VS Code with GitHub to sync settings"
    echo "• Add Jira search to Firefox"
    echo "• Test Neovim setup by running 'nvim' (plugins should auto-install on first run)"
    echo ""
    echo -e "${GREEN}Development environment setup complete!${NC}"
    echo -e "${CYAN}Please restart your terminal or run 'source ~/.zshrc' to apply changes.${NC}"
    echo -e "${CYAN}The 'vim' and 'vi' commands now point to Neovim.${NC}"
}

# Main execution
main() {
    log_info "Starting Mac Development Environment Setup"
    echo -e "${CYAN}This script will set up your Mac for development work.${NC}"
    echo ""
    
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS only!"
        exit 1
    fi
    
    # Check if we're in a git repository for submodules
    if [[ ! -f ".gitmodules" ]]; then
        log_error "This script must be run from the root of the mac-setup git repository!"
        log_error "Make sure you cloned with: git clone --recurse-submodules https://github.com/coderste/mac-setup.git"
        exit 1
    fi
    
    # Check if required files exist
    local required_files=("apps.txt" "tools.txt")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Required file $file not found!"
            exit 1
        fi
    done
    
    # Run setup functions
    install_homebrew
    install_applications
    install_developer_tools
    setup_zsh
    setup_neovim
    setup_ghostty
    copy_config_files
    authenticate_github
    create_directories
    print_manual_tasks
}

# Run main function
main "$@"
