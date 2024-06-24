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
echo "--------------------------------" >> "$log_file"
echo "--------------------------------"

# Add the new TAG to the XMP IPTC "Subject" metadata for all files in the destination folder and redirect output to log file
cat cleaned_not_matching_files.txt | xargs -I {} perl /usr/share/applications/ExifTool/exiftool -r -P -v -overwrite_original_in_place -XMP:Subject+="$TAG" "{}" >> "$log_file" 2>&1

# Loop through all JPG files in the source folder
for file in $SOURCE_FOLDER; do
    # Extract the date from the filename
    date_from_filename=$(echo "$file" | grep -oP '(?<=IMG-)\d{8}(?=-WA)')

    # Extract the current modification time (HH:MM:SS) of the file
    file_current_date=$(exiftool -s -s -s -FileModifyDate "$file" | awk '{print $4}')

    # Format the new modification date
    new_mod_date="${date_from_filename:0:4}:${date_from_filename:4:2}:${date_from_filename:6:2} $file_current_date"

    # Update the file's modification date
    exiftool -P -overwrite_original -FileModifyDate="$new_mod_date" "$file"
done

echo "--------------------------------" >> "$log_file"
echo "END script : $0 at $(date +%Y%m%d_%H%M%S)" >> "$log_file"

# Print log file location
echo "--------------------------------"
echo "END script : $0 at $(date +%Y%m%d_%H%M%S)"
echo "Log file created at: $log_file"
