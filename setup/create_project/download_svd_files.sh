#!/bin/bash

REPO_NAME=""
suffix="_"
get_cube_name() {
    local input="$1"
    
    # Extract the two characters after "stm32" using string manipulation
    local extracted=${input:5:2}
    
    # Convert the extracted characters to uppercase
    MCU_SVD_FILE="stm32${extracted}"
    
}
if [[ $MCU_FAMILY == "stm32h755xx" ]];then
    suffix="-"
fi

get_cube_name ${MCU_FAMILY}
FILE="${MCU_SVD_FILE}${suffix}svd"
ZIP_FILE="${FILE}.zip"
DIR_NAME=$(basename "$ZIP_FILE" .zip)
BASE_URL="https://www.st.com/resource/en/svd/${FILE}.zip"
mkdir -p "$DIR_NAME"
curl -f -L -o "$ZIP_FILE" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" "$BASE_URL"
unzip -j "$ZIP_FILE" -d "$DIR_NAME"
rm "$ZIP_FILE" 

export UPPERCASE_MCU_FAMILY="${MCU_FAMILY^^}"
SUBSTRING_MCU_FAMILY="${UPPERCASE_MCU_FAMILY:0:8}"
matching_files=$(find "$DIR_NAME" -type f -name "${SUBSTRING_MCU_FAMILY}*.svd")
DEST_DIR="${PROJECT_NAME}"

# Check if the number of matches is greater than two
if [[ $(echo "$matching_files" | wc -l) -gt 2 ]]; then
    # Filter out the exact matches using grep
    matching_files=$(echo "$matching_files" | grep -E "${UPPERCASE_MCU_FAMILY:0:9}.*\.svd$")
fi

while IFS= read -r file; do
    cp "$file" "$DEST_DIR"
done <<< "$matching_files"
rm -rf "$DIR_NAME"
