#!/bin/bash


# Check if the MCU is dual-core or single-core and populate MCU_SRC_DIRS accordingly
if [[ "$IS_DUAL_CORE" == "0" ]]; then
    # Split the cores based on space and add them to the MCU_SRC_DIRS array
    IFS=' ' read -ra CORES <<< "${DUAL_CORE_PROCESSORS[$MCU_FAMILY]}"
    for core in "${CORES[@]}"; do
        MCU_SRC_DIRS+=("$core")
    done
else
    MCU_SRC_DIRS+=("${MCU_SRC_DIR_DEFAULT}")
fi