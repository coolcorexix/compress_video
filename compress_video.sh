#!/bin/bash

# Check for ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg could not be found. Please install ffmpeg to use this script."
    exit 1
fi

# Function to draw progress bar
draw_progress_bar() {
    local width=50
    local percentage=$1
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))
    
    # Create the bar
    printf "\rProgress: ["
    printf "%${filled}s" '' | tr ' ' '='
    printf "%${empty}s" '' | tr ' ' ' '
    printf "] %3d%%" "$percentage"
}

# Check if input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"
output_file="compressed_${input_file}"

# Get video duration using ffprobe
duration=$(ffmpeg -i "$input_file" 2>&1 | grep "Duration" | cut -d ' ' -f 4 | sed 's/,//')
# Convert duration to integer seconds
duration_seconds=$(echo "$duration" | awk -F: '{print int(($1 * 3600) + ($2 * 60) + $3)}')

# Create temporary file for progress monitoring
progress_file=$(mktemp)
trap "rm -f $progress_file" EXIT

# Start FFmpeg compression in background with progress output
ffmpeg -i "$input_file" -vcodec h264 -crf 28 \
    -progress "$progress_file" \
    "$output_file" 2>/dev/null &

ffmpeg_pid=$!

# Initialize progress variables
current_time=0
last_percentage=0

# Monitor progress
while kill -0 $ffmpeg_pid 2>/dev/null; do
    if [[ -f "$progress_file" ]]; then
        # Get current time from progress file and convert to integer seconds
        current_time=$(grep "out_time_ms" "$progress_file" | tail -n 1 | cut -d'=' -f2)
        if [[ ! -z "$current_time" ]]; then
            # Convert milliseconds to integer seconds
            current_time=$((current_time / 1000000))
            percentage=$((current_time * 100 / duration_seconds))
            
            # Ensure percentage doesn't exceed 100
            if [ "$percentage" -gt 100 ]; then
                percentage=100
            fi
            
            # Only update if percentage changed
            if [ "$percentage" != "$last_percentage" ]; then
                draw_progress_bar "$percentage"
                last_percentage=$percentage
            fi
        fi
    fi
    sleep 0.1
done

# Wait for FFmpeg to finish
wait $ffmpeg_pid
echo # New line after progress bar

# Calculate and show the final compression results
if [ -f "$output_file" ]; then
    original_size=$(stat -f%z "$input_file" 2>/dev/null || stat --format=%s "$input_file")
    new_size=$(stat -f%z "$output_file" 2>/dev/null || stat --format=%s "$output_file")
    size_reduction=$((100 - (new_size * 100 / original_size)))
    
    # Function to format file size
    format_size() {
        local size=$1
        for unit in B KB MB GB TB; do
            if [ $size -lt 1024 ]; then
                echo "$size $unit"
                break
            fi
            size=$((size / 1024))
        done
    }
    
    echo -e "\nCompression completed:"
    echo "Original size: $(format_size $original_size)"
    echo "New size: $(format_size $new_size)"
    echo "File size reduced by: $size_reduction%"
    # Function to create a hyperlink to show in Finder
    create_finder_link() {
        local file_path=$1
        echo "Show in Finder: file://$file_path"
    }

    create_finder_link "$(realpath "$output_file")"
else
    echo -e "\nError: Compression failed"
    exit 1
fi