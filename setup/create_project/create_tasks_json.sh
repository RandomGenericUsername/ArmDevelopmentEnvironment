#!/bin/bash


#!/bin/bash
PROBLEM_MATCHER=$(cat << 'EOM'
"problemMatcher": {
    "owner": "cpp",
    "fileLocation": ["relative", "${workspaceFolder}"],
    "pattern": {
      "regexp": "^(.*):(\\\\\\d+):(\\\\\\d+):\\\\\\s+(warning|error):\\\\\\s+(.*)$",
      "file": 1,
      "line": 2,
      "column": 3,
      "severity": 4,
      "message": 5
    }
},
"presentation": {
    "reveal": "always"
}
EOM
)

DEDICATED_MAKE_RULES=""
if [[ ${#MCU_SRC_DIRS[@]} -gt 1 ]]; then
    for cores in ${MCU_SRC_DIRS[@]}; do
        # Use printf and sed to adjust the indentation
        INDENTED_PROBLEM_MATCHER=$(printf "$PROBLEM_MATCHER" | sed 's/^/\t/')
        DEDICATED_MAKE_RULES+=$(cat << EOM
{
    //Build for Core ${cores}
    "label": "Build Core ${cores}",
    "type": "process",
    "command": "make",
    "args": [
        "build_project_${cores}"
    ],
$INDENTED_PROBLEM_MATCHER
},
{
    //Clean for Core ${cores}
    "label": "Clean Core ${cores}",
    "type": "process",
    "command": "make",
    "args": [
        "clean_${cores}"
    ],
},
{
	"label": "Flash Core ${cores}",
    "type": "process",
    "command": "make",
    "args": [
        "flash_${cores}"
    ],
    "presentation": {
        "reveal": "always"
    },
    "dependsOn": "Clean Core ${cores} & Build Core ${cores}"
},
{
	"label": "Clean & Build Core ${cores}",
    "dependsOrder": "sequence",
    "dependsOn": ["Clean Core ${cores}", "Build Core ${cores}"]	
},
EOM
)\\n
    done
fi

INDENTED_MAKE_RULES=$(printf "$DEDICATED_MAKE_RULES" | sed 's/^/\t\t/')
COMMON_TASKS=$(cat << EOM
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Clean Project",
            "type": "process",
            "command": "make",
            "args": [
                "clean"
            ],
            "problemMatcher": []
        },
        {
            "label": "Build Project",
            "type": "process",
            "command": "make",
            "args": [
                "all"
            ],
        },
        {
            "label": "Flash Project",
            "type": "process",
            "command": "make",
            "args": [
                "flash"
            ],
            "dependsOrder": "sequence",
            "dependsOn": ["Clean Project", "Build Project"]	
        },
        {
            "label": "Build Test",
            "type": "process",
            "command": "make",
            "args": [
                "build_test"
            ],
        },
        {
            "label": "Run Test",
            "type": "process",
            "command": "make",
            "args": [
                "run_test"
            ],
        },
$INDENTED_MAKE_RULES
    ]
}

EOM
)


echo "${COMMON_TASKS}" > $PROJECT_NAME/.vscode/tasks.json