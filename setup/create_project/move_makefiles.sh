#!/bin/bash


for core in "${MCU_SRC_DIRS[@]}"; do

    startup=$(./get_startup_script_for_core.sh "$core")
    #echo "Core: $core -> Startup Script: $startup"

    linker=$(./get_linker_script_for_core.sh "$core" "flash")  # Change "flash" to "sram" if you want RAM
    #echo "Core: $core -> Linker Script: $linker"

    mpu_arch="cortex-${core}"
    #echo "architecture: $mpu_arch"

    fpu_v=${FPU_V_PER_PROCESSOR["${core}"]}

    fpu=${FPU_PER_PROCESSOR["${core}"]}

    source ./create_sub_makefile.sh -ld $linker -st $startup -ma $mpu_arch -fv $fpu_v -fpu $fpu -p $core
    if [[ ${#MCU_SRC_DIRS[@]} -eq 1 ]]; then
        core=$MCU_SRC_DIR_DEFAULT
    fi
    mv makefile ${PROJECT_NAME}/${CORE_DIR}/${core}/
    #SUB_MAKEFILE_ROUTES+=
done

source ./create_root_makefile.sh
mv Makefile ${PROJECT_NAME}/