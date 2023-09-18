from mcu_builder import CoreData
from mcu_builder import MCU 
from utils import convert_to_raw_url

#Definitions for stm32h755xx mcu

stm32h755xx_m4 = CoreData(
    mcu_name="stm32h755xx",
    architecture="cortex-m4",
    fpu="hard",
    fpu_v="fpv4-sp-d16",
)
stm32h755xx_m7 = CoreData(
    mcu_name="stm32h755xx",
    architecture="cortex-m7",
    fpu="hard",
    fpu_v="fpv5-sp-d16",
)
stm32h755xx = MCU(mcu="stm32h755xx", core_data=[stm32h755xx_m4, stm32h755xx_m7])
print(stm32h755xx.to_json())

#End of definitions for stm32h755xx mcu
#https://raw.githubusercontent.com/STMicroelectronics/cmsis_device_h7/master/Source/Templates/gcc/startup_stm32h755xx.s

#Definitions for stm32wl55xx mcu

stm32wl55xx_m4 = CoreData(
    mcu_name="stm32wl55xx",
    architecture="cortex-m4",
    fpu="hard",
    fpu_v="fpv4-sp-d16",
)
stm32wl55xx_m0plus  = CoreData(
    mcu_name="stm32wl55xx",
    architecture="cortex-m0plus",
)
stm32wl55xx = MCU(
    mcu="stm32wl55xx",
    core_data=[stm32wl55xx_m4, stm32wl55xx_m0plus],
    dedicated_startup_file_per_core = True
)

print(stm32wl55xx.to_json())
#End of definitions for stm32wl55xx mcu


#Definitions for stm32f411xe mcu
stm32f411xe_m4 = CoreData(
    mcu_name="stm32f411xe",
    architecture="cortex-m4",
    fpu="hard",
    fpu_v="fpv4-sp-d16",
)
stm32f411xe = MCU(
    mcu="stm32f411xe",
    core_data=[stm32f411xe_m4]
)
print(stm32f411xe.to_json())
#End of definitions for stm32f411xe mcu
