#!/bin/bash
getStartupScriptForCore() {
    local core="$1"
    local st=""
    local p=""
    
    # Find all .s files in the STARTUP_SCRIPT_DIR
    local s_files=($(find "$PROJECT_NAME/$STARTUP_SCRIPT_DIR" -type f -name "*.s"))
    
    # Check the number of .s files found
    if [[ ${#s_files[@]} -eq 1 ]]; then
        st="${s_files[0]}"
        p="${st#*/}"
    elif [[ ${#s_files[@]} -gt 1 ]]; then
        for file in "${s_files[@]}"; do
            # Extract the core suffix from the filename (e.g., cm7 from startup_xxxxx_cm7.s)
            local suffix="${file##*_}"  # This removes everything up to the last underscore
            suffix="${suffix%.*}"  # This removes the file extension
            
            # Check if the suffix matches the core
            if [[ "$suffix" == "c$core" ]]; then
                st="$file"
                p="${st#*/}"
                break
            fi
        done
    fi

    # Return the matched file's name
    echo "$p"
}

echo $(getStartupScriptForCore $@)