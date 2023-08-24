#!/bin/bash



parseOptions() {

    declare -A mandatory_options=(
        ["STARTUP_SCRIPT"]="-st or --startup-script"
        ["LINKER_SCRIPT"]="-ld or --linker-script"
        ["MPU_ARCH"]="-ma or --mpu-arch"
        ["FPU_V"]="-fv or --fpu-v"
        ["FPU"]="-fpu"
    )
    missing_params=0
    while [[ "$#" -gt 0 ]]; do
        key="$1"
        case $key in
            -st|--startup-script)
                STARTUP_SCRIPT="$2"
                shift
                shift
                ;;
            -ld|--linker-script)
                LINKER_SCRIPT="$2"
                shift
                shift
                ;;
            -ma|--mpu-arch)
                MPU_ARCH="$2"
                shift
                shift
                ;;
            -fv|--fpu-v)
                FPU_V="$2"
                shift
                shift
                ;;
            -fpu)
                FPU="$2"
                shift
                shift
                ;;
            -sd|--startup-dir)
                STARTUP_DIR="$2"
                shift
                shift
                ;;
            -bd|--build-dir)
                BUILD_DIR="$2"
                shift
                shift
                ;;
            -ld|--linker-dir)
                LINKER_DIR="$2"
                shift
                shift
                ;;
            -ssd|--startup-script-dir)
                STARTUP_SCRIPT_DIR="$2"
                shift
                shift
                ;;
            -cd|--core-dir)
                CORE_DIR="$2"
                shift
                shift
                ;;
            -dd|--drivers-dir)
                DRIVERS_DIR="$2"
                shift
                shift
                ;;
            -ud|--utils-dir)
                UTILS_DIR="$2"
                shift
                shift
                ;;
            -id|--include-dir)
                INC_DIR="$2"
                shift
                shift
                ;;
            -td|--test-dir)
                TEST_DIR="$2"
                shift
                shift
                ;;
            -comd|--common-dir)
                COMMON_DIR="$2"
                shift
                shift
                ;;
            -srcd|--src-dir)
                SRC_DIR="$2"
                shift
                shift
                ;;
            -int|--interface)
                INTERFACE="$2"
                shift
                shift
                ;;
            *)
                echo "Unknown parameter passed: $1"
                exit 1
                ;;
        esac
    done

    for var in "${!mandatory_options[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo "Error: Missing ${mandatory_options[$var]} option."
            missing_params=1
        fi
    done

    if [[ $missing_params -eq 1 ]]; then
        exit 1
    fi

}

parseOptions "$@"


#PROJECT_NAME="project"

INTERFACE="stlink"
#MCU_FAMILY=""
STARTUP_SCRIPT=""
LINKER_SCRIPT=""
MPU_ARCH=""
FPU_V=""
FPU=""
STARTUP_SCRIPT_PATH=$STARTUP_SCRIPT_DIR/$STARTUP_SCRIPT
LINKER_SCRIPT_PATH=$LINKER_DIR/$LINKER_SCRIPT

if [[ ${#MCU_SRC_DIRS[@]} -eq 1 ]]; then
    TESTS_EXCLUDED_DIRS=$MCU_SRC_DIR_DEFAULT
else 
    TESTS_EXCLUDED_DIRS=$MCU_SRC_DIRS
fi

EXCLUDED_DIRS=(${TESTS_DIR})
for dir in "${MCU_SRC_DIRS[@]}"; do
    if [[ "$dir" != "$SRC_DIR" ]]; then
        EXCLUDED_DIRS+=("$dir")
    fi
done
