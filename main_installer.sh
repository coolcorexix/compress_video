#!/bin/bash

# Color codes for formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Quick Action and Destination Paths
SOURCE_QUICK_ACTION="compress_video.workflow"
DESTINATION_PATH="$HOME/Library/Services"

# Function to check and install Homebrew
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        echo -e "${GREEN}Adding Homebrew to PATH...${NC}"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$USER/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

# Function to install ffmpeg
install_ffmpeg() {
    if ! command -v ffmpeg &> /dev/null; then
        echo -e "${YELLOW}ffmpeg not found. Installing ffmpeg...${NC}"
        brew install ffmpeg
    else
        echo -e "${GREEN}ffmpeg is already installed.${NC}"
    fi
}

# Function to install Quick Action
install_quick_action() {
    # Ensure destination directory exists
    mkdir -p "$DESTINATION_PATH"
    
    # Copy Quick Action
    cp -R "$SOURCE_QUICK_ACTION" "$DESTINATION_PATH/"
    
    # Set correct permissions
    chmod -R 644 "$DESTINATION_PATH/$SOURCE_QUICK_ACTION.workflow"
    
    echo -e "${GREEN}Quick Action installed successfully!${NC}"
}

# Main installation process
main() {
    echo -e "${YELLOW}Starting Quick Action Installation...${NC}"
    
    # Check for Xcode Command Line Tools
    if ! xcode-select -p &> /dev/null; then
        echo -e "${YELLOW}Installing Xcode Command Line Tools...${NC}"
        xcode-select --install
        # Wait for Xcode CLI tools to install
        while ! xcode-select -p &> /dev/null; do
            sleep 5
        done
    fi
    
    # Install Homebrew
    install_homebrew
    
    # Install ffmpeg
    install_ffmpeg
    
    # Install Quick Action
    install_quick_action
    
    echo -e "${GREEN}Installation Complete! Your Quick Action is now ready to use.${NC}"
}

# Run the installation
main