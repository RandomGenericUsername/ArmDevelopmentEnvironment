from utils import *
import copy
from abc import ABC, abstractmethod
from enum import Enum
from typing import Dict, Union, Optional



base_url = "https://raw.githubusercontent.com/STMicroelectronics"

url_elements_index = ["base_url", "repo", "branch", "path", "filename"]

url_component_modifiers = ["prefix", "sufix", "function"]

exceptions_url = {
    "stm32f411xe" : {"file_name": "sapo" ,"repo" : {"value" : "stm32cubef774"}, "path" : "Projects/STM32F411RE-Nucleo/Templates/SW4STM32"},
    "stm32wl55xx" : {"branch" : {"function":str.upper, "prefix" : "hola"}, "file_name": str.upper}
}

class Consts:
    startup_script = "startup"
    linker_script = "linker"


class Filename:
    def __init__(self, mcu, arch, file_type, dedicated_per_core=False) -> None:
        if not options:
            options = {}
        self.mcu = mcu
        self.arch = arch
        self.file_type = file_type
        self.is_multi_core = dedicated_per_core

    @property
    def family_name(self)->str:
        return self.mcu[5:7]

    @property
    def core_type(self)->str:
        return self.arch.split("-")[1]

    @abstractmethod
    def generate_file_name(self):
        pass

class StartupScriptFilename(Filename):

    def __init__(self, mcu, arch, dedicated_per_core=False, custom_url=None):
        super().__init__(mcu=mcu, arch=arch, filetype=Consts.startup_script, custom_url=custom_url)
        self.dedicated_per_core = dedicated_per_core
        setattr(self.url_parts, "file_name", self.generate_file_name())
        self.apply_custom_url()
        self.url_parts.file_extension = "s"
        

    def generate_file_name(self):
        name = f"startup_{self.mcu}"
        if self.dedicated_per_core:
            name = f"{name}_c{self.core_type}"
        return name


class LinkerScriptFilenameGenerator(Filename):

    def __init__(self, mcu, arch, mount_on_ram = False, dedicated_per_core = False, custom_url = None):
        super().__init__(mcu, arch, Consts.linker_script, custom_url)
        self.mount_on_ram = mount_on_ram
        self.dedicated_per_core = dedicated_per_core
        setattr(self.url_parts, "file_name", self.generate_file_name())
        self.apply_custom_url()
        self.url_parts.file_extension = "ld"
        

    def generate_file_name(self):
        core_type_mapping = {
            "M7": "1",
            "M4": "2",
        }

        # Determine file_type based on conditions
        if self.mount_on_ram:
            file_type = f"sram{core_type_mapping.get(self.core_type.upper(), '')}" if self.dedicated_per_core else "sram"
        else:
            file_type = "flash"

        # Determine suffix based on dedicated_per_core
        suffix = f"_c{self.core_type}" if self.dedicated_per_core else ""

        # Construct and return the file name
        name = f"{self.mcu}_{file_type}{suffix}"
        return name


class UrlParts:
    def __init__(self, mcu_family: str):
        self.base_url = base_url
        self.repo = f"cmsis_device_{mcu_family}"
        self.branch = "master"
        self.path = "Source/Templates/gcc"
        self.file_name = None
        self.file_extension = None

    @property
    def to_dict(self) -> Dict[str, str]:
        """Convert the CoreData object to a dictionary."""
        return {key: value for key, value in self.__dict__.items() if not key.startswith("_")}
    


class UrlGenerator(ABC):

    def __init__(self, mcu: str, arch: str, filetype: str, custom_url: Optional[Dict] = None):
        if custom_url is None:
            custom_url = {}
        self.mcu = mcu
        self.arch = arch
        self.filetype = filetype
        self.url_parts = UrlParts(self.family_name)
        self.custom_url = UrlGenerator.parse_custom_url_obj(custom_url=custom_url, mcu=mcu, url_parts=self.url_parts) 

    @staticmethod
    def get_key_value(url_parts: UrlParts, key: str)->str:
        value = getattr(url_parts, key, None) if isinstance(url_parts, UrlParts) else url_parts[key]
        if isinstance(value, str):
            return value
        elif isinstance(value, dict):
            return value.get("value") or value.get("val")
        return None
        
    @staticmethod
    def parse_custom_url_obj(custom_url: Optional[Dict], mcu: str, url_parts: UrlParts) -> Dict:
        if not custom_url: 
            return {}
        #this is so the custom url can be recognized as {"stm_family" : {"prop1" : value1, ...."prop":value}}
        #or {"prop1" : value1, ...."prop":value}
        return custom_url[mcu] if mcu in custom_url else {key: value for key, value in custom_url.items() if hasattr(url_parts, key)}

    @property
    def url(self)->str:
        url = ""
        for key, value in vars(self.url_parts).items():
            #print(value)
            if not value.startswith("/") and not value.startswith("http") and key != "file_extension":
                value = f"/{value}"
            elif key == "file_extension":
                value = f".{value}"
            url = url + value
        return url

    @property
    def file_name(self)->str: 
        return self.url_parts.file_name
        
    def apply_custom_url(self):
        if not self.custom_url:
            return
        for key, value in self.custom_url.items():
            if hasattr(self.url_parts, key):
                self.apply_value(key, value)

    def apply_value(self, key: str, value: Union[str, Dict, callable]):
        if isinstance(value, str):
            setattr(self.url_parts, key, value)
        elif callable(value):
            setattr(self.url_parts, key, value(getattr(self.url_parts, key)))
        elif isinstance(value, dict):
            self.apply_dict_value(key, value)


    def apply_dict_value(self, key: str, url_part_custom_obj: Dict):

        fun_dicts = {
            "prefix" : lambda url,arg: f"{arg}{url}",
            "sufix" : lambda url,arg: f"{url}{arg}",
            "function" : lambda url,arg: arg(url),
        }
        part = url_part_custom_obj.get("value")
        url_part = part if part else getattr(self.url_parts, key)
        #iterate through the modifiers for a url component, namely: value, prefix, sufix, functions, index
        for modifier in url_component_modifiers:
            #checks if the modifier is set in the url_part_custom_obj
            if mod_value := url_part_custom_obj.get(modifier):
                url_part = fun_dicts[modifier](url_part, mod_value)
        setattr(self.url_parts, key, url_part)


        

