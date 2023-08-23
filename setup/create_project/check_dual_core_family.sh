#!/bin/bash

for family in "${DUAL_CORE_FAMILIES[@]}"; do
    if [[ "$MCU_FAMILY" == "$family" ]]; then
        echo 0
        exit 0
    fi
done
echo 1
exit 1