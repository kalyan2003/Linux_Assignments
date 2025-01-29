#!/bin/bash

# passing three parameters source directory, backup directory , file extension
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source_directory> <backup_directory> <file_extension>"
    exit 1
fi

# Assigning command-line arguments to variables

SOURCE_DIR="$1"
BACKUP_DIR="$2"
EXTENSION="$3"

# code to ensure source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Creating  backup directory if it does not exist

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" || { echo "Error: Failed to create backup directory."; exit 1; }
fi

# Finding all files with the given extension in the source directory and storing them in an array
FILES=("$SOURCE_DIR"/*"$EXTENSION")

# Checking if files exist in the source directory with the given extension
if [ "${#FILES[@]}" -eq 0 ]; then
    echo "No files with extension '$EXTENSION' found in '$SOURCE_DIR'."
    exit 0
fi

# Initializing backup count as an environment variable
export BACKUP_COUNT=0
TOTAL_SIZE=0

echo "Backing up files..."

# Looping through each file in the source directory
for FILE in "${FILES[@]}"; do
    [ -e "$FILE" ] || continue  # Skip iteration if the file does not exist
    
    # Extracting file name from the full path
    FILENAME=$(basename "$FILE")
    DEST_FILE="$BACKUP_DIR/$FILENAME"

    # Getting file size and modification time
    FILE_SIZE=$(stat -c %s "$FILE")
    FILE_TIME=$(stat -c %Y "$FILE")
    
    # Accumulating total size of files to be backed up
    TOTAL_SIZE=$((TOTAL_SIZE + FILE_SIZE))

    # Checking if the file already exists in the backup directory
    if [ -e "$DEST_FILE" ]; then
        BACKUP_TIME=$(stat -c %Y "$DEST_FILE")
        # Only overwrite the backup file if the source file is new one
        if [ "$FILE_TIME" -le "$BACKUP_TIME" ]; then
            echo "Skipping '$FILENAME' (Backup is up-to-date)"
            continue
        fi
    fi

    # Copying  file to the backup directory
    cp "$FILE" "$BACKUP_DIR/"
    echo "Backed up: $FILENAME ($FILE_SIZE bytes)"
    
    # Incrementing the backup count
    BACKUP_COUNT=$((BACKUP_COUNT + 1))
done

# summary report in the backup directory
REPORT="$BACKUP_DIR/backup_report.log"
echo "Backup Summary" > "$REPORT"
echo "Total files processed: $BACKUP_COUNT" >> "$REPORT"
echo "Total size of files backed up: $TOTAL_SIZE bytes" >> "$REPORT"
echo "Backup location: $BACKUP_DIR" >> "$REPORT"

echo "Backup completed. Report saved at $REPORT"
