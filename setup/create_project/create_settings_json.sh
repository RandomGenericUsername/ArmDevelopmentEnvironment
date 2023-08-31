#!/bin/bash

SETTINGS="
{
    \"cortex-debug.gdbPath\":\"/usr/bin/arm-none-eabi-gdb\",
    \"cortex-debug.openocdPath\":\"/usr/local/bin/openocd\"
}"


echo "${SETTINGS}" > "${PROJECT_NAME}/.vscode/settings.json"