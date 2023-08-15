# Define cross-compiler
CC      := arm-none-eabi-gcc
CXX     := arm-none-eabi-g++
TEST_CXX := g++

# Define the source and object file directories
CORE_DIR := Core
STARTUP_DIR := Startup
OBJ_DIR := Debug
LINKER := stm32_ls.ld
INC_DIR := Include
TEST_DIR := Tests
UTILS_DIR := Utils
DRIVERS_DIR := Drivers

PROJECT_NAME := $(shell basename "$(shell pwd)")
LINKER_PATH := $(shell pwd)/${STARTUP_DIR}/${LINKER}
TARGET := ${OBJ_DIR}/${PROJECT_NAME}.elf
TEST_TARGET := ${TEST_DIR}/${PROJECT_NAME}.elf
TEST_OBJ_DIR := ${TEST_DIR}/${OBJ_DIR}

# Define include directories
INC_DIRS += $(shell find ${CORE_DIR} -type d)
INC_FLAGS := $(addprefix -I, $(INC_DIRS))

# Define the flags
EXCEPTIONS_FLAG := -fexceptions
NANO_SPECS := --specs=nano.specs
RTTI := -fno-rtti
OPT_DBG_FLAGS := -g3 -O0
C_STDR := -std=gnu11
CXX_STDR := -std=gnu++20
CFLAGS  := -mcpu=cortex-m4 $(C_STDR) -c ${OPT_DBG_FLAGS} ${NANO_SPECS} -ffunction-sections -fdata-sections ${EXCEPTIONS_FLAG} -Wall -fstack-usage -MMD -MP  -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb $(INC_FLAGS)
CXXFLAGS:= -mcpu=cortex-m4 $(CXX_STDR) -c ${OPT_DBG_FLAGS} ${NANO_SPECS} -ffunction-sections -fdata-sections ${EXCEPTIONS_FLAG} -Wall -fstack-usage -MMD -MP  -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb $(INC_FLAGS) $(RTTI) -fno-use-cxa-atexit
TEST_CXXFLAGS := -std=c++20 -g3 -O0 -Wall $(INC_FLAGS)


# Automatically gather all source files and determine the object and dependency file paths
CPP_SOURCES_CORE := $(shell find $(CORE_DIR) -name '*.cpp' -not -path "$(TEST_DIR)/*")
C_SOURCES_CORE   := $(shell find $(CORE_DIR) -name '*.c' -not -path "$(TEST_DIR)/*")
ASM_SOURCES_STARTUP := $(shell find $(STARTUP_DIR) -name '*.s')
CPP_OBJECTS := $(CPP_SOURCES_CORE:$(CORE_DIR)/%.cpp=$(OBJ_DIR)/%.o)
C_OBJECTS   := $(C_SOURCES_CORE:$(CORE_DIR)/%.c=$(OBJ_DIR)/%.o)
ASM_OBJECTS := $(ASM_SOURCES_STARTUP:%.s=$(OBJ_DIR)/%.o)
DEPS        := $(CPP_OBJECTS:.o=.d) $(C_OBJECTS:.o=.d) $(ASM_OBJECTS:.o=.d)
MACROS := COMPILE

# Gather all source files from Core excluding Src
TEST_CPP_SOURCES := $(shell find $(CORE_DIR) -name '*.cpp' -not -path "$(CORE_DIR)/Src/*") $(shell find $(TEST_DIR) -name '*.cpp')

# Determine the object file paths for the test build
TEST_CPP_OBJECTS := $(TEST_CPP_SOURCES:%.cpp=$(TEST_OBJ_DIR)/%.o)



all: clean build

build: $(TARGET)

build_test: clean_test $(TEST_TARGET)

flash: all
	openocd -f interface/stlink.cfg -f board/st_nucleo_f4.cfg -c "program ./${OBJ_DIR}/${PROJECT_NAME}.elf verify reset exit"

run_test: build_test 
	@./$(TEST_TARGET)

debug_test: run_test 
	@gdb ./$(TEST_TARGET)



$(TARGET): $(CPP_OBJECTS) $(C_OBJECTS) $(ASM_OBJECTS) 
	$(CXX) -T $(LINKER_PATH) $^ -o $@ -Wl,-Map=$(TARGET:.elf=.map),--cref -D$(MACROS) -mcpu=cortex-m4 ${NANO_SPECS} -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -Wl,--start-group -lc -lm -lstdc++ -lsupc++ -Wl,--end-group -Wl,--print-memory-usage
	@echo 'Finished building target: $@'
	@echo ' '

$(TEST_TARGET): $(TEST_CPP_OBJECTS) 
	$(TEST_CXX) $^ -o $@ 
	@echo 'Finished building test target: $@'
	@echo ' '

# Rule to make the object files
$(OBJ_DIR)/%.o: $(CORE_DIR)/%.cpp
	@mkdir -p $(@D)
	$(CXX) $< $(CXXFLAGS) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@"

$(OBJ_DIR)/%.o: $(CORE_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $< $(CFLAGS) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@"

$(OBJ_DIR)/${STARTUP_DIR}/%.o: $(STARTUP_DIR)/%.s
	@mkdir -p $(@D)
	$(CC) -c $< -o $@

$(TEST_OBJ_DIR)/$(CORE_DIR)/%.o: $(CORE_DIR)/%.cpp
	@mkdir -p $(@D)
	$(TEST_CXX) -c $< $(TEST_CXXFLAGS) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@"

$(TEST_OBJ_DIR)/$(TEST_DIR)/%.o: $(TEST_DIR)/%.cpp
	@mkdir -p $(@D)
	$(TEST_CXX) -c $< $(TEST_CXXFLAGS) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@"





# Include all .d files
-include $(DEPS)

.PHONY: clean

clean:
	rm -rf $(OBJ_DIR)

clean_test:
	rm -rf $(TEST_OBJ_DIR)