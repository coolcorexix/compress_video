#! bin/bash

echo "Installing compress_video script..."
curl -o compress_video_quick_action.zip https://raw.githubusercontent.com/coolcorexix/compress_video/refs/heads/main/workflows/compress_video.workflow.zip
unzip -u compress_video_quick_action.zip

cp -R -f compress_video.workflow ~/Library/Services 

echo "Installation complete! You can now use the 'compress_video' command."
echo "Usage: compress_video <input_file>" 
# Remove the downloaded script
rm compress_video_quick_action.zip
rm -rf compress_video.workflow
# folder get created during unzip
rm -rf __MACOSX 