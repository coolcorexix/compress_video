#!/bin/bash

# this script has to be run without admin privileges because it call brew install

PATH=$PATH:/opt/homebrew/bin

# Check if ffmpeg is installed
if ! which ffmpeg &> /dev/null; then
    echo "FFmpeg not found. Installing FFmpeg..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install ffmpeg
    else
        echo "Error: Unsupported operating system"
        exit 1
    fi
fi