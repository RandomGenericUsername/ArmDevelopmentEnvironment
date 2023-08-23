#!/bin/bash


# Define an array of supported microcontroller families
SUPPORTED_FAMILIES=("stm32f411xe" "stm32h755xx" "stm32wl55xx")
DUAL_CORE_FAMILIES=("stm32h755xx" "stm32wl55xx")
# Declare an associative array for dual-core families
declare -A DUAL_CORE_PROCESSORS
DUAL_CORE_PROCESSORS["${DUAL_CORE_FAMILIES[0]}"]="m4 m7"
DUAL_CORE_PROCESSORS["${DUAL_CORE_FAMILIES[1]}"]="m0 m4"




MCU_FAMILY=""
PROJECT_NAME=""

parseCommands()
{
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
    echo "MCU_FAMILY = $MCU_FAMILY"
    echo "PROJECT_NAME = $PROJECT_NAME"

    # Check if both MCU_FAMILY and PROJECT_NAME are set
    if [[ -z "$MCU_FAMILY" || -z "$PROJECT_NAME" ]]; then
        echo "Error: Both -mcu/--mcu-family and -pn/--project-name options are required."
        exit 1
    fi
}
assertArguments()
{
    # Check if the provided MCU_FAMILY is in the SUPPORTED_FAMILIES array
    if ! [[ " ${SUPPORTED_FAMILIES[@]} " =~ " ${MCU_FAMILY} " ]]; then
        echo "Error: Unsupported microcontroller family."
        echo "Supported families are: ${SUPPORTED_FAMILIES[*]}"
        exit 1  # Exit the script if the condition is not met
    fi
}

createDirectories()
{
    mkdir -p "${PROJECT_NAME}"
    mkdir -p "${PROJECT_NAME}/Core"
    mkdir -p "${PROJECT_NAME}/Core/Drivers"
    mkdir -p "${PROJECT_NAME}/Core/Include/CMSIS"
    mkdir -p "${PROJECT_NAME}/Core/Utils"
    mkdir -p "${PROJECT_NAME}/Startup"
    mkdir -p "${PROJECT_NAME}/Tests"
    mkdir -p "${PROJECT_NAME}/.vscode"
    touch "${PROJECT_NAME}/Tests/main.cpp"
    cat test_main.txt > "${PROJECT_NAME}/Tests/main.cpp" 
    #cp makefile "${PROJECT_NAME}"

    # Store the original directory path
    ORIGINAL_DIR=$(pwd)
    
    # Change to the .vscode directory
    cd "${PROJECT_NAME}/.vscode"
    
    # Execute the scripts using the stored original directory path
    $ORIGINAL_DIR/create_settings_json.sh 
    $ORIGINAL_DIR/create_c_cpp_properties_json.sh -pn "$PROJECT_NAME"
    
    # Change back to the original directory
    cd $ORIGINAL_DIR
}

checkIfDualCoreFamily()
{
    for family in "${DUAL_CORE_FAMILIES[@]}"; do
        if [[ "$MCU_FAMILY" == "$family" ]]; then
            echo "$MCU_FAMILY is a dual-core family."
            createDualCoreProject
            return 0
        fi
    done
    createSingleCoreProject "Src" "main"
    return 0
}
createSingleCoreProject()
{
    mkdir -p "${PROJECT_NAME}/Core/$1"
    touch "${PROJECT_NAME}/Core/$1/$2.cpp"
    cat main.txt > "${PROJECT_NAME}/Core/$1/$2.cpp"
    ./create_makefile.sh -c "single" -t "$1" -n "${PROJECT_NAME}" -s "${MCU_FAMILY}"
    cp syscalls.c sysmem.c "${PROJECT_NAME}/Core/$1"
    mv temp "${PROJECT_NAME}/Core/$1"
    mv "${PROJECT_NAME}/Core/$1/temp" "${PROJECT_NAME}/Core/$1/makefile"
}

createDualCoreProjectHelper()
{
    EXCLUDE_DIRS=""
    for proc in "${PROCESSORS[@]}"; do
        if [ -z "$EXCLUDE_DIRS" ]; then
            EXCLUDE_DIRS="core_$proc"
        else
            EXCLUDE_DIRS="$EXCLUDE_DIRS,core_$proc"
        fi
    done

    mkdir -p "${PROJECT_NAME}/Core/$1"
    touch "${PROJECT_NAME}/Core/$1/$2.cpp"
    cat main.txt > "${PROJECT_NAME}/Core/$1/$2.cpp"
    ./create_makefile.sh -c "dual" -t "${EXCLUDE_DIRS}" -n "${PROJECT_NAME}" -e $3 
    mv temp "${PROJECT_NAME}/Core/$1"
    mv "${PROJECT_NAME}/Core/$1/temp" "${PROJECT_NAME}/Core/$1/makefile"
}

createDualCoreProject()
{
    # Get the microprocessors for the provided MCU family
    IFS=' ' read -ra PROCESSORS <<< "${DUAL_CORE_PROCESSORS[$MCU_FAMILY]}"
    
    # Create directories for each microprocessor
    # Create directories for each microprocessor
    for idx in "${!PROCESSORS[@]}"; do
        FILE_NAME="main_${PROCESSORS[$idx]}"
        FILE_PATH="core_${PROCESSORS[$idx]}"
        
        # Determine the other processor
        if [ "$idx" -eq "0" ]; then
            OTHER_PROCESSOR="core_${PROCESSORS[1]}"
        else
            OTHER_PROCESSOR="core_${PROCESSORS[0]}"
        fi
        
        createDualCoreProjectHelper ${FILE_PATH} ${FILE_NAME} ${OTHER_PROCESSOR}
    done
    COMMON_DIR="${PROJECT_NAME}/Core/Common"
    mkdir -p $COMMON_DIR 
    cp syscalls.c sysmem.c $COMMON_DIR 
}
# Function to download resources based on the MCU family
downloadResources() 
{
    script_name="./get_${MCU_FAMILY}_resources.sh"
    if [[ -f "$script_name" ]]; then
        echo "Executing $script_name..."
        export MCU_FAMILY
        export PROJECT_NAME
        source "$script_name"
    else
        echo "Error: Script $script_name not found!"
    fi
}



# Main execution
main() 
{
    parseCommands "$@"
    assertArguments
    createDirectories
    checkIfDualCoreFamily
    downloadResources
    echo "Creating project for ${MCU_FAMILY}"
}

# Call the main function
main "$@"