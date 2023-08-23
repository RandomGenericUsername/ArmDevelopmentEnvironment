#!/bin/bash

#
export MCU_FAMILY=""
export PROJECT_NAME=""
export MCU_SRC_DIRS=()
export IS_DUAL_CORE=0
export MCU_SRC_DIR_DEFAULT=Src

source ./stm_mcu_families.sh
source ./parse_commands.sh "$@"
./assert_arguments.sh "$MCU_FAMILY" "${SUPPORTED_FAMILIES[@]}"
IS_DUAL_CORE=$(source ./check_dual_core_family.sh)
source ./populate_mcu_src_dirs.sh
source ./create_basic_file_structure.sh
source ./download_resources.sh
./create_settings_json.sh
source ./create_c_cpp_properties_json.sh 
source ./copy_files.sh
source ./to_lower_case.sh
set --

#source ./create_makefile.sh -ld



