#!/bin/bash

# --- Configuration ---
# Set the target directory here. By default, it's set to "a" as requested.
# You can change this to any folder you want to clean.
TARGET_DIR=$1

# --- Script Logic ---

# Check if the target directory exists.
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: The directory '$TARGET_DIR' does not exist."
    exit 1
fi

echo "Searching for and removing .DS_Store files in '$TARGET_DIR'..."

# The core command:
# find: a utility for searching for files in a directory tree.
# "$TARGET_DIR": the starting point for the search.
# -type f: limits the search to regular files only (not directories).
# -name ".DS_Store": specifies the name of the file to find.
# -exec rm {}: executes the 'rm' command on each file found.
# {}: a placeholder for the path of the found file.
# \;: terminates the -exec command.
find "$TARGET_DIR" -type f -name ".DS_Store" -exec rm {} \;

echo "Done. All .DS_Store files have been removed from '$TARGET_DIR' and its subdirectories."
