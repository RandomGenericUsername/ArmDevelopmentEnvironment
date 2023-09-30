from url_generator import UrlGeneratorHandler, FileTypes
from abc import ABC, abstractmethod
from enum import Enum
from typing import Dict, Union, Optional, Callable, TypedDict
import json

from utils import (
    TypedProperty,
    architecture_validator,
    fpu_v_validator,
    fpu_validator,
    truthy_falsy_validator,
    script_url_validator
)
from enum import Enum

class CoreDataMembersDict(TypedDict):
    mcu : str
    architecture : str 
    fpu : str 
    fpu_v : str 
    base_url : str 
    supports_mount_on_ram : bool 
    startup_file_per_core : bool 
    linker_file_per_core : bool 
    mount_on_ram : bool 

class CoreDataMembers():
    mcu = "mcu"
    architecture = "architecture"
    fpu = "fpu"
    fpu_v = "fpu_v"
    base_url = "base_url"
    supports_mount_on_ram = "supports_mount_on_ram"
    startup_file_per_core = "startup_file_per_core"
    linker_file_per_core = "linker_file_per_core"
    mount_on_ram = "mount_on_ram"


class CoreData:

    mcu = TypedProperty(data_type=str)
    architecture = TypedProperty(data_type=str)
    fpu = TypedProperty(data_type=str)
    fpu_v = TypedProperty(data_type=str)
    base_url = TypedProperty(data_type=str)
    supports_mount_on_ram = TypedProperty(data_type=object)
    startup_file_per_core = TypedProperty(data_type=object)
    linker_file_per_core = TypedProperty(data_type=object)
    mount_on_ram = TypedProperty(data_type=object)
    startup_script_url = TypedProperty(data_type=str)
    linker_script_url = TypedProperty(data_type=Union[Dict, str])

    def __init__(
        self,
        mcu: Optional[str]="",
        architecture: Optional[str]="",
        fpu: Optional[str]="",
        fpu_v: Optional[str]="",
        base_url: Optional[str]="",
        supports_mount_on_ram: Optional[bool] = False,
        startup_file_per_core: Optional[bool] = False,
        linker_file_per_core: Optional[bool] = False,
        mount_on_ram: Optional[bool] = False,
    ):
        self.mcu = mcu 
        self.architecture = architecture
        self.fpu = fpu 
        self.fpu_v = fpu_v 
        self.base_url = base_url 
        self.supports_mount_on_ram = supports_mount_on_ram 
        self.startup_file_per_core = startup_file_per_core 
        self.linker_file_per_core = linker_file_per_core 
        self.mount_on_ram = mount_on_ram 
        
    @property
    def startup_script_url(self):
        return self.get_startup_script_url() 

    @property
    def linker_script_url(self):
        return self.get_linker_script_url() 
        
    def get_linker_script_url(self)->[str]:
        key = "flash" if not self.mount_on_ram else "sram"
        handler = self.generate_linker_script_urls_handler().get(key)
        return handler()

    def get_startup_script_url(self)->str:
        handler = self.generate_startup_script_url_handler()
        return handler()

    def generate_startup_script_url_handler(self)->UrlGeneratorHandler:
        options = {"dedicated_per_core" : self.startup_file_per_core}
        return UrlGeneratorHandler(base_url=self.base_url, mcu=self.mcu, arch=self.architecture, file_type=FileTypes.startup_script.value, options=options)

    def generate_linker_script_urls_handler(self)->[dict[str,UrlGeneratorHandler]]:
        supports_mount_on = ["flash"]
        options = {"dedicated_per_core": self.linker_file_per_core}

        if self.supports_mount_on_ram:
            supports_mount_on.append("sram")
            options.update({"mount_on_ram": self.mount_on_ram})

        url_generators = {} 
        for mount in supports_mount_on:
            url = UrlGeneratorHandler(
                base_url=self.base_url,
                mcu=self.mcu,
                arch=self.architecture,
                file_type=FileTypes.linker_script.value,
                options=options,
            )
            url_generators.update({mount: url})
        return url_generators 

    def to_dict(self):
        """Convert the CoreData object to a dictionary."""
        return {
            key: value.value if isinstance(value, TypedProperty) else value 
            for key, value in self.__dict__.items()
            if not key.startswith("_")
        }

    def update(self, options: CoreDataMembersDict):
        for k,v in options.items():
            if hasattr(self, k):
                setattr(self, k,v)


#base_url = "https://github.com/STMicroelectronics"
#c1 = CoreData(
#    mcu="stm32h755xx",
#    architecture="cortex-m7",
#    fpu="hard",
#    fpu_v="fpv5-sp-d16",
#    base_url=base_url,
#    supports_mount_on_ram="false",
#    startup_file_per_core="false",
#    linker_file_per_core="true",
#    mount_on_ram="true",
#)
#print(c1)
