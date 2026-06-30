#!/bin/bash

# --- Function: Display Help ---
show_usage() {
    echo "Usage: $(basename "$0") [TARGET_DIRECTORY]"
    echo ""
    echo "Description:"
    echo "  Recursively finds and removes all files with these extensions:"
    echo " *.txt *.keras *.pkl log* 2025* Noisy* ML .DS_Store tb_model"
    echo "  inside TARGET_DIRECTORY."
    echo ""
    echo "Arguments:"
    echo "  TARGET_DIRECTORY  The root folder to start searching in."
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message and exit."
    echo ""
    echo "Example:"
    echo "  ./cleanfolder.sh /Users/jdoe/Documents"
}

# --- Argument Parsing ---

# Check if the first argument is a help flag or empty.
# We accept -h, --help, help, or man.
if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" || "$1" == "man" ]]; then
    show_usage
    exit 0
fi

# --- Configuration ---
TARGET_DIR=$1

# --- Script Logic ---

# Check if the target directory exists.
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: The directory '$TARGET_DIR' does not exist."
    exit 1
fi

for TARGET_FILE in *.txt *.keras *.pkl log* 2025* Noisy* ML .DS_Store; do
    echo "Searching for and removing '$TARGET_FILE' (files or folders) in '$TARGET_DIR'..."
    find "$TARGET_DIR" -name "$TARGET_FILE" -prune -exec rm -rf {} \;
    echo "Done. All instances of '$TARGET_FILE' have been removed from '$TARGET_DIR'."
done
