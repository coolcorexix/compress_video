# Compress Video Installation Guide

A simple command-line tool to compress videos using FFmpeg.

## Prerequisites

- Unix-based system (macOS or Linux)
- curl (pre-installed on most systems)
- sudo privileges

## Quick Installation

Install with a single command:

```bash
curl -sSL https://raw.githubusercontent.com/coolcorexix/compress_video/refs/heads/main/install_compress_video.sh | sudo bash
```

## Usage

After installation, you can use the command in two ways:

1. Basic usage (output file will be named automatically):
   ```bash
   compress_video input.mp4
   ```
   This will create `input_compressed.mp4`

2. Specify output filename:
   ```bash
   compress_video input.mp4 output.mp4
   ```

## Troubleshooting

If you see "FFmpeg not found", the script will attempt to install it automatically. If that fails, install FFmpeg manually:
- For macOS: `brew install ffmpeg`
- For Ubuntu/Debian: `sudo apt-get install ffmpeg`
- For CentOS/RHEL: `sudo yum install ffmpeg`

## Uninstallation

To remove the command:
```bash
sudo rm /usr/local/bin/compress_video
```

## Manual Installation

If you prefer to inspect the scripts before installation:

1. Download the installation script:
   ```bash
   curl -O https://raw.githubusercontent.com/coolcorexix/compress_video/refs/heads/main/install_compress_video.sh
   ```

2. Make it executable and run:
   ```bash
   chmod +x install_compress_video.sh
   sudo ./install_compress_video.sh
   ```

## Notes

- The compression uses H.264 codec with default settings
- Original files are not modified; a new compressed file is created
- Compression time depends on the size of the input video