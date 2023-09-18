from utils import *
import copy

base_url = "https://raw.githubusercontent.com/STMicroelectronics"

exceptions_url = {
    "stm32f411xe" : {"repo" : "STM32CubeF4", "path" : "Projects/STM32F411RE-Nucleo/Templates/SW4STM32"},
    "stm32wl55xx" : {"branch" : "main"}
}

defaults = {
    "base_url" : base_url,
    "repo" : "cmsis_device_",
    "branch" : "master",
    "path" : "Source/Templates/gcc"
}


class UrlGenerator:

    elements = ["base_url", "repo", "branch", "path", "filename", "extension"]
    default_url = ""
    extensions = {
        "linker" : "ld",
        "startup" : "s"
    }

    def __init__(self, mcu, arch, filetype, dedicated = False):
        self.mcu = mcu
        self.arch = arch
        self.filetype = filetype
        self.dedicated = dedicated
        self.url_elements = copy.deepcopy(defaults)
        self.adequate()
        
    def adequate(self):

        self.url_elements["repo"] = self.url_elements["repo"] + self.family_name

        except_url = exceptions_url.get(self.mcu, None)

        if except_url is not None:
            for key, value in except_url.items():
                if self.url_elements.get(key, None) is not None:
                    self.url_elements[key] =  value
    
    @property
    def file_name(self):
        name = ""
        extension = self.extensions[self.filetype]

        if extension == "s":
            name = f"startup_{self.mcu}"
            if self.dedicated:
                name = f"{name}_c{self.core_type}"

        elif extension == "ld":
            pass

        name = f"{name}.{extension}"
        return name

    @property
    def core_type(self):
        return self.arch.split("-")[1]

    @property
    def extension(self):
        return self.extensions[self.filetype]
        
    @property
    def url(self):

        url = ""
        for key, value in self.url_elements.items():
            if not value.startswith("/"):
                value = f"/{value}"
            url = url + value

        if self.filetype == "linker": 
            url = f"{url}/linker"

        url = f"{url}/{self.file_name}"

        return url

    @property
    def family_name(self):
        return self.mcu[5:7]



a = UrlGenerator("stm32h755xx", "cortex-m7", "startup")
b = UrlGenerator("stm32f411xe", "cortex-m4", "startup")
c = UrlGenerator("stm32wl55xx", "cortex-m0plus", "startup", True)
print(a.url)
print(b.url)
print(c.url)
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

