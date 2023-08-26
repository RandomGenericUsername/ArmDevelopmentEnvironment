#!/bin/bash

STARTUP_SCRIPT=""
LINKER_SCRIPT=""
MPU_ARCH=""
FPU_V=""
FPU=""
SRC_PATH=""


declare -A mandatory_options=(
    ["STARTUP_SCRIPT"]="-st or --startup-script"
    ["LINKER_SCRIPT"]="-ld or --linker-script"
    ["MPU_ARCH"]="-ma or --mpu-arch"
    ["FPU_V"]="-fv or --fpu-v"
    ["FPU"]="-fpu"
    ["SRC_PATH"]="-p or --path"
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
        -p|--path)
            SRC_PATH="$2"
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

if [[ ${#MCU_SRC_DIRS[@]} -eq 1 ]]; then
    TESTS_EXCLUDED_DIRS=$MCU_SRC_DIR_DEFAULT
else 
    TESTS_EXCLUDED_DIRS=${MCU_SRC_DIRS[@]}
fi

EXCLUDED_DIRS="-not -path \"../.../${TESTS_DIR}\""
TEST_EXCLUDED_DIRS=""
for dir in "${MCU_SRC_DIRS[@]}"; do
    if [[ "$dir" != "$SRC_PATH" ]]; then
        EXCLUDED_DIRS+=" -not -path \"../${dir}/*\""
    fi
	if [[ "${#MCU_SRC_DIRS[@]}" -eq 1 ]]; then
		dir=${MCU_SRC_DIR_DEFAULT}
	fi
    TEST_EXCLUDED_DIRS+=" -not -path \"../${dir}/*\""
done

TEST_EXCLUDED_FILES_STR=""
for file in "${TEST_EXCLUDED_FILES[@]}"; do
    TEST_EXCLUDED_FILES_STR+=" -not -name \"${file}\""
done


board_or_target_data=${IS_BOARD_OR_TARGET["${MCU_FAMILY}"]}
words=($board_or_target_data)
board_or_target="${words[0]}"
board_or_target_value="${words[1]}"

INTERFACE="stlink"
BUILD_PATH="../../${BUILD_DIR}"
TARGET=${BUILD_PATH}/${SRC_PATH}/${PROJECT_NAME}.elf
TEST_BUILD_PATH="${BUILD_PATH}/${TESTS_DIR}/${SRC_PATH}"
TEST_TARGET=${TEST_BUILD_PATH}/${PROJECT_NAME}.elf

# Define include directories
INC_DIRS="\$(shell find ../ -type d)"
INC_FLAGS="\$(addprefix -I, \$(INC_DIRS))"
COMMON_FLAGS_DEF="-mfpu=${FPU_V} -mfloat-abi=${FPU} \${INC_FLAGS}"
C_FLAGS_DEF="${C_FLAGS} \${COMMON_FLAGS_DEF}"
CXX_FLAGS_DEF="${CXX_FLAGS} \${COMMON_FLAGS_DEF}"
TEST_C_FLAGS_DEF="${TEST_C_FLAGS} \${INC_FLAGS}"
TEST_CXX_FLAGS_DEF="${TEST_CXX_FLAGS} \${INC_FLAGS}"

CXX_SOURCES_CORE="\$(shell find ../ -name '*.cpp' ${EXCLUDED_DIRS})"
C_SOURCES_CORE="\$(shell find ../ -name '*.c' ${EXCLUDED_DIRS})"
TEST_CXX_SOURCES="\$(shell find ../ -name '*.cpp' ${TEST_EXCLUDED_DIRS} ${TEST_EXCLUDED_FILES_STR}) \$(shell find \"../../${TESTS_DIR}\" -name '*.cpp')"
TEST_C_SOURCES="\$(shell find ../ -name '*.c' ${TEST_EXCLUDED_DIRS} ${TEST_EXCLUDED_FILES_STR}) \$(shell find \"../../${TESTS_DIR}\" -name '*.c')"
STARTUP_SCRIPT_PATH=../../$STARTUP_SCRIPT
LINKER_SCRIPT_PATH=../../$LINKER_SCRIPT
OBJ_DIR=${BUILD_PATH}/${SRC_PATH}
TEST_OBJ_DIR=${BUILD_PATH}/${TESTS_DIR}/${SRC_PATH}
CXX_OBJECTS="\$(CXX_SOURCES_CORE:../%.cpp=\${OBJ_DIR}/%.o)"
C_OBJECTS="\$(C_SOURCES_CORE:../%.c=\${OBJ_DIR}/%.o)"
TEST_CXX_OBJ="\$(TEST_CXX_SOURCES_CORE:../%.cpp=\${TEST_OBJ_DIR}/%.o)"
TEST_C_OBJ="\$(TEST_C_SOURCES_CORE:../%.c=\${TEST_OBJ_DIR}/%.o)"
ASM_OBJECTS="\$(STARTUP_SCRIPT_PATH:../../${STARTUP_DIR}/%.s=${OBJ_DIR}/${STARTUP_DIR}/%.o)"
DEPS="\$(CXX_OBJECTS:.o=.d) \$(C_OBJECTS:.o=.d) \$(ASM_OBJECTS:.o=.d)"
asdf=${IS_BOARD_OR_TARGET[$"{MCU_FAMILY}"]}


TEMP=$(cat << EOM

#
CC := ${CC} 
CXX := ${CXX} 
TEST_CC := ${TEST_CC} 
TEST_CXX := ${TEST_CXX}

INTERFACE := ${INTERFACE}
BUILD_PATH := ${BUILD_PATH}
TARGET := ${TARGET}
TEST_BUILD_PATH := ${TEST_BUILD_PATH}
TEST_TARGET := ${TEST_TARGET}

# Define include directories
INC_DIRS += ${INC_DIRS}
INC_FLAGS := ${INC_FLAGS}
COMMON_FLAGS_DEF := ${COMMON_FLAGS_DEF}
C_FLAGS_DEF := ${C_FLAGS_DEF}
CXX_FLAGS_DEF := ${CXX_FLAGS_DEF}
TEST_C_FLAGS_DEF := ${TEST_C_FLAGS_DEF}
TEST_CXX_FLAGS_DEF := ${TEST_CXX_FLAGS_DEF}

CXX_SOURCES_CORE := ${CXX_SOURCES_CORE}
C_SOURCES_CORE := ${C_SOURCES_CORE}
TEST_CXX_SOURCES_CORE := ${TEST_CXX_SOURCES}
TEST_C_SOURCES_CORE := ${TEST_C_SOURCES}
STARTUP_SCRIPT_PATH := ${STARTUP_SCRIPT_PATH}
LINKER_SCRIPT_PATH := ${LINKER_SCRIPT_PATH}
OBJ_DIR := ${OBJ_DIR}
TEST_OBJ_DIR := ${TEST_OBJ_DIR}
CXX_OBJECTS := ${CXX_OBJECTS}
C_OBJECTS := ${C_OBJECTS}
TEST_CXX_OBJECTS := ${TEST_CXX_OBJ}
TEST_C_OBJECTS := ${TEST_C_OBJ}
ASM_OBJECTS := ${ASM_OBJECTS}
DEPS := ${DEPS}

all: clean build_project

build_project: \$(TARGET)

flash: all
    openocd -f interface/${INTERFACE}.cfg -f $board_or_target/$board_or_target_value.cfg -c "progam ./${TARGET} verify reset exit" 

build_test: clean_test \$(TEST_TARGET)

run_test: build_test
	@./\$(TEST_TARGET)


\$(TARGET): \$(CXX_OBJECTS) \$(C_OBJECTS) \$(ASM_OBJECTS) 
	\$(CXX) -T \$(LINKER_PATH) $^ -o \$@ -Wl,-Map=\$(TARGET:.elf=.map),--cref \$(COMMON_FLAGS_DEF) -Wl,--start-group -lc -lm -lstdc++ -lsupc++ -Wl,--end-group -Wl,--print-memory-usage
	@echo 'Finished building target: $@'
	@echo ' '

\$(TEST_TARGET): \$(TEST_CXX_OBJECTS) \$(TEST_C_OBJECTS)
	\$(TEST_CXX) $^ -o \$@ 
	@echo 'Finished building test target: $@'
	@echo ' '



\$(OBJ_DIR)/%.o: ../../${CORE_DIR}/%.cpp
	@mkdir -p \$(@D)
	\$(CXX) $< \$(CXX_FLAGS_DEF) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

\$(OBJ_DIR)/%.o: ../../${CORE_DIR}/%.c
	@mkdir -p \$(@D)
	\$(CC) $< \$(C_FLAGS_DEF) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"


\$(OBJ_DIR)/${STARTUP_DIR}/%.o: ../../${STARTUP_SCRIPT}
	@mkdir -p \$(@D)
	\$(CC) -c $< -o \$@


\$(TEST_OBJ_DIR)/%.o: ../../${CORE_DIR}/%.cpp
	@mkdir -p \$(@D)
	\$(TEST_CXX) -c $< \$(TEST_CXX_FLAGS_DEF) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

\$(TEST_OBJ_DIR)/%.o: ../../${CORE_DIR}/%.c
	@mkdir -p \$(@D)
	\$(TEST_CC) -c $< \$(TEST_C_FLAGS_DEF) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

\$(TEST_OBJ_DIR)/%.o: ../../${TESTS_DIR}/%.cpp
	@mkdir -p \$(@D)
	\$(TEST_CXX) -c $< \$(TEST_CXX_FLAGS_DEF) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

\$(TEST_OBJ_DIR)/%.o: ../../${TESTS_DIR}/%.c
	@mkdir -p \$(@D)
	\$(TEST_CC) -c $< \$(TEST_C_FLAGS_DEF) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"




# Include all .d files
-include \$(DEPS)

.PHONY: clean

clean:
	rm -rf \$(OBJ_DIR)

clean_test:
	rm -rf \$(TEST_OBJ_DIR)

EOM
)

echo "$TEMP" > makefile 







