#!/bin/bash

SETTINGS="
{
    \"cortex-debug.gdbPath\":\"/usr/bin/arm-none-eabi-gdb\",
    \"cortex-debug.openocdPath\":\"/usr/local/bin/openocd\"
}"


echo "${SETTINGS}" > settings.json
echo "settings.json has been created!"