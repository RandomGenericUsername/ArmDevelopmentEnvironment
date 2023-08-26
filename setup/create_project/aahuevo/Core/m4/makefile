
#
CC := arm-none-eabi-gcc 
CXX := arm-none-eabi-g++ 
TEST_CC := gcc 
TEST_CXX := g++

INTERFACE := stlink
BUILD_PATH := ../../Build
TARGET := ../../Build/m4/aahuevo.elf
TEST_BUILD_PATH := ../../Build/Tests/m4
TEST_TARGET := ../../Build/Tests/m4/aahuevo.elf

# Define include directories
INC_DIRS += $(shell find ../ -type d)
INC_FLAGS := $(addprefix -I, $(INC_DIRS))
COMMON_FLAGS_DEF := -mfpu=fpv4-sp-d16 -mfloat-abi=hard ${INC_FLAGS}
C_FLAGS_DEF := -std=gnu11 -c -g3 -O0 --specs=nano.specs -ffunction-sections -fdata-sections -fexceptions -Wall -fstack-usage -MMD -MP -mthumb ${COMMON_FLAGS_DEF}
CXX_FLAGS_DEF := -std=gnu++20 -c -g3 -O0 --specs=nano.specs -ffunction-sections -fdata-sections -fexceptions -Wall -fstack-usage -MMD -MP -mthumb -fno-rtti -fno-use-cxa-atexit ${COMMON_FLAGS_DEF}
TEST_C_FLAGS_DEF := -std=gnu11 -g3 -O0 -Wall ${INC_FLAGS}
TEST_CXX_FLAGS_DEF := -std=c++20 -g3 -O0 -Wall ${INC_FLAGS}

CXX_SOURCES_CORE := $(shell find ../ -name '*.cpp' -not -path "../.../Tests" -not -path "../m7/*")
C_SOURCES_CORE := $(shell find ../ -name '*.c' -not -path "../.../Tests" -not -path "../m7/*")
TEST_CXX_SOURCES_CORE := $(shell find ../ -name '*.cpp'  -not -path "../m4/*" -not -path "../m7/*"  -not -name "sysmem.c" -not -name "syscalls.c") $(shell find "../../Tests" -name '*.cpp')
TEST_C_SOURCES_CORE := $(shell find ../ -name '*.c'  -not -path "../m4/*" -not -path "../m7/*"  -not -name "sysmem.c" -not -name "syscalls.c") $(shell find "../../Tests" -name '*.c')
STARTUP_SCRIPT_PATH := ../../Startup/startup_stm32h755xx.s
LINKER_SCRIPT_PATH := ../../Startup/stm32h755xx_flash_cm4.ld
OBJ_DIR := ../../Build/m4
TEST_OBJ_DIR := ../../Build/Tests/m4
CXX_OBJECTS := $(CXX_SOURCES_CORE:../%.cpp=${OBJ_DIR}/%.o)
C_OBJECTS := $(C_SOURCES_CORE:../%.c=${OBJ_DIR}/%.o)
TEST_CXX_OBJECTS := $(TEST_CXX_SOURCES_CORE:../%.cpp=${TEST_OBJ_DIR}/%.o)
TEST_C_OBJECTS := $(TEST_C_SOURCES_CORE:../%.c=${TEST_OBJ_DIR}/%.o)
ASM_OBJECTS := $(STARTUP_SCRIPT_PATH:../../Startup/%.s=../../Build/m4/Startup/%.o)
DEPS := $(CXX_OBJECTS:.o=.d) $(C_OBJECTS:.o=.d) $(ASM_OBJECTS:.o=.d)

all: clean build_project

build_project: $(TARGET)

flash: all
    openocd -f interface/stlink.cfg -f board/st_nucleo_h754zi.cfg -c "progam ./../../Build/m4/aahuevo.elf verify reset exit" 

build_test: clean_test $(TEST_TARGET)

run_test: build_test
	@./$(TEST_TARGET)


$(TARGET): $(CXX_OBJECTS) $(C_OBJECTS) $(ASM_OBJECTS) 
	$(CXX) -T $(LINKER_PATH) $^ -o $@ -Wl,-Map=$(TARGET:.elf=.map),--cref $(COMMON_FLAGS_DEF) -Wl,--start-group -lc -lm -lstdc++ -lsupc++ -Wl,--end-group -Wl,--print-memory-usage
	@echo 'Finished building target: '
	@echo ' '

$(TEST_TARGET): $(TEST_CXX_OBJECTS) $(TEST_C_OBJECTS)
	$(TEST_CXX) $^ -o $@ 
	@echo 'Finished building test target: '
	@echo ' '



$(OBJ_DIR)/%.o: ../../Core/%.cpp
	@mkdir -p $(@D)
	$(CXX) $< $(CXX_FLAGS_DEF) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@"

$(OBJ_DIR)/%.o: ../../Core/%.c
	@mkdir -p $(@D)
	$(CC) $< $(C_FLAGS_DEF) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@"


$(OBJ_DIR)/Startup/%.o: ../../Startup/startup_stm32h755xx.s
	@mkdir -p $(@D)
	$(CC) -c $< -o $@


$(TEST_OBJ_DIR)/%.o: ../../Core/%.cpp
	@mkdir -p $(@D)
	$(TEST_CXX) -c $< $(TEST_CXX_FLAGS_DEF) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@"

$(TEST_OBJ_DIR)/%.o: ../../Core/%.c
	@mkdir -p $(@D)
	$(TEST_CC) -c $< $(TEST_C_FLAGS_DEF) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@"

$(TEST_OBJ_DIR)/%.o: ../../Tests/%.cpp
	@mkdir -p $(@D)
	$(TEST_CXX) -c $< $(TEST_CXX_FLAGS_DEF) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@"

$(TEST_OBJ_DIR)/%.o: ../../Tests/%.c
	@mkdir -p $(@D)
	$(TEST_CC) -c $< $(TEST_C_FLAGS_DEF) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@"




# Include all .d files
-include $(DEPS)

.PHONY: clean

clean:
	rm -rf $(OBJ_DIR)

clean_test:
	rm -rf $(TEST_OBJ_DIR)
