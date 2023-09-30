
import json
import re
from typing import Any, Optional, Callable, List, get_args, get_origin

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
class TypedProperty:
    def __init__(self, data_type: Any, validator: Optional[Callable]=None):
        self.data_type = data_type
        self.validator = validator

    def __set_name__(self, owner, name):
        self.name = name

    def __get__(self, instance, owner):
        if instance is None:
            return self
        return instance.__dict__.get(self.name)

    def __set__(self, instance, value):
        origin = get_origin(self.data_type)
        args = get_args(self.data_type)


        if origin is list and not isinstance(value, list):
            raise TypeError(f"Expected a list, got {type(value)}")
        elif origin is list and not all(isinstance(item, args[0]) for item in value):
            raise TypeError(f"All items in list must be of type {args[0]}")
        elif origin is not list and not isinstance(value, self.data_type):
            raise TypeError(f"Expected {self.data_type}, got {type(value)}")

        # If a validator function is provided, use it to validate the value
        if self.validator and not self.validator(value):
            raise ValueError(f"Invalid value for {self.name}: {value}")
        
        instance.__dict__[self.name] = value
    


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