#a = StartupScriptUrlGenerator(mcu="stm32f411xe", arch="cortex-m7", dedicated_per_core=True, custom_url=exceptions_url)
#b = StartupScriptUrlGenerator(mcu="stm32h755xx", arch="cortex-m7", dedicated_per_core=True, custom_url=exceptions_url)
#c = StartupScriptUrlGenerator(mcu="stm32wl55xx", arch="cortex-m7", dedicated_per_core=True, custom_url=exceptions_url)
#a = LinkerScriptUrlGenerator(mcu="stm32wl55xx", arch="cortex-m7", mount_on_ram=True, dedicated_per_core=True)

print(a.url)



#https://github.com/STMicroelectronics/cmsis_device_wl/tree/main/Source/Templates/gcc 
#https://github.com/STMicroelectronics/cmsis_device_h7/tree/master/Source/Templates/gcc
#https://github.com/STMicroelectronics/STM32CubeF4/tree/master/Projects/STM32F411RE-Nucleo/Templates/SW4STM32




class CoreData:
    mcu_name = TypedProperty(data_type=str)
    architecture = TypedProperty(data_type=str, validator=architecture_validator)
    fpu = TypedProperty(data_type=str, default="soft", validator=fpu_validator)
    fpu_v = TypedProperty(data_type=str, default="", validator=fpu_v_validator)
    supports_mount_on_ram = TypedProperty(data_type=object, default=False, validator=truthy_falsy_validator)
    dedicated_startup_file = TypedProperty(data_type=object, default=False, validator=truthy_falsy_validator)
    mount_on_ram = TypedProperty(data_type=object, default=False, validator=truthy_falsy_validator)  # Define mount_on_ram as a TypedProperty

    startup_script_url = TypedProperty(data_type=str, default="")
    linker_script_url = TypedProperty(data_type=list, default=[])

    def __init__(self, **kwargs):

        _handlers = {}

        # Identify attributes without default values
        required_attrs = [attr_name for attr_name, attr_value in self.__class__.__dict__.items()
                            if isinstance(attr_value, TypedProperty) and not attr_value.has_default]

        
        # Check if all required attributes are provided in kwargs
        missing_attrs = [attr for attr in required_attrs if attr not in kwargs]
        if missing_attrs:
            raise ValueError(f"Missing required attributes: {', '.join(missing_attrs)}")

        for key, value in kwargs.items():
            if hasattr(self, key):  # Check if the attribute exists
                if hasattr(_handlers, key):
                    _handlers[key](self, value)
                else:
                    setattr(self, key, value)
            else:
                raise AttributeError(f"'{type(self).__name__}' object has no attribute '{key}'")

        # Initialize attributes with default values if not provided in kwargs
        for attr_name, attr_value in CoreData.__dict__.items():
            if isinstance(attr_value, TypedProperty) and attr_value.has_default and attr_name not in kwargs:
                setattr(self, attr_name, attr_value.default)

        self.startup_script_url = self.generate_startup_script_url()
        self.linker_script_url = self.generate_linker_script_url()

    def update(self):
        self.startup_script_url = self.generate_startup_script_url

    def to_dict(self):
        """Convert the CoreData object to a dictionary."""
        return {key: value for key, value in self.__dict__.items() if not key.startswith("_")}
    
    def generate_startup_script_url(self):
        return UrlGenerator.generate_url(self.mcu_name, "startup", self.architecture, self.dedicated_startup_file)

    def generate_linker_script_url(self):
        mount_on = ["flash"]
        a = []
        if self.supports_mount_on_ram:
            mount_on.append("sram")
        for mount in mount_on:
            url = UrlGenerator.generate_url(self.mcu_name, "linker", self.architecture, True)
            a.append({mount : url})
        return a 
        
    

#stm32h755xx_m4 = CoreData(
#    mcu_name="stm32h755xx",
#    architecture="cortex-m4",
#    fpu="hard",
#    fpu_v="fpv4-sp-d16",
#)
#stm32h755xx_m7 = CoreData(
#    mcu_name="stm32h755xx",
#    architecture="cortex-m7",
#    fpu="hard",
#    fpu_v="fpv5-sp-d16",
#)

