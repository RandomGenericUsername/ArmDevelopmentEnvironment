from core_data_builder import CoreData, CoreDataMembers, CoreDataMembersDict
from enum import Enum
from typing import Dict, Union, Optional, Callable, TypedDict, List
from utils import (
    TypedProperty,
    architecture_validator,
    fpu_v_validator,
    fpu_validator,
    truthy_falsy_validator,
    script_url_validator,
)


class MCU:

    mcu = TypedProperty(data_type=str)
    core_data = TypedProperty(data_type=List[CoreData])
    mount_on_ram = TypedProperty(data_type=object)
    base_url = TypedProperty(data_type=str)
    supports_mount_on_ram = TypedProperty(data_type=object)
    startup_file_per_core = TypedProperty(data_type=object)
    linker_file_per_core = TypedProperty(data_type=object)
    _instances = {}  # Class-level dictionary to store instances

    def __new__(
        cls,
        base_url: str,
        mcu: str,
        core_data: list[CoreData],
        *,
        options: Optional[Union[Dict,None]] = None,
    ):
        # If an instance with the given mcu name already exists, return that instance
        if mcu in cls._instances:
            instance = cls._instances[mcu]
        else:
            # Otherwise, create a new instance and store it in the dictionary
            instance = super(MCU, cls).__new__(cls)
            cls._instances[mcu] = instance
            instance.mcu = mcu  # Initialize the mcu attribute here
        return instance

    def __init__(
        self,
        base_url:str, 
        mcu: str,
        core_data: list[CoreData],
        *,
        options: Optional[Union[Dict,None]] = None,
    ):
        if not options:
            options = {}
        #self.mcu = TypedProperty(data_type=str, value=mcu).value #set at the __new__ level
        self.core_data = core_data
        self.mount_on_ram = options.get('mount_on_ram', False)
        self.base_url = base_url 
        self.supports_mount_on_ram = options.get('supports_mount_on_ram', False)
        self.startup_file_per_core = options.get('startup_file_per_core', False)
        self.linker_file_per_core = options.get('linker_file_per_core', False)
        self.update_core_data()

    
    def update_core_data(self):
        cd : CoreDataMembersDict ={
            "base_url": self.base_url,
            "mcu" : self.mcu,
            "supports_mount_on_ram" : self.supports_mount_on_ram,
            "mount_on_ram" : self.mount_on_ram,
            "linker_file_per_core" : self.linker_file_per_core,
            "startup_file_per_core" : self.startup_file_per_core,
        }
        for core_data in self.core_data:
            core_data.update(options=cd)

    def serialize_core_data(self):
        return [core_data.to_dict() for core_data in self.core_data]

    def to_dict(self):
        """Convert the CoreData object to a dictionary."""
        return {
            key: value.value if isinstance(value, TypedProperty) else (self.serialize_core_data() if isinstance(value, List) else value) 
            for key, value in self.__dict__.items()
            if not key.startswith("_")
        }

c1 = CoreData(
    architecture="cortex-m7",
    fpu="hard",
    fpu_v="fpv5-sp-d16",
)
#
c2 = CoreData(
    architecture="cortex-m4",
    fpu="hard",
    fpu_v="fpv4-sp-d16",
)

base_url = "https://github.com/STMicroelectronics"
smt32h755xx = MCU(
    base_url=base_url,
    mcu="stm32h755xx",
    core_data=[c1, c2],
    options={
        "supports_mount_on_ram":True,
        "dedicated_linker_file":True,
        #"mount_on_ram":True,
    }
)

print(smt32h755xx.to_dict())
