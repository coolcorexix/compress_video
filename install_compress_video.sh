#!/bin/bash

echo "Installing compress_video dependencies..."
PATH=$PATH:/opt/homebrew/bin

# Check if ffmpeg is installed
if ! which ffmpeg &> /dev/null; then
    echo "FFmpeg not found. Installing FFmpeg..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install ffmpeg
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if which apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y ffmpeg
        elif which yum &> /dev/null; then
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



# Copy the compress_video script to /usr/local/bin
curl -o compress_video.sh https://raw.githubusercontent.com/coolcorexix/compress_video/refs/heads/main/compress_video.sh
echo "Installing compress_video script..."
curl -o compress_video_quick_action.zip https://raw.githubusercontent.com/coolcorexix/compress_video/refs/heads/main/workflows/compress_video.workflow.zip
unzip -u compress_video_quick_action.zip

cp -R -f compress_video.workflow ~/Library/Services 
sudo cp -f compress_video.sh /usr/local/bin/compress_video


# Make the script executable
sudo chmod +x /usr/local/bin/compress_video
echo "Installation complete! You can now use the 'compress_video' command."
echo "Usage: compress_video <input_file>" 
# Remove the downloaded script
rm compress_video.sh
rm compress_video_quick_action.zip
# folder get created during unzip
rm -rf __MACOSX 
rm -rf compress_video.workflow