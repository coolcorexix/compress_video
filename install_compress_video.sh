#!/bin/bash

echo "Installing compress_video dependencies..."

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "FFmpeg not found. Installing FFmpeg..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install ffmpeg
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y ffmpeg
        elif command -v yum &> /dev/null; then
            sudo yum install -y ffmpeg
        else
            echo "Error: Unsupported package manager. Please install FFmpeg manually."
            exit 1
        fi
    else
        echo "Error: Unsupported operating system"
        exit 1
    fi
fi

# Check if source file exists
if [ ! -f "compress_video.sh" ]; then
    echo "Error: compress_video.sh not found in current directory"
    exit 1
fi

# Copy the compress_video script to /usr/local/bin
curl -o compress_video.sh https://raw.githubusercontent.com/coolcorexix/compress_video/refs/heads/main/install_compress_video.sh
echo "Installing compress_video script..."
sudo cp compress_video.sh /usr/local/bin/compress_video
# Remove the downloaded script
rm compress_video.sh

# Make the script executable
sudo chmod +x /usr/local/bin/compress_video

echo "Installation complete! You can now use the 'compress_video' command."
echo "Usage: compress_video <input_file> [output_file]" 