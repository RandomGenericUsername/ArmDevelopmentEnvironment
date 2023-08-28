#!/bin/bash

export FPU_V4="fpv4-sp-d16"
export FPU_V5="fpv5-sp-d16"

# Define an array of supported microcontroller families
export SUPPORTED_FAMILIES=("stm32f411xe" "stm32h755xx" "stm32wl55xx")

# Declare an associative array for dual-core families
declare -A MPU_PER_MCU_FAMILY 
MPU_PER_MCU_FAMILY["stm32h755xx"]="m4 m7"
MPU_PER_MCU_FAMILY["stm32wl55xx"]="m0plus m4"
MPU_PER_MCU_FAMILY["stm32f411xe"]="m4"



declare -A FPU_V_PER_PROCESSOR
FPU_V_PER_PROCESSOR["m0plus"]=$FPU_V4
FPU_V_PER_PROCESSOR["m4"]=$FPU_V4
FPU_V_PER_PROCESSOR["m7"]=$FPU_V5

declare -A FPU_PER_PROCESSOR
FPU_PER_PROCESSOR["m0plus"]="hard"
FPU_PER_PROCESSOR["m4"]="hard"
FPU_PER_PROCESSOR["m7"]="hard"

declare -A IS_BOARD_OR_TARGET
IS_BOARD_OR_TARGET["stm32f411xe"]="board st_nucleo_f4"
IS_BOARD_OR_TARGET["stm32h755xx"]="board st_nucleo_h745zi"
IS_BOARD_OR_TARGET["stm32wl55xx"]="target stm32wlx"



#declare -A LINKER_SCRIPT_PER_MPU
#LINKER_SCRIPT_PER_MPU[""]