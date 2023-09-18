CC = "arm-none-eabi-gcc"
CXX = "arm-none-eabi-g++"
OBJCOPY = "arm-none-eabi-objcopy"
TEST_CC = "gcc"
TEST_CXX = "g++"

EXCEPTIONS_FLAG = "-fexceptions"
SPECS = "nano.specs"
RTTI = "-fno-rtti"
OPT_DBG_FLAGS = "-g3 -O0"
C_STDR = "gnu11"
CXX_STDR = "gnu++20"
TEST_CXX_STDR = "c++20"
TEST_C_STDR = "gnu11"
FF_SECTIONS = "-ffunction-sections"
FNO_CXA_ATEXIT = "-fno-use-cxa-atexit"
FDATA_SECTIONS = "-fdata-sections"
TEST_C_FLAGS = f"-std={TEST_C_STDR} -g3 -O0 -Wall"
TEST_CXX_FLAGS = f"-std={TEST_CXX_STDR} -g3 -O0 -Wall"


MCU_SRC_DIR_DEFAULT = "Src"
CORE_DIR = "Core"
STARTUP_DIR = "Startup"
TESTS_DIR = "Tests"
BUILD_DIR = "Build"
LINKER_DIR = STARTUP_DIR
STARTUP_SCRIPT_DIR = STARTUP_DIR
DRIVERS_DIR = "Drivers"
UTILS_DIR = "Utils"
INC_DIR = "Include"
COMMON_DIR = "Common"

