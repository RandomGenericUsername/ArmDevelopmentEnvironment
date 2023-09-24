
from abc import ABC, abstractmethod
from enum import Enum
from typing import Dict, Union, Optional, Callable, TypedDict
import json

class UrlSubParts(Enum):
    base_name = "base_name"
    prefix = "prefix"
    suffix = "suffix"

class UrlSubPartDict(TypedDict):
    value: str
    op: Optional[Callable[[str], str]]

class UrlSubPart():
    def __init__(self, value: Optional[str]=None, operation: Optional[Callable[[str], str]]=None) -> None:
        self.value = value
        self.operation = operation

    def __repr__(self):
        return self.operation(self.value) if callable(self.operation) else (self.value if self.value else "")

    @staticmethod
    def isinstance(obj: dict) -> bool:
        return isinstance(obj, dict) and \
           'value' in obj and isinstance(obj['value'], str) and \
           ('op' in obj and callable(obj['op']) or obj.get('op') is None)

class UrlPart():

    url_sub_parts = [UrlSubParts.prefix, UrlSubParts.base_name, UrlSubParts.suffix]

    def __init__(self, base_name: Union[str, UrlSubPartDict], prefix: Optional[Union[str, UrlSubPartDict]]=None, suffix: Optional[Union[str, UrlSubPartDict]]=None) -> None:
        # Capture the arguments as a dictionary
        args_dict = locals()
        # Remove "self" from dict
        args_dict.pop('self')

        # Assert the arguments to be of str type
        self.assert_str_args(args=args_dict.values())

        # Assign the values to the members
        self.assign_members_values(url_part_obj=self, args_dict=args_dict.items())

    def serialize(self)->dict:
        return {k:v for k,v in self.__dict__.items()}

    def __repr__(self) -> str:
        concatenated_parts = []
        for sub_part in self.url_sub_parts:
            member_value = getattr(self, sub_part.value)
            if member_value is not None:
                concatenated_parts.append(str(member_value))
        return ''.join(concatenated_parts)

    @staticmethod
    def assert_str_args(args: Union[list, tuple]):
        for arg in args:
            if arg is not None and not isinstance(arg, str) and not UrlSubPart.isinstance(arg):
                raise ValueError(f"Argumrnt {arg} is not a string or a UrlSubPartDict object")

    @staticmethod
    def assign_members_values(url_part_obj: 'UrlPart', args_dict: dict):
        for k,v in args_dict:
            op = None
            if UrlSubPart.isinstance(v):
                value = v["value"]
                op = v.get("op")
            else:
                value = v
            value = "" if not value else value
            setattr(url_part_obj, k, UrlSubPart(value=value, operation=op))


a = UrlPart(base_name="b", suffix={"value": "cunt", "op":str.upper})
print(a)

    











