#!/bin/bash

# =========================================================
# Default Variables
# =========================================================
MODE="candidate"
BASE_URL="https://ftp.mozilla.org/pub/thunderbird/candidates/"
PREFIX=""

# =========================================================
# Argument Parsing
# =========================================================
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -r|--release)
            MODE="release"
            BASE_URL="https://ftp.mozilla.org/pub/thunderbird/releases/"
            shift # Move past the flag
            ;;
        -h|--help)
            echo "Usage: $0 [-r|--release] [PREFIX]"
            echo "  -r, --release    Use the releases directory instead of candidates"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Usage: $0 [-r|--release] [PREFIX]"
            exit 1
            ;;
        *)
            # If it's not a flag, it must be the prefix
            PREFIX="$1"
            shift
            ;;
    esac
done

# Ensure the base URL always ends with a trailing slash
BASE_URL="${BASE_URL%/}/"

# ---------------------------------------------------------
# Step 1: Find the latest version directory
# ---------------------------------------------------------
echo "Searching for the latest directory in $BASE_URL..."

# Adjust search pattern based on whether we are looking at candidates or releases
if [ "$MODE" == "candidate" ]; then
    DIR_PATTERN="href=\"[^\"]*${PREFIX}[^\"]+-candidates/\""
else
    # Exclude folders that start with letters (like 'latest/') to ensure we grab versions
    DIR_PATTERN="href=\"[^\"]*${PREFIX}[0-9][^\"]+/\""
    LATEST_BUILD="release"
fi

LATEST_DIR=$(curl -s "$BASE_URL" | \
  grep -oE "$DIR_PATTERN" | \
  sed -E 's/href="([^"]+)"/\1/' | \
  awk -F'/' '{print $(NF-1)"/"}' | \
  sort -V | \
  tail -n 1)

if [ -z "$LATEST_DIR" ]; then
  echo "Error: No matching directories found."
  exit 1
fi

echo "-> Found latest version: $LATEST_DIR"
CURRENT_URL="${BASE_URL}${LATEST_DIR}"

# ---------------------------------------------------------
# Step 2: Find the latest build directory (ONLY for candidates)
# ---------------------------------------------------------
if [ "$MODE" == "candidate" ]; then
    echo "Searching for the latest build in $CURRENT_URL..."

    LATEST_BUILD=$(curl -s "$CURRENT_URL" | \
      grep -oE "href=\"[^\"]*build[0-9]+/?\"" | \
      sed -E 's/href="([^"]+)"/\1/' | \
      awk -F'/' '{print $(NF-1)"/"}' | \
      sort -V | \
      tail -n 1)

    if [ -z "$LATEST_BUILD" ]; then
      echo "Error: No build directories found inside $CURRENT_URL"
      exit 1
    fi

    echo "-> Found latest build: $LATEST_BUILD"
    CURRENT_URL="${CURRENT_URL}${LATEST_BUILD}"
fi

# ---------------------------------------------------------
# Step 3: Find the .dmg file in mac/en-US/
# ---------------------------------------------------------
MAC_DIR_URL="${CURRENT_URL}mac/en-US/"

echo "Searching for the .dmg file in $MAC_DIR_URL..."

DMG_FILE=$(curl -s "$MAC_DIR_URL" | \
  grep -oE "href=\"[^\"]+\.dmg\"" | \
  sed -E 's/href="([^"]+)"/\1/' | \
  awk -F'/' '{print $NF}' | \
  head -n 1)

if [ -z "$DMG_FILE" ]; then
  echo "Error: No .dmg file found in $MAC_DIR_URL"
  exit 1
fi

# URL-encode the filename (replace spaces with %20)
ENCODED_DMG_FILE=$(echo "$DMG_FILE" | sed 's/ /%20/g')

DOWNLOAD_URL="${MAC_DIR_URL}${ENCODED_DMG_FILE}"
echo "---------------------------------------------------------"
echo "File ready to download: $DMG_FILE"
echo "Build: ${LATEST_BUILD////}"
echo ""
echo "From: $DOWNLOAD_URL"
echo "---------------------------------------------------------"

# ---------------------------------------------------------
# Step 4: Ask for confirmation
# ---------------------------------------------------------
read -p "Do you want to proceed with the download? (y/n) " -n 1 -r
echo    

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Starting download..."
    curl -o "$DMG_FILE" "$DOWNLOAD_URL"
    echo "Download complete! Saved to your current directory."
else
    echo "Download cancelled by user."
    exit 0
fi
