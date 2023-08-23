#!/bin/bash
#!/bin/bash

MCU_FAMILY="$1"
shift
SUPPORTED_FAMILIES=("$@")

assertArguments()
{
    # Check if the provided MCU_FAMILY is in the SUPPORTED_FAMILIES array
    if ! [[ " ${SUPPORTED_FAMILIES[@]} " =~ " ${MCU_FAMILY} " ]]; then
        echo "Error: Unsupported microcontroller family."
        echo "Supported families are: ${SUPPORTED_FAMILIES[*]}"
        exit 1  # Exit the script if the condition is not met
    fi
}

assertArguments
