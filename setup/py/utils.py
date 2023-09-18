
import json
import re

def convert_to_raw_url(github_url):
    """
    Convert a GitHub repository file link to its raw URL.

    Args:
    - github_url (str): The GitHub URL of the file.

    Returns:
    - str: The raw URL of the file.
    """
    # Replace 'github.com' with 'raw.githubusercontent.com'
    raw_url = github_url.replace("github.com", "raw.githubusercontent.com")
    
    # Remove the '/blob/' part from the URL
    raw_url = raw_url.replace("/blob/", "/")
    
    return raw_url


# Define a unique sentinel object
_NO_DEFAULT = object()
class TypedProperty:
    def __init__(self, data_type, default=_NO_DEFAULT, validator=None):
        self.data_type = data_type
        self.validator = validator
        self.default = default
        self._has_default = default is not _NO_DEFAULT

    def __set_name__(self, owner, name):
        self.name = name

    def __get__(self, instance, owner):
        return instance.__dict__.get(self.name, self.default)

    def __set__(self, instance, value):
        if not isinstance(value, self.data_type):
            raise TypeError(f"Expected {self.data_type}, got {type(value)}")
        
        # If a validator function is provided, use it to validate the value
        if self.validator and not self.validator(value):
            raise ValueError(f"Invalid value for {self.name}: {value}")
        
        instance.__dict__[self.name] = value
    
    @property
    def has_default(self):
        return self._has_default


# Validators
def script_url_validator(value):
    # Helper function to validate individual dictionary
    def validate_script(script):
        # Check if the dictionary has the required keys
        if not all(key in script for key in ["mount", "url"]):
            return False
        # Check if 'mount' has a valid value
        if script["mount"] not in ["flash", "ram"]:
            return False
        # Check if 'link' is a valid URL
        if not script["url"].startswith("http"):
            return False
        return True

    # If value is a list, validate each dictionary in the list
    if isinstance(value, list):
        return all(validate_script(script) for script in value)
    # If value is a dictionary, validate it
    elif isinstance(value, dict):
        return validate_script(value)
    return False


def fpu_validator(value):
    return value in ["hard", "soft"]

def fpu_v_validator(value):
    # Regular expression pattern for fpvX-sp-dYZ
    pattern = r'^(fpv[0-9]-sp-d[0-9]{1,2}|)$'
    return re.match(pattern, value) is not None

def architecture_validator(value):
    pattern = r'^cortex-m[0-9](plus)?$'
    return re.match(pattern, value) is not None

def truthy_falsy_validator(value):
    """Validator for truthy or falsy values."""
    return value == bool(value)



