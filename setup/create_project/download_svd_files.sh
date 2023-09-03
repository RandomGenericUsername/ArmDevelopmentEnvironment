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
unzip "$ZIP_FILE" -d "$DIR_NAME"
rm "$ZIP_FILE" 

