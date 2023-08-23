#!/bin/bash

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    key="$1"
    case $key in
        -mcu|--mcu-family)
            MCU_FAMILY="$2"
            shift # past argument
            shift # past value
            ;;
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

# Debug print statements
#echo "MCU_FAMILY = $MCU_FAMILY"
#echo "PROJECT_NAME = $PROJECT_NAME"

# Check if both MCU_FAMILY and PROJECT_NAME are set
if [[ -z "$MCU_FAMILY" || -z "$PROJECT_NAME" ]]; then
    echo "Error: Both -mcu/--mcu-family and -pn/--project-name options are required."
    exit 1
fi


