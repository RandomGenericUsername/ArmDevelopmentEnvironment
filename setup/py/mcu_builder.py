
from utils import *

class CoreData:
    mcu_name = TypedProperty(data_type=str)
    architecture = TypedProperty(data_type=str, validator=architecture_validator)
    fpu = TypedProperty(data_type=str, default="soft", validator=fpu_validator)
    fpu_v = TypedProperty(data_type=str, default="", validator=fpu_v_validator)
    startup_script_url = TypedProperty(data_type=str, default="")
    linker_script_url = TypedProperty(data_type=list, default=[])
    supports_mount_on_ram = TypedProperty(data_type=object, default=False, validator=truthy_falsy_validator)
    dedicated_startup_file = TypedProperty(data_type=object, default=False, validator=truthy_falsy_validator)
    mount_on_ram = TypedProperty(data_type=object, default=False, validator=truthy_falsy_validator)  # Define mount_on_ram as a TypedProperty
    base_url = "https://github.com/STMicroelectronics/"


    def _handle_script_url(self, value):
        """Handles the initialization of script URLs."""
        if isinstance(value, str):
            return [{"mount": "flash", "url": value}]
        elif isinstance(value, dict):
            return [value]
        elif isinstance(value, list):
            return value
        else:
            raise TypeError(f"Invalid type for script URL: {type(value)}")

    def _handle_mount_on_ram(self, value):
        """Converts the value to a boolean based on its truthiness."""
        return bool(value)


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

    def update(self):
        self.startup_script_url = self.generate_startup_script_url()

    def to_dict(self):
        """Convert the CoreData object to a dictionary."""
        return {key: value for key, value in self.__dict__.items() if not key.startswith("_")}
    
    def generate_startup_script_url(self):
        return self.generate_url(self.mcu_name, "startup")

    def generate_linker_script_url(self):
        return [self.generate_url(self.mcu_name, "linker")]
        
    
    def determine_repo(self, mcu_name):
        """Determine the repository name based on the MCU name."""
        # This function can be expanded as more MCUs are added
        if "h7" in mcu_name:
            return "cmsis_device_h7"
        elif "wl" in mcu_name:
            return "cmsis_device_wl"
        elif "f4" in mcu_name:
            return "STM32CubeF4"
        else:
            raise ValueError("Unknown MCU series")

    def generate_url(self, mcu_name, file_type, extra_info=""):
        """Generate the URL for the given MCU, core type, and file type."""
        core_type = self.get_core_name()
        if file_type == "linker":
            file_name = f"{mcu_name}_{core_type}.ld"
        elif file_type == "startup":
            path = f"{mcu_name}_{core_type}" if self.dedicated_startup_file else mcu_name
            file_name = f"startup_{path}.s"
        else:
            raise ValueError("Invalid file type")

        repo_name = self.determine_repo(mcu_name)
        url = f"{self.base_url}{repo_name}/blob/master/Source/Templates/gcc/{extra_info}{file_name}"
        return convert_to_raw_url(url)
    
    def get_core_name(self):
        core_name = self.architecture.split("-")[1]
        return f"c{core_name}"

    



class MCU:

    _instances = {}  # Class-level dictionary to store instances

    mcu = TypedProperty(str)
    number_of_cores = TypedProperty(int)
    core_data = TypedProperty(list)
    dedicated_startup_file_per_core = TypedProperty(data_type=object, default=False, validator=truthy_falsy_validator)

    def __new__(cls, mcu, core_data, dedicated_startup_file_per_core=False):
        # If an instance with the given mcu name already exists, return that instance
        if mcu in cls._instances:
            instance = cls._instances[mcu]
        else:
            # Otherwise, create a new instance and store it in the dictionary
            instance = super(MCU, cls).__new__(cls)
            cls._instances[mcu] = instance
            instance.mcu = mcu  # Initialize the mcu attribute here
        return instance
    
    def _handle_core_data(self, value):
        """Handles the initialization of core data."""
        if isinstance(value, dict):
            self.number_of_cores = 1
            value.dedicated_startup_file = self.dedicated_startup_file_per_core
            value.update()
            return [value]  # Convert the dict to a single-item list for consistency
        elif isinstance(value, list):
            self.number_of_cores = len(value)
            for i in value:
                i.dedicated_startup_file = self.dedicated_startup_file_per_core
                i.update()
            return value
        else:
            raise TypeError("core_data must be either a dict or a list of dicts")

    def __init__(self, mcu, core_data, dedicated_startup_file_per_core=False):

        self.dedicated_startup_file_per_core = dedicated_startup_file_per_core
        handlers = {
            "core_data": self._handle_core_data,
        }
        for key, value in {"core_data": core_data}.items():
            if hasattr(self, key):  # Check if the attribute exists
                if key in handlers:
                    value = handlers[key](value)
                setattr(self, key, value)
            else:
                raise AttributeError(f"'{type(self).__name__}' object has no attribute '{key}'")
    
    def to_dict(self):
        """Convert the MCU object to a dictionary."""
        mcu_dict = {
            key: (
                [item.to_dict() for item in value] if isinstance(value, list) and all(isinstance(item, CoreData) for item in value) 
                else value.to_dict() if isinstance(value, CoreData) 
                else value
            )
            for key, value in self.__dict__.items() if not key.startswith("_")
        }
        return mcu_dict

    def to_json(self):
        """Convert the MCU object to a JSON string."""
        return json.dumps(self.to_dict(), indent=4)

