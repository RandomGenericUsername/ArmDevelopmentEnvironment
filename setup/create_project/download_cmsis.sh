#!/bin/bash

REPO_NAME=""
get_cube_name() {
    local input="$1"
    
    # Extract the two characters after "stm32" using string manipulation
    local extracted=${input:5:2}
    
    # Convert the extracted characters to uppercase
    REPO_NAME="STM32Cube${extracted^^}"
    MCU_REPO_NAME="STM32${extracted^^}xx"
    
}
get_cube_name ${MCU_FAMILY}
BASE_URL="http://github.com/STMicroelectronics/${REPO_NAME}/trunk/Drivers/"
INC_PATH=CMSIS/Include
INC_URL=$BASE_URL/$INC_PATH
DEVICE_PATH=CMSIS/Device/ST/${MCU_REPO_NAME}/Include
DEVICE_URL=$BASE_URL/$DEVICE_PATH

svn checkout $INC_URL ${PROJECT_NAME}/${CORE_DIR}/${INC_DIR}/${INC_PATH}
svn checkout $DEVICE_URL ${PROJECT_NAME}/${CORE_DIR}/${INC_DIR}/${DEVICE_PATH}
