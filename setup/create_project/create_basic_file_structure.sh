#!/bin/bash

mkdir -p "${PROJECT_NAME}"
mkdir -p "${PROJECT_NAME}/Core"
mkdir -p "${PROJECT_NAME}/Core/Drivers"
mkdir -p "${PROJECT_NAME}/Core/Include/CMSIS"
mkdir -p "${PROJECT_NAME}/Core/Utils"
mkdir -p "${PROJECT_NAME}/Startup"
mkdir -p "${PROJECT_NAME}/Tests"
mkdir -p "${PROJECT_NAME}/.vscode"

# Create directories based on MCU_SRC_DIRS array
for dir in "${MCU_SRC_DIRS[@]}"; do
    mkdir -p "${PROJECT_NAME}/Core/$dir"
done

if [[ $IS_DUAL_CORE -eq 0 ]]; then
    mkdir -p "${PROJECT_NAME}/Core/Common"
fi