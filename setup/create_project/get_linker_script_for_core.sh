#!/bin/bash

getLinkerScriptForCore() {
    local core="$1"
    local memory_type="$2"  # This should be either "flash" or "sram"
    local linker_script=""
    local p=""

    # Find all .ld files in the LINKER_DIR
    local ld_files=($(find "$PROJECT_NAME/$LINKER_DIR" -type f -name "*.ld"))

    # Check the number of .ld files found
    if [[ ${#ld_files[@]} -eq 1 ]]; then
        linker_script="${ld_files[0]}"
        p="${linker_script##*/}"
    elif [[ ${#ld_files[@]} -gt 1 ]]; then
        for file in "${ld_files[@]}"; do
            # Extract the core suffix from the filename
            local suffix="${file##*_}"  # This removes everything up to the last underscore
            suffix="${suffix%.*}"  # This removes the file extension

            # Check if the suffix matches the core and the memory type
            if [[ "$suffix" == "c$core" && "$file" == *"$memory_type"* ]]; then
                linker_script="$file"
                p="${linker_script##*/}"
                break
            fi
        done
    fi

    # Return the matched file's name
    echo "$p"
}

echo $(getLinkerScriptForCore $@)
