#!/bin/bash


# Split the cores based on space and add them to the MCU_SRC_DIRS array
IFS=' ' read -ra CORES <<< "${MPU_PER_MCU_FAMILY[$MCU_FAMILY]}"
for core in "${CORES[@]}"; do
    MCU_SRC_DIRS+=("$core")
done