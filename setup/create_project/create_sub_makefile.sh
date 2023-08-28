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

BUILD_PATH_SUFFIX="_${SRC_PATH}"
SRC_BUILD_PATH="/${SRC_PATH}"
#if only one core, change mx to Src
if [[ ${#MCU_SRC_DIRS[@]} -eq 1 ]]; then
    SRC_PATH=$MCU_SRC_DIR_DEFAULT
    BUILD_PATH_SUFFIX=""
    SRC_BUILD_PATH=""
fi

EXCLUDED_DIRS=""
TEST_EXCLUDED_DIRS=""
for dir in "${MCU_SRC_DIRS[@]}"; do
	if [[ "${#MCU_SRC_DIRS[@]}" -eq 1 ]]; then
		dir=${MCU_SRC_DIR_DEFAULT}
	fi
    if [ "$dir" != "$SRC_PATH" -a "${#MCU_SRC_DIRS[@]}" -gt 1 ]; then
        EXCLUDED_DIRS+=" -not -path \"../../${CORE_DIR}/${dir}/*\""
    fi
    TEST_EXCLUDED_DIRS+=" -not -path \"../../${CORE_DIR}/${dir}/*\""
done

if [[ ${#MCU_SRC_DIRS[@]} -eq 1 ]]; then
    TESTS_EXCLUDED_DIRS=$MCU_SRC_DIR_DEFAULT
else 
    TESTS_EXCLUDED_DIRS=${MCU_SRC_DIRS[@]}
fi

TEST_EXCLUDED_FILES_STR=""
for file in "${TEST_EXCLUDED_FILES[@]}"; do
    TEST_EXCLUDED_FILES_STR+=" -not -name \"${file}\""
done

board_or_target_data=${IS_BOARD_OR_TARGET["${MCU_FAMILY}"]}
words=($board_or_target_data)
board_or_target="${words[0]}"
board_or_target_value="${words[1]}"

INTERFACE="stlink"

CORE_REL_PATH="../../${CORE_DIR}"
STARTUP_REL_PATH="../../${STARTUP_DIR}"
TESTS_REL_PATH="../../${TESTS_DIR}"
BUILD_PATH="../../${BUILD_DIR}"
TEST_BUILD_PATH="${BUILD_PATH}/${TESTS_DIR}"
STARTUP_SCRIPT_PATH=${STARTUP_REL_PATH}/$STARTUP_SCRIPT
LINKER_SCRIPT_PATH=${STARTUP_REL_PATH}/$LINKER_SCRIPT
OBJ_DIR=${BUILD_PATH}${SRC_BUILD_PATH}
TEST_OBJ_DIR=${BUILD_PATH}/${TESTS_DIR}${SRC_BUILD_PATH}
TARGET=${BUILD_PATH}/${PROJECT_NAME}${BUILD_PATH_SUFFIX}.elf
TEST_TARGET=${TEST_BUILD_PATH}/${PROJECT_NAME}${BUILD_PATH_SUFFIX}.elf

# Define include directories
INC_DIRS="\$(shell find ${CORE_REL_PATH} -type d -name .svn -prune -o -type d -print)"
INC_FLAGS="\$(addprefix -I, \$(INC_DIRS))"
COMMON_FLAGS="-mthumb -mcpu=${MPU_ARCH} -mfpu=${FPU_V} -mfloat-abi=${FPU} ${NANO_SPECS}"
COMPILATION_COMMON_FLAGS="${INC_FLAGS} ${COMMON_FLAGS} ${OPT_DBG_FLAGS} ${FF_SECTIONS} ${FDATA_SECTIONS} ${EXCEPTIONS_FLAG} -Wall -fstack-usage"
C_FLAGS_DEF="${COMPILATION_COMMON_FLAGS}"
CXX_FLAGS_DEF="${COMPILATION_COMMON_FLAGS} ${RTTI} ${FNO_CXA_ATEXIT}"
LINKER_FLAGS="-Wl,-Map=\$(TARGET:.elf=.map),--cref ${COMMON_FLAGS} -Wl,--start-group -lc -lm -lstdc++ -lsupc++ -Wl,--end-group -Wl,--print-memory-usage"
TEST_C_FLAGS_DEF="${TEST_C_FLAGS} ${INC_FLAGS}"
TEST_CXX_FLAGS_DEF="${TEST_CXX_FLAGS} ${INC_FLAGS}"

ASM_SOURCE_CORE="${STARTUP_SCRIPT_PATH}"
CXX_SOURCES_CORE="\$(shell find ${CORE_REL_PATH} -name '*.cpp' ${EXCLUDED_DIRS})"
C_SOURCES_CORE="\$(shell find ${CORE_REL_PATH} -name '*.c' ${EXCLUDED_DIRS})"
TEST_CXX_SOURCES_CORE="\$(shell find ${TESTS_REL_PATH} -name '*.cpp') \$(shell find ${CORE_REL_PATH} -name '*.cpp' ${TEST_EXCLUDED_DIRS} ${TEST_EXCLUDED_FILES_STR})"
TEST_C_SOURCES_CORE="\$(shell find ${TESTS_REL_PATH} -name '*.c') \$(shell find ${CORE_REL_PATH} -name '*.c' ${TEST_EXCLUDED_DIRS} ${TEST_EXCLUDED_FILES_STR})"

ASM_OBJECTS="\$(STARTUP_SCRIPT_PATH:\${STARTUP_REL_PATH}/%.s=\$(OBJ_DIR)/${STARTUP_DIR}/%.o)"
CXX_OBJECTS="\$(CXX_SOURCES_CORE:\${CORE_REL_PATH}/%.cpp=\$(OBJ_DIR)/%.o)"
C_OBJECTS="\$(C_SOURCES_CORE:\${CORE_REL_PATH}/%.c=\$(OBJ_DIR)/%.o)"
TEST_CXX_OBJ="\$(TEST_CXX_SOURCES_CORE:../../%.cpp=${TEST_OBJ_DIR}/%.o)"
TEST_C_OBJ="\$(TEST_C_SOURCES_CORE:../../%.c=${TEST_OBJ_DIR}/%.o)"

DEPS="\$(CXX_OBJECTS:.o=.d) \$(C_OBJECTS:.o=.d) \$(ASM_OBJECTS:.o=.d)"

TEMP=$(cat << EOM

CC := ${CC}
CXX := ${CXX}
TEST_CC := ${TEST_CC}
TEST_CXX := ${TEST_CXX}

INTERFACE := ${INTERFACE}
BUILD_PATH := ${BUILD_PATH}
TARGET := ${TARGET}
TEST_BUILD_PATH := ${TEST_BUILD_PATH}
TEST_TARGET := ${TEST_TARGET}
CORE_REL_PATH := ${CORE_REL_PATH}
STARTUP_REL_PATH := ${STARTUP_REL_PATH}

# Define include directories
INC_DIRS := ${INC_DIRS}
INC_FLAGS := ${INC_FLAGS}
C_FLAGS_DEF := ${C_FLAGS_DEF}
CXX_FLAGS_DEF := ${CXX_FLAGS_DEF}
TEST_C_FLAGS_DEF := ${TEST_C_FLAGS_DEF}
TEST_CXX_FLAGS_DEF := ${TEST_CXX_FLAGS_DEF}
LINKER_FLAGS := ${LINKER_FLAGS}

CXX_SOURCES_CORE := ${CXX_SOURCES_CORE}
C_SOURCES_CORE := ${C_SOURCES_CORE}
TEST_CXX_SOURCES_CORE := ${TEST_CXX_SOURCES_CORE}
TEST_C_SOURCES_CORE := ${TEST_C_SOURCES_CORE}
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

-include \$(DEPS)

all: clean build_project

build_project: \$(TARGET)

flash: all
	openocd -f interface/${INTERFACE}.cfg -f $board_or_target/$board_or_target_value.cfg -c "program \$(TARGET) verify reset exit"

build_test: clean_test \$(TEST_TARGET)

run_test: build_test
	@./\$(TEST_TARGET)

\$(TARGET): \$(CXX_OBJECTS) \$(C_OBJECTS) \$(ASM_OBJECTS)
	\$(CXX) -T \$(LINKER_SCRIPT_PATH) $^ -o \$@ \$(LINKER_FLAGS)
	@echo 'Finished building target: \$@'
	@echo ' '

\$(TEST_TARGET): \$(TEST_CXX_OBJECTS) \$(TEST_C_OBJECTS)
	\$(TEST_CXX) $^ -o \$@
	@echo 'Finished building test target: \$@'
	@echo ' '

\$(OBJ_DIR)/%.o: ${CORE_REL_PATH}/%.cpp
	@mkdir -p \$(dir \$@)
	\$(CXX) -std=gnu++20 -c $< \$(CXX_FLAGS_DEF) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

\$(OBJ_DIR)/%.o: ${CORE_REL_PATH}/%.c
	@mkdir -p \$(dir \$@)
	\$(CC) -c -std=gnu11 $< \$(C_FLAGS_DEF) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

\$(OBJ_DIR)/Startup/%.o: ${STARTUP_REL_PATH}/%.s
	@mkdir -p \$(dir \$@)
	\$(CC) -c $< -o \$@

\$(TEST_OBJ_DIR)/%.o: ${TESTS_REL_PATH}/%.cpp
	@mkdir -p \$(dir \$@)
	\$(TEST_CXX) -c $< \$(TEST_CXX_FLAGS_DEF) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

\$(TEST_OBJ_DIR)/%.o: ${TESTS_REL_PATH}/%.c
	@mkdir -p \$(dir \$@)
	\$(TEST_CC) -c $< \$(TEST_C_FLAGS_DEF) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

\$(TEST_OBJ_DIR)/%.o: ${CORE_REL_PATH}/%.cpp
	@mkdir -p \$(dir \$@)
	\$(TEST_CXX) -c $< \$(TEST_CXX_FLAGS_DEF) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

\$(TEST_OBJ_DIR)/%.o: ${CORE_REL_PATH}/%.c
	@mkdir -p \$(dir \$@)
	\$(TEST_CC) -c $< \$(TEST_C_FLAGS_DEF) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

.PHONY: clean clean_test

clean:
	rm -rf \$(OBJ_DIR)

clean_test:
	rm -rf \$(TEST_OBJ_DIR)

EOM
)

echo "$TEMP" > makefile
