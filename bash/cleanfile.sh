#!/bin/bash

# --- Function: Display Help ---
show_usage() {
    echo "Usage: $(basename "$0") [TARGET_NAME] [TARGET_DIRECTORY]"
    echo ""
    echo "Description:"
    echo "  Recursively finds and removes all files or folders matching TARGET_NAME"
    echo "  inside TARGET_DIRECTORY."
    echo ""
    echo "Arguments:"
    echo "  TARGET_NAME       The name of the file or folder to delete (e.g., '.DS_Store' or 'node_modules')."
    echo "  TARGET_DIRECTORY  The root folder to start searching in."
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message and exit."
    echo ""
    echo "Examples:"
    echo "  ./cleanfile.sh .DS_Store /Users/jdoe/Documents"
    echo "  ./cleanfile.sh node_modules ."
}

# --- Argument Parsing ---

# Check if the first argument is a help flag or empty.
# We accept -h, --help, help, or man.
if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" || "$1" == "man" ]]; then
    show_usage
    exit 0
fi

# Check if we have the required arguments (we need at least 2).
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing arguments."
    show_usage
    exit 1
fi

# --- Configuration ---
TARGET_FILE=$1
TARGET_DIR=$2

# --- Script Logic ---

# Check if the target directory exists.
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: The directory '$TARGET_DIR' does not exist."
    exit 1
fi

echo "Searching for and removing '$TARGET_FILE' (files or folders) in '$TARGET_DIR'..."

# The core command:
# 1. Look in TARGET_DIR
# 2. Find items named TARGET_FILE
# 3. -prune: If found, do not look inside it (prevents errors when deleting folders)
# 4. -exec rm -rf: Force remove recursively
find "$TARGET_DIR" -name "$TARGET_FILE" -prune -exec rm -rf {} \;

echo "Done. All instances of '$TARGET_FILE' have been removed from '$TARGET_DIR'."
