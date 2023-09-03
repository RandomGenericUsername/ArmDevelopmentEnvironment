#!/bin/bash

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
    DEDICATED_CONFIGS+=$(cat << EOM
{
    "name": "Cortex Debug ${cores}",
    "cwd": "${workspaceFolder}",
    "executable": "./${BUILD_DIR}/${cores}/${PROJECT_NAME}_${cores}.elf",
    "request": "launch",
    "type": "cortex-debug",
    "runToEntryPoint": "main",
    "servertype": "openocd",
    "configFiles": [
        "/usr/local/share/openocd/scripts/interface/stlink.cfg",
        "/usr/local/share/openocd/scripts/target/stm32f4x.cfg"
    ]
},
{
    "name": "Flash and Debug ${cores}",
    "cwd": "${workspaceFolder}",
    "executable": "./${BUILD_DIR}/${cores}/${PROJECT_NAME}_${cores}.elf",
    "request": "launch",
    "type": "cortex-debug",
    "runToEntryPoint": "main",
    "servertype": "openocd",
    "configFiles": [
        "/usr/local/share/openocd/scripts/interface/stlink.cfg",
        "/usr/local/share/openocd/scripts/target/stm32f4x.cfg"
    ],
    "preLaunchTask": "Flash ${cores}"
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
