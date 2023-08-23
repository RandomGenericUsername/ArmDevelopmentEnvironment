#!/bin/bash


script_name="./get_${MCU_FAMILY}_resources.sh"
if [[ -f "$script_name" ]]; then
    source "$script_name"
else
    echo "Error: Script $script_name not found!"
fi