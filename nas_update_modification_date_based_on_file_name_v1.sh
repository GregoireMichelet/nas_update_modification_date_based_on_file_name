#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$0")

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 source_folder"
  echo "Script to update the modification date of files using perl /usr/share/applications/ExifTool/exiftool"
  exit 1
fi

SOURCE_FOLDER=$1

# Check if the source folder exists
if [ ! -d "$SOURCE_FOLDER" ]; then
  echo "Source folder does not exist"
  exit 1
fi

# Create the LOGS folder in the script's directory if it doesn't exist
LOGS_FOLDER="$SCRIPT_DIR/LOGS"
if [ ! -d "$LOGS_FOLDER" ]; then
  mkdir -p "$LOGS_FOLDER"
fi

# Create a log file with a timestamp
log_file="$LOGS_FOLDER/LOG_nas_update_modification_date_based_on_file_name_v1_$(date +%Y%m%d_%H%M%S).log"

echo "START script : $0 at $(date +%Y%m%d_%H%M%S)" >> "$log_file"
echo "Executed in source folder : '$SOURCE_FOLDER'" >> "$log_file"
echo "START script : $0 at $(date +%Y%m%d_%H%M%S)"
echo "Executed in source folder : '$SOURCE_FOLDER'"

# Function to update the modification date of a file based on the file name pattern "IMG-YYYYMMDD-WAXXXXXXXX.jpg"
update_modification_date() {
    local file="$1"
    echo "--------------------------------" >> "$log_file"
    echo "--------------------------------"
    echo "Processing file : $file" >> "$log_file"
    echo "Processing file : $file"

    # Extract the current modification time (HH:MM:SS) of the file
    current_time=$(exiftool -FileModifyDate "$file" | awk -F': ' '/File Modification Date\/Time/ {print $2}' | cut -d' ' -f2)

    # Check if current_time is extracted successfully
    if [ -z "$current_time" ]; then
        echo "Error: Unable to extract current modification time for file $file"
        return
    fi

    echo "File current time : $current_time"

    # Extract hours, minutes, and seconds
    hours=$(echo "$current_time" | cut -d':' -f1)
    minutes=$(echo "$current_time" | cut -d':' -f2)
    seconds=$(echo "$current_time" | cut -d':' -f3 | cut -d'+' -f1)

    # Extract the date from the filename
    date_from_filename=$(echo "$file" | grep -oP '(?<=IMG-)\d{8}(?=-WA)|(?<=VID-)\d{8}(?=-WA)')

    # Format the new modification date
    new_mod_date="${date_from_filename:0:4}:${date_from_filename:4:2}:${date_from_filename:6:2} ${hours}:${minutes}:${seconds}"
    echo "Extracted date : $new_mod_date" >> "$log_file"
    echo "Extracted date : $new_mod_date"

    # Update the file's modification date
    exiftool -P -overwrite_original -FileModifyDate="$new_mod_date" "$file" >> "$log_file" 2>&1
}

# Function to update the modification date for WhatsApp files
update_mod_date_whatsapp() {
    local file="$1"
    echo "--------------------------------" >> "$log_file"
    echo "--------------------------------"
    echo "Processing whatsapp file : $file" >> "$log_file"
    echo "Processing whatsapp file : $file"

    # Extract the current modification time (HH:MM:SS) of the file
    current_time=$(exiftool -FileModifyDate "$file" | awk -F': ' '/File Modification Date\/Time/ {print $2}' | cut -d' ' -f2)

    # Check if current_time is extracted successfully
    if [ -z "$current_time" ]; then
        echo "Error: Unable to extract current modification time for file $file"
        return
    fi

    echo "File current time : $current_time"

    # Extract hours, minutes, and seconds
    hours=$(echo "$current_time" | cut -d':' -f1)
    minutes=$(echo "$current_time" | cut -d':' -f2)
    seconds=$(echo "$current_time" | cut -d':' -f3 | cut -d'+' -f1)

    # Extract the date from the filename
    date_from_filename=$(echo "$file" | grep -oP '(?<=IMG-)\d{8}(?=-WA)|(?<=VID-)\d{8}(?=-WA)')

    # Format the new modification date
    new_mod_date="${date_from_filename:0:4}:${date_from_filename:4:2}:${date_from_filename:6:2} ${hours}:${minutes}:${seconds}"
    echo "Extracted date : $new_mod_date" >> "$log_file"
    echo "Extracted date : $new_mod_date"

    # Update the file's modification date
    exiftool -P -overwrite_original -FileModifyDate="$new_mod_date" "$file" >> "$log_file" 2>&1
}

# Function to update the modification date for "mes-photos" files
update_mod_date_mes_photos() {
    local file="$1"
    echo "--------------------------------" >> "$log_file"
    echo "--------------------------------"
    echo "Processing mes-photos file : $file" >> "$log_file"
    echo "Processing mes-photos file : $file"

    # Extract the date and time from the filename
    date_time_from_filename=$(basename "$file" | grep -oP '\d{8}_\d{6}')

    # Check if date_time_from_filename is extracted successfully
    if [ -z "$date_time_from_filename" ]; then
        echo "Error: Unable to extract date and time from filename for file $file"
        return
    fi

    # Format the new modification date
    new_mod_date="${date_time_from_filename:0:4}:${date_time_from_filename:4:2}:${date_time_from_filename:6:2} ${date_time_from_filename:9:2}:${date_time_from_filename:11:2}:${date_time_from_filename:13:2}"
    echo "Extracted date : $new_mod_date" >> "$log_file"
    echo "Extracted date : $new_mod_date"

    # Update the file's modification date
    exiftool -P -overwrite_original -FileModifyDate="$new_mod_date" "$file"
}

# Main function to determine which format to use and update the modification date
update_modification_date() {
    local file="$1"

    if [[ "$file" =~ IMG-[0-9]{8}-WA[0-9]{4}.jpg ]] || [[ "$file" =~ VID-[0-9]{8}-WA[0-9]{4}.mp4 ]]; then
        update_mod_date_whatsapp "$file"
    elif [[ "$file" =~ [0-9]{8}_[0-9]{6}.jpg ]] || [[ "$file" =~ [0-9]{8}_[0-9]{6}.mp4 ]]; then
        update_mod_date_mes_photos "$file"
    else
        echo "Error: Unrecognized file format for file $file"
    fi
}

# Use find to locate all JPG files and process each one
find "$SOURCE_FOLDER" -type f \( -name 'IMG-*.jpg' -o -name 'VID-*.mp4' -o -name '[0-9]*_[0-9]*.jpg' -o -name '[0-9]*_[0-9]*.mp4' \) -print0 | while IFS= read -r -d '' file; do
    update_modification_date "$file"
done

echo "--------------------------------" >> "$log_file"
echo "END script : $0 at $(date +%Y%m%d_%H%M%S)" >> "$log_file"
echo "Log file created at: $log_file" >> "$log_file"

echo "--------------------------------"
echo "END script : $0 at $(date +%Y%m%d_%H%M%S)"
echo "Log file created at: $log_file"
