#!/bin/bash

export FPU_V4="fpv4-sp-d16"
export FPU_V5="fpv5-sp-d16"

# Define an array of supported microcontroller families
export SUPPORTED_FAMILIES=("stm32f411xe" "stm32h755xx" "stm32wl55xx")
export DUAL_CORE_FAMILIES=("stm32h755xx" "stm32wl55xx")

declare -A FPU_V_PER_PROCESSOR
FPU_V_PER_PROCESSOR["m0"]=$FPU_V4
FPU_V_PER_PROCESSOR["m4"]=$FPU_V4
FPU_V_PER_PROCESSOR["m7"]=$FPU_V5

declare -A IS_BOARD_OR_TARGET
IS_BOARD_OR_TARGET["stm32f411xe"]="board"
IS_BOARD_OR_TARGET["stm32h755xx"]="target"
IS_BOARD_OR_TARGET["stm32wl55xx"]="target"


# Declare an associative array for dual-core families
declare -A DUAL_CORE_PROCESSORS
DUAL_CORE_PROCESSORS["stm32h755xx"]="m4 m7"
DUAL_CORE_PROCESSORS["stm32wl55xx"]="m0 m4"