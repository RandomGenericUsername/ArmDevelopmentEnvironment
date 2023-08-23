#!/bin/bash

# Define the template for c_cpp_properties.json
C_CPP_PROPERTIES_JSON='{
    "configurations": [
        {
            "name": "Linux",
            "includePath": [
                "${WORKSPACE_FOLDER}/Core/Include/**",
                "${WORKSPACE_FOLDER}/Core/Utils/**",
                "${WORKSPACE_FOLDER}/Core/Drivers/**"
            ],
            "defines": [],
            "compilerPath": "/usr/bin/arm-none-eabi-gcc",
            "cStandard": "c17",
            "cppStandard": "c++20",
            "intelliSenseMode": "linux-clang-x64"
        }
    ],
    "version": 4
}'

PROJECT_NAME=""
WORKSPACE_FOLDER=""

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    key="$1"
    case $key in
        -pn|--project-name)
            PROJECT_NAME="$2"
            shift # past argument
            shift # past value
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

# Check if PROJECT_NAME is set
if [[ -z "$PROJECT_NAME" ]]; then
    echo "Error: The -pn/--project-name option is required."
    exit 1
fi

# Set the WORKSPACE_FOLDER variable
WORKSPACE_FOLDER="${PROJECT_NAME}"

# Replace all occurrences of the placeholder in the template with the actual WORKSPACE_FOLDER value
C_CPP_PROPERTIES_JSON=$(echo "$C_CPP_PROPERTIES_JSON" | sed "s/\${WORKSPACE_FOLDER}/$WORKSPACE_FOLDER/g")

# Write the modified template to c_cpp_properties.json
echo "$C_CPP_PROPERTIES_JSON" > c_cpp_properties.json

echo "c_cpp_properties.json has been created!"
