#!/bin/bash


target_config_name=${TARGET_CONFIG[${MCU_FAMILY}]}
declare -n target_config=$target_config_name

target_sel_name=${TARGET_SEL[${MCU_FAMILY}]}
declare -n target_sel=$target_sel_name

interface_config_name=${INTERFACE_CONFIG[${MCU_FAMILY}]}
declare -n interface_config=$interface_config_name


COMMON_CONFIG=$(cat << EOM
{
    "name": "Debug Test",
    "type": "cppdbg",
    "request": "launch",
    "program": "\${workspaceFolder}/${BUILD_DIR}/${TESTS_DIR}/${PROJECT_NAME}_test.elf",
    "args": [],
    "stopAtEntry": false,
    "cwd": "\${workspaceFolder}",
    "environment": [],
    "externalConsole": false,
    "MIMode": "gdb",
    "miDebuggerPath": "/usr/bin/gdb-multiarch",
    "setupCommands": [
        {
            "description": "Enable pretty-printing for gdb",
            "text": "-enable-pretty-printing",
            "ignoreFailures": true
        }
    ]
}
EOM
)

DEDICATED_CONFIGS=""
for cores in ${MCU_SRC_DIRS[@]}; do

    svd_file=$(find "${PROJECT_NAME}" -name '*.svd' )

    BOARD_OR_TARGET=${target_sel[$cores]}
    BOARD_OR_TARGET_VALUE=${target_config[$cores]}
    INTERFACE=${interface_config[$cores]}

    if [[ ${#MCU_SRC_DIRS[@]} -gt 1 ]];then

        executable=\"./${BUILD_DIR}/${PROJECT_NAME}_${cores}.elf\"
        cores=${cores^^}
        svd_file=$(echo "${svd_file}" |  grep -E "${UPPERCASE_MCU_FAMILY:0:8}[a-z A-Z 0-9]_C${cores:0:3}\.svd$")
        else
            cores=""
            executable=\"./${BUILD_DIR}/${PROJECT_NAME}.bin\"
    fi

    svd_file="${svd_file#*/}"
    cores=${cores,,}
    DEDICATED_CONFIGS+=$(cat << EOM
{
    "name": "Cortex Debug ${cores}",
    "cwd": "\${workspaceFolder}",
    "type": "cortex-debug",
    "executable": $executable,
    "request": "launch",
    "servertype": "stlink",
    "device" : "STM32H755ZI",
    "interface" : "swd",
    "serialNumber" : "",
    "runToEntryPoint": "main",
    "svdFile": "${svd_file}",
    "v1" : false,
    "showDevDebugOutput" : "both"

},
EOM
)
done

LAUNCH_JSON=$(cat << EOM
{
   "version": "0.2.0",
   "configurations": [
       $COMMON_CONFIG,
       $DEDICATED_CONFIGS
   ]
}
EOM
)

echo "${LAUNCH_JSON}" > $PROJECT_NAME/.vscode/launch.json

