#!/bin/bash

#
export MCU_FAMILY=""
export PROJECT_NAME=""
export MCU_SRC_DIRS=()
export IS_DUAL_CORE=0
export MCU_SRC_DIR_DEFAULT=Src

export CORE_DIR=Core
export STARTUP_DIR=Startup
export TESTS_DIR=Tests
export BUILD_DIR=Build
export LINKER_DIR=${STARTUP_DIR}
export STARTUP_SCRIPT_DIR=${STARTUP_DIR}
export DRIVERS_DIR=Drivers
export UTILS_DIR=Utils
export INC_DIR=Include
export COMMON_DIR=Common
export TARGET_DIR=${BUILD_DIR}/${PROJECT_NAME}
export TARGET=${TARGET_DIR}.elf

source ./stm_mcu_families.sh
source ./parse_commands.sh "$@"
export DOWNLOAD_RESOURCES_SCRIPT_NAME="./get_${MCU_FAMILY}_resources.sh"
source ./populate_mcu_src_dirs.sh
source ./create_basic_file_structure.sh
source ./download_resources.sh
./create_settings_json.sh
source ./create_c_cpp_properties_json.sh 
source ./copy_files.sh
source ./to_lower_case.sh
set --

for core in "${MCU_SRC_DIRS[@]}"; do

    startup=$(./get_startup_script_for_core.sh "$core")
    echo "Core: $core -> Startup Script: $st"

    linker=$(./get_linker_script_for_core.sh "$core" "flash")  # Change "flash" to "sram" if you want RAM
    echo "Core: $core -> Linker Script: $linker"

    mpu_arch="cortex-${core}"
    echo "architecture: $mpu_arch"

    fpu_v=${FPU_V_PER_PROCESSOR["${core}"]}
    echo "fpu_v: $fpu_v"

    fpu="hard"

done

#source ./create_makefile.sh -ld



