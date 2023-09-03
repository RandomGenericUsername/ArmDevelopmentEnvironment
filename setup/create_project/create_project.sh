#!/bin/bash

calling_dir=$(pwd)

cd "$(dirname "$0")"

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
export FF_SECTIONS="-ffunction-sections"
export FNO_CXA_ATEXIT="-fno-use-cxa-atexit"
export FDATA_SECTIONS="-fdata-sections"
export TEST_C_FLAGS="-std=${TEST_C_STDR} -g3 -O0 -Wall"
export TEST_CXX_FLAGS="-std=${TEST_CXX_STDR} -g3 -O0 -Wall"

#
export MCU_FAMILY=""
export PROJECT_NAME=""
export MCU_SRC_DIRS=()
export TEST_EXCLUDED_FILES=(sysmem.c syscalls.c)
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
source ./download_cmsis.sh
source ./download_linker_and_startup_script.sh
./create_settings_json.sh
source ./create_c_cpp_properties_json.sh 
source ./create_tasks_json.sh
source ./download_svd_files.sh
source ./create_launch_json.sh
source ./copy_files.sh
set --
source ./move_makefiles.sh

mv ${PROJECT_NAME} ${calling_dir}

