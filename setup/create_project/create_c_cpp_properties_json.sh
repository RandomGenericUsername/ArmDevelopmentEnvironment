#!/bin/bash

# Define the template for c_cpp_properties.json
C_CPP_PROPERTIES_JSON='{
    "configurations": [
        {
            "name": "Linux",
            "includePath": [
                "${PROJECT_NAME}/${CORE_DIR}/**",
                "${PROJECT_NAME}/${CORE_DIR}/${INC_DIR}/**",
                "${PROJECT_NAME}/${CORE_DIR}/${UTILS_DIR}/**",
                "${PROJECT_NAME}/${CORE_DIR}/${DRIVERS_DIR}/**"
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



# Replace all occurrences of the placeholder in the template with the actual PROJECT_NAME value
C_CPP_PROPERTIES_JSON=$(echo "$C_CPP_PROPERTIES_JSON" | sed "s/\${PROJECT_NAME}/$PROJECT_NAME/g")

# Write the modified template to c_cpp_properties.json
echo "$C_CPP_PROPERTIES_JSON" > "${PROJECT_NAME}/.vscode/c_cpp_properties.json"

echo "c_cpp_properties.json has been created!"
