#!/bin/bash

# Default values for the variables
STARTUP="stm32_startup.s"
OBJ_DIR="Build"
LINKER="stm32_ls.ld"
INTERFACE="stlink"
BOARD="st_nucleo_f4"
MCU_ARCH="cortex-m4"
FPU_V="fpv4-sp-d16"
FPU="hard"
PROJECT_NAME="project"
N_CORES="single"
TEST_EXCLUDE_DIR=()
EXCLUDE_DIR=""

# Parse command-line options
while getopts s:o:l:i:b:a:v:p:n:c:e:t: option
do
    case "${option}" in
        s) STARTUP=${OPTARG};;
        o) OBJ_DIR=${OPTARG};;
        l) LINKER=${OPTARG};;
        i) INTERFACE=${OPTARG};;
        b) BOARD=${OPTARG};;
        a) MCU_ARCH=${OPTARG};;
        v) FPU_V=${OPTARG};;
        p) FPU=${OPTARG};;
        n) PROJECT_NAME=${OPTARG};;
        c) N_CORES=${OPTARG};;
        e) EXCLUDE_DIR=${OPTARG};;
        t) IFS=',' read -ra ADDR <<< "${OPTARG}"
           for dir in "${ADDR[@]}"; do
               TEST_EXCLUDE_DIRS+=("$dir")
           done
           ;;
    esac
done

# Adjust paths based on N_CORES value
if [ "$N_CORES" == "dual" ]; then
    PREFIX="../"
    POSTFIX="-${MCU_ARCH}"
else
    PREFIX=""
    POSTFIX=""
fi

# Common Makefile content
COMMON_CONTENT=$(cat <<- EOM
# Define cross-compiler
CC      := arm-none-eabi-gcc
CXX     := arm-none-eabi-g++
TEST_CXX := g++
EXCEPTIONS_FLAG := -fexceptions
SPECS := nano.specs
RTTI := -fno-rtti
OPT_DBG_FLAGS := -g3 -O0
C_STDR := gnu11
CXX_STDR := gnu++20

MCU_ARCH := ${MCU_ARCH}
FPU_V := ${FPU_V}
FPU := ${FPU}

# Define the source and object file directories
CORE_DIR := ${PREFIX}Core
INC_DIR := ${PREFIX}Include
TEST_DIR := ${PREFIX}Tests
UTILS_DIR := ${PREFIX}Utils
DRIVERS_DIR := ${PREFIX}Drivers
STARTUP_DIR := ${PREFIX}Startup
OBJ_DIR := ${OBJ_DIR}
LINKER := ${LINKER}
STARTUP := ${STARTUP}
INTERFACE := ${INTERFACE}
BOARD := ${BOARD}

PROJECT_NAME := ${PROJECT_NAME}
LINKER_PATH := \$(shell pwd)/\${STARTUP_DIR}/${LINKER}
TARGET_NAME := ${PROJECT_NAME}${POSTFIX}.elf
TARGET := \${OBJ_DIR}/\${TARGET_NAME}
TEST_TARGET := \${TEST_DIR}/\${PROJECT_NAME}.elf
TEST_OBJ_DIR := \${TEST_DIR}/\${OBJ_DIR}

# Define include directories
INC_DIRS += \$(shell find \${CORE_DIR} -type d)
INC_FLAGS := \$(addprefix -I, \$(INC_DIRS))

# Define the flags
COMMON_FLAGS:= -mcpu=\$(MCU_ARCH) --specs=\$(SPECS) -mfpu=\$(FPU_V) -mfloat-abi=\$(FPU) -mthumb
COMPILE_COMMON_FLAGS := \$(COMMON_FLAGS) \$(OPT_DBG_FLAGS) -ffunction-sections -fdata-sections \$(EXCEPTIONS_FLAG) -Wall -fstack-usage -MMD -MP 
CFLAGS  := -std=\$(C_STDR) -c \$(COMPILE_COMMON_FLAGS)  \$(INC_FLAGS)
CXXFLAGS:= -std=\$(CXX_STDR) -c \$(COMPILE_COMMON_FLAGS)  \$(INC_FLAGS) \$(RTTI) -fno-use-cxa-atexit
TEST_CXXFLAGS := -std=c++20 -g3 -O0 -Wall \$(INC_FLAGS)

EOM
)

