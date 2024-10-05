#!/bin/bash

# Define the source directory
SOURCE_DIR="new"

# Iterate over each file in the "new" directory
for file in "$SOURCE_DIR"/*; do
  # Check if the item is a file
  if [ -f "$file" ]; then
    # Extract the filename without the extension
    filename=$(basename "$file")
    dirname="${filename%.*}"

    # Create a new directory with the same name as the filename without the extension
    mkdir -p "$SOURCE_DIR/$dirname"

    # Move the file into the created directory
    mv "$file" "$SOURCE_DIR/$dirname/"
  fi
done
