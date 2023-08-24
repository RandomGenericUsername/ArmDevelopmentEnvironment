#!/bin/bash

mkdir -p "${PROJECT_NAME}"
mkdir -p "${PROJECT_NAME}/${CORE_DIR}"
mkdir -p "${PROJECT_NAME}/${CORE_DIR}/${DRIVERS_DIR}"
mkdir -p "${PROJECT_NAME}/${CORE_DIR}/${INC_DIR}/CMSIS"
mkdir -p "${PROJECT_NAME}/${CORE_DIR}/${UTILS_DIR}"
mkdir -p "${PROJECT_NAME}/${STARTUP_DIR}"
mkdir -p "${PROJECT_NAME}/${TESTS_DIR}"
mkdir -p "${PROJECT_NAME}/.vscode"

# Create directories based on MCU_SRC_DIRS array
for dir in "${MCU_SRC_DIRS[@]}"; do
    FILE_NAME=$dir
    if [[ ${#MCU_SRC_DIRS[@]} -eq 1 ]];then
        FILE_NAME=$MCU_SRC_DIR_DEFAULT
    fi
    mkdir -p "${PROJECT_NAME}/${CORE_DIR}/${FILE_NAME}"
done

if [[ ${#MCU_SRC_DIRS[@]} -gt 1 ]]; then
    mkdir -p "${PROJECT_NAME}/${CORE_DIR}/${COMMON_DIR}"
fi