# Check if EXCLUDE_DIRS is empty or not
if [ ${#TEST_EXCLUDE_DIRS[@]} -eq 0 ]; then
    # If EXCLUDE_DIRS is empty
    TEST_SOURCE_GATHERING=$(cat <<- EOM

# Adjust the source gathering
TEST_CPP_SOURCES := \$(shell find \$(CORE_DIR) -name '*.cpp' \$(shell find \$(TEST_DIR) -name '*.cpp'))

EOM
)
else
    # If EXCLUDE_DIRS is not empty
    EXCLUDE_PATTERNS=""
    for dir in "${TEST_EXCLUDE_DIRS[@]}"; do
        EXCLUDE_PATTERNS+=" -not -path \"${PREFIX}Core/$dir/*\""
    done
    TEST_SOURCE_GATHERING=$(cat <<- EOM

# Adjust the source gathering to exclude ${EXCLUDE_DIRS[@]}
TEST_CPP_SOURCES := \$(shell find \$(CORE_DIR) -name '*.cpp' $EXCLUDE_PATTERNS \$(shell find \$(TEST_DIR) -name '*.cpp'))

EOM
)
fi

# Check if EXCLUDE_DIR is empty or not
if [ -z "$EXCLUDE_DIR" ]; then
    # If EXCLUDE_DIR is empty
    SOURCE_GATHERING=$(cat <<- EOM

# Adjust the source gathering
CPP_SOURCES_CORE := \$(shell find \$(CORE_DIR) -name '*.cpp'  -not -path "\$(TEST_DIR)/*")
C_SOURCES_CORE   := \$(shell find \$(CORE_DIR) -name '*.c'  -not -path "\$(TEST_DIR)/*")

EOM
)
else
    # If EXCLUDE_DIR is not empty
    SOURCE_GATHERING=$(cat <<- EOM

# Adjust the source gathering to exclude ${EXCLUDE_DIR}
CPP_SOURCES_CORE := \$(shell find \$(CORE_DIR) -name '*.cpp' -not -path "$PREFIX${EXCLUDE_DIR}/*" -not -path "\$(TEST_DIR)/*")
C_SOURCES_CORE   := \$(shell find \$(CORE_DIR) -name '*.c' -not -path "$PREFIX${EXCLUDE_DIR}/*" -not -path "\$(TEST_DIR)/*")

EOM
)
fi

REST_CONTENT=$(cat <<-EOM

ASM_SOURCES_STARTUP := \$(shell find \$(STARTUP_DIR) -name '\$(STARTUP)')
CPP_OBJECTS := \$(CPP_SOURCES_CORE:\$(CORE_DIR)/%.cpp=\$(OBJ_DIR)/%.o)
C_OBJECTS   := \$(C_SOURCES_CORE:\$(CORE_DIR)/%.c=\$(OBJ_DIR)/%.o)
ASM_OBJECTS := \$(ASM_SOURCES_STARTUP:%.s=\$(OBJ_DIR)/%.o)
DEPS        := \$(CPP_OBJECTS:.o=.d) \$(C_OBJECTS:.o=.d) \$(ASM_OBJECTS:.o=.d)

# Determine the object file paths for the test build
TEST_CPP_OBJECTS := \$(TEST_CPP_SOURCES:%.cpp=\$(TEST_OBJ_DIR)/%.o)

all: clean build

build: \$(TARGET)

build_test: clean_test \$(TEST_TARGET)

flash: all
    openocd -f interface/\${INTERFACE}.cfg -f board/\${BOARD}.cfg -c "program ./\${OBJ_DIR}/\${TARGET_NAME}.elf verify reset exit"

run_test: build_test 
    @./\$(TEST_TARGET)

\$(TARGET): \$(CPP_OBJECTS) \$(C_OBJECTS) \$(ASM_OBJECTS) 
    \$(CXX) -T \$(LINKER_PATH) \$^ -o \$@ -Wl,-Map=\$(TARGET:.elf=.map),--cref \$(COMMON_FLAGS) -Wl,--start-group -lc -lm -lstdc++ -lsupc++ -Wl,--end-group -Wl,--print-memory-usage
    @echo 'Finished building target: \$@'
    @echo ' '

\$(TEST_TARGET): \$(TEST_CPP_OBJECTS) 
    \$(TEST_CXX) \$^ -o \$@ 
    @echo 'Finished building test target: \$@'
    @echo ' '

# Rule to make the object files
\$(OBJ_DIR)/%.o: \$(CORE_DIR)/%.cpp
    @mkdir -p \$(@D)
    \$(CXX) \$< \$(CXXFLAGS) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

\$(OBJ_DIR)/%.o: \$(CORE_DIR)/%.c
    @mkdir -p \$(@D)
    \$(CC) \$< \$(CFLAGS) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

\$(OBJ_DIR)/\${STARTUP_DIR}/%.o: \$(STARTUP_DIR)/%.s
    @mkdir -p \$(@D)
    \$(CC) -c \$< -o \$@

\$(TEST_OBJ_DIR)/\$(CORE_DIR)/%.o: \$(CORE_DIR)/%.cpp
    @mkdir -p \$(@D)
    \$(TEST_CXX) -c \$< \$(TEST_CXXFLAGS) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"

\$(TEST_OBJ_DIR)/\$(TEST_DIR)/%.o: \$(TEST_DIR)/%.cpp
    @mkdir -p \$(@D)
    \$(TEST_CXX) -c \$< \$(TEST_CXXFLAGS) -MMD -MP -MF"\$(@:%.o=%.d)" -MT"\$@" -o "\$@"


# Include all .d files
-include \$(DEPS)

.PHONY: clean

clean:
    rm -rf \$(OBJ_DIR)

clean_test:
    rm -rf \$(TEST_OBJ_DIR)
EOM
)
# Combine COMMON_CONTENT and SOURCE_GATHERING
FINAL_CONTENT="$COMMON_CONTENT$SOURCE_GATHERING$TEST_SOURCE_GATHERING$REST_CONTENT"

# Write to somefile
echo "$FINAL_CONTENT" > temp 
