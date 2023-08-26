#!/bin/bash

# Define cross-compiler
export CC=arm-none-eabi-gcc
export CXX=arm-none-eabi-g++
export TEST_CC=gcc
export TEST_CXX=g++

# Define the common flags
export EXCEPTIONS_FLAG="-fexceptions"
export SPECS="nano.specs"
export RTTI="-fno-rtti"
export OPT_DBG_FLAGS="-g3 -O0"
export C_STDR="gnu11"
export CXX_STDR="gnu++20"
export TEST_CXX_STDR="c++20"
export TEST_C_STDR="gnu11"
export C_FLAGS="-std=${C_STDR} -c ${OPT_DBG_FLAGS} --specs=${SPECS} -ffunction-sections -fdata-sections ${EXCEPTIONS_FLAG} -Wall -fstack-usage -MMD -MP -mthumb"
export CXX_FLAGS="-std=${CXX_STDR} -c ${OPT_DBG_FLAGS} --specs=${SPECS} -ffunction-sections -fdata-sections ${EXCEPTIONS_FLAG} -Wall -fstack-usage -MMD -MP -mthumb ${RTTI} -fno-use-cxa-atexit"
export TEST_C_FLAGS="-std=${TEST_C_STDR} -g3 -O0 -Wall"
export TEST_CXX_FLAGS="-std=${TEST_CXX_STDR} -g3 -O0 -Wall"




#
export MCU_FAMILY=""
export PROJECT_NAME=""
export MCU_SRC_DIRS=()
export TEST_EXCLUDED_FILES=(sysmem.c syscalls.c)
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
    #echo "Core: $core -> Startup Script: $startup"

    linker=$(./get_linker_script_for_core.sh "$core" "flash")  # Change "flash" to "sram" if you want RAM
    #echo "Core: $core -> Linker Script: $linker"

    mpu_arch="cortex-${core}"
    #echo "architecture: $mpu_arch"

    fpu_v=${FPU_V_PER_PROCESSOR["${core}"]}
    #echo "fpu_v: $fpu_v"

    fpu="hard"
    path=${core}
    source ./create_makefile.sh -ld $linker -st $startup -ma $mpu_arch -fv $fpu_v -fpu $fpu -p $path
    if [[ ${#MCU_SRC_DIRS[@]} -eq 1 ]]; then
        core=$MCU_SRC_DIR_DEFAULT
    fi
    mv makefile ${PROJECT_NAME}/${CORE_DIR}/${core}/

done




