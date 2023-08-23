#!/bin/bash

LINKER_SCRIPT_URL=https://raw.githubusercontent.com/STMicroelectronics/STM32CubeF4/master/Projects/STM32F411RE-Nucleo/Templates/SW4STM32/STM32F4xx-Nucleo/STM32F411RETx_FLASH.ld
LINKER_SCRIPT=${MCU_FAMILY}_flash.ld
STARTUP_SCRIPT_URL=https://raw.githubusercontent.com/STMicroelectronics/STM32CubeF4/master/Projects/STM32F411RE-Nucleo/Templates/SW4STM32/startup_stm32f411xe.s
STARTUP=startup_${MCU_FAMILY}.s

curl -L -o ${STARTUP} "$STARTUP_SCRIPT_URL"
curl -L -o ${LINKER_SCRIPT} "$LINKER_SCRIPT_URL"

mv ${STARTUP} "${PROJECT_NAME}/Startup"
mv ${LINKER_SCRIPT} "${PROJECT_NAME}/Startup"


