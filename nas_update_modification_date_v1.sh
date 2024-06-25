#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$0")

# Check if the folder and date are provided as arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <folder> <date>"
    echo "Date format: YYYY:MM:DD HH:MM:SS"
    exit 1
fi

SOURCE_FOLDER="$1"
NEW_MODIFICATION_DATE="$2"

# Check if the source folder exists
if [ ! -d "$SOURCE_FOLDER" ]; then
  echo "Source folder does not exist"
  exit 1
fi

# Validate the date format (basic validation)
if [[ ! "$NEW_MODIFICATION_DATE" =~ ^[0-9]{4}:[0-9]{2}:[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
    echo "Error: Invalid date format. Use 'YYYY:MM:DD HH:MM:SS'"
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

# Function to update the modification date for all files in a folder
update_mod_date_for_all() {
    local folder="$1"
    local new_mod_date="$2"
    echo "--------------------------------" >> "$log_file"
    echo "--------------------------------"
    echo "Processing file : $file" >> "$log_file"
    echo "Processing file : $file"

    # Use find to locate jpeg, jpg, mp4, and MP4 files and process each one
    find "$folder" -type f \( -iname '*.jpeg' -o -iname '*.jpg' -o -iname '*.mp4' -o -iname '*.MP4' \) -print0 | while IFS= read -r -d '' file; do
        # Update the file's modification date
        exiftool -P -overwrite_original -FileModifyDate="$new_mod_date" "$file" >> "$log_file" 2>&1
    done
}

# Call the function to update the modification date for all files
update_mod_date_for_all "$SOURCE_FOLDER" "$NEW_MOD_DATE"

echo "--------------------------------" >> "$log_file"
echo "END script : $0 at $(date +%Y%m%d_%H%M%S)" >> "$log_file"
echo "Log file created at: $log_file" >> "$log_file"

echo "--------------------------------"
echo "END script : $0 at $(date +%Y%m%d_%H%M%S)"
echo "Log file created at: $log_file"
