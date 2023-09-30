from utils import TypedProperty
from abc import ABC, abstractmethod
from enum import Enum
from typing import Dict, Union, Optional, Callable, TypedDict
import json

class UrlParts(Enum):
    base_url = "base_url"
    repo = "repo"
    branch = "branch"
    path = "path"
    file_name = "file_name"
    file_extension = "file_extension"

class UrlGenerator:

    # Define TypedProperty descriptors at the class level
    base_url = TypedProperty(str)
    repo = TypedProperty(str)
    branch = TypedProperty(str)
    path = TypedProperty(str)
    file_name = TypedProperty(str)
    file_extension = TypedProperty(str)

    def __init__(
        self,
        base_url: str,
        repo: str,
        branch: str,
        path: str,
        file_name: str,
        file_extension: str,
    ) -> None:
        pass
        #Typed property descriptors are created automatically
        self.base_url = base_url
        self.repo = repo
        self.branch = branch
        self.path = path
        self.file_name = file_name
        self.file_extension = file_extension

    def __call__(self) -> str:
        concatenated_parts = []
        for k, v in (parts := self.__dict__.items()):
            if (
                not v.startswith("/")
                and not v.startswith("http")
                and k != UrlParts.file_extension.value
            ):
                v = f"/{v}"
            elif k == UrlParts.file_extension.value:
                v = f".{v}"
            concatenated_parts.append(v)
        return "".join(concatenated_parts)

a = UrlGenerator(base_url="21", repo="repo", branch="branch", path="path", file_name="name", file_extension="ext")
#print(a())



class FileTypes(Enum):
    startup_script = "startup"
    linker_script = "linker"

class Filename:
    def __init__(
        self,
        mcu: str,
        arch: str,
        file_type: str,
        dedicated_per_core: Optional[bool] = False,
    ) -> None:
        self.mcu = mcu
        self.arch = arch
        self.file_type = file_type
        self.dedicated_per_core = dedicated_per_core

    @property
    def core_type(self) -> str:
        return self.arch.split("-")[1]

    @abstractmethod
    def __call__(self):
        pass


class StartupScriptFilename(Filename):
    def __init__(self, mcu: str, arch: str, dedicated_per_core: Optional[bool] = False):
        super().__init__(
            mcu=mcu,
            arch=arch,
            file_type=FileTypes.startup_script.value,
            dedicated_per_core=dedicated_per_core,
        )

    def __call__(self)->str:
        name = f"{FileTypes.startup_script.value}_{self.mcu}"
        if self.dedicated_per_core:
            name = f"{name}_c{self.core_type}"
        return name


class LinkerScriptFilename(Filename):
    def __init__(
        self,
        mcu: str,
        arch: str,
        dedicated_per_core: Optional[bool] = False,
        mount_on_ram: Optional[bool] = False,
    ):
        super().__init__(
            mcu=mcu,
            arch=arch,
            file_type=FileTypes.linker_script.value,
            dedicated_per_core=dedicated_per_core,
        )
        self.mount_on_ram = mount_on_ram

    def __call__(self)->str:
        core_type_mapping = {
            "m7": "1",
            "m4": "2",
        }
        # Determine file_type based on conditions
        if self.mount_on_ram:
            file_type = (
                f"sram{core_type_mapping[self.core_type]}"
                if self.dedicated_per_core
                else "sram"
            )
        else:
            file_type = f"flash"

        # Determine suffix based on dedicated_per_core
        suffix = f"_c{self.core_type}" if self.dedicated_per_core else ""

        # Construct and return the file name
        name = f"{self.mcu}_{file_type}{suffix}"
        return name

class UrlGeneratorHandler:
    def __init__(
        self, base_url: str, mcu: str, arch: str, file_type: str, *, options: Optional[dict] = None
    ) -> None:
        self.base_url = base_url
        self.mcu = mcu
        self.arch = arch
        self.file_type = file_type
        self.file_name = UrlGeneratorHandler.get_file_name_generator(
            mcu=mcu,
            arch=arch,
            dedicated_per_core=options.get("dedicated_per_core", False),
            mount_on_ram=options.get("mount_on_ram", False),
            file_type=file_type
        )
        self.url_generator = UrlGenerator(
            base_url=self.base_url,
            repo=UrlGeneratorHandler.get_repo(repo="cmsis_device_", mcu=mcu),
            branch="master",
            path="Source/Templates/gcc",
            file_name=self.file_name(),
            file_extension=UrlGeneratorHandler.get_file_extension(
                file_type=self.file_type
            )
        )
        self.custom_url_definitions = UrlGeneratorHandler.parse_custom_url_obj(
            custom_url_obj=options.get("custom_url", None),
            mcu=mcu,
            url_generator=self.url_generator,
        )
        self.write_custom_url_to_url_generator()

    def __call__(self) -> str:
        return self.url_generator()

    def write_custom_url_to_url_generator(self):
        if not self.custom_url_definitions:
            return
        for url_part_key, url_part_value in self.custom_url_definitions.items():
            if hasattr(self.url_generator, url_part_key):
                setattr(self.url_generator, url_part_key, url_part_value)

    @staticmethod
    def parse_custom_url_obj(
        custom_url_obj: Union[Dict, None], mcu: str, url_generator: UrlGenerator
    ) -> Dict:
        if not custom_url_obj:
            return None
        # this is so the custom url can be recognized as {"stm_family" : {"prop1" : value1, ...."prop":value}}
        # or {"prop1" : value1, ...."prop":value}
        return (
            custom_url_obj[mcu]
            if mcu in custom_url_obj
            else {
                key: value
                for key, value in custom_url_obj.items()
                if hasattr(url_generator, key)
            }
        )

    @staticmethod
    def get_file_name_generator(
        mcu: str,
        arch: str,
        dedicated_per_core: bool,
        mount_on_ram: bool,
        file_type: str,
    ) -> str:
        obj = None
        if file_type == FileTypes.startup_script.value:
            obj = StartupScriptFilename(
                mcu=mcu, arch=arch, dedicated_per_core=dedicated_per_core
            )
        elif file_type == FileTypes.linker_script.value:
            obj = LinkerScriptFilename(
                mcu=mcu,
                arch=arch,
                dedicated_per_core=dedicated_per_core,
                mount_on_ram=mount_on_ram,
            )
        else:
            raise KeyError("...CHECK.....")
        return obj

    @staticmethod
    def family_name(mcu: str) -> str:
        return mcu[5:7]

    @staticmethod
    def get_repo(repo: str, mcu: str) -> str:
        return f"{repo}{UrlGeneratorHandler.family_name(mcu=mcu)}"

    @staticmethod
    def get_file_extension(file_type: str):
        extension = {
            FileTypes.linker_script.value: "ld",
            FileTypes.startup_script.value: "s",
        }
        return extension[file_type]


#a = UrlGeneratorHandler(
#    base_url="http://home.com",
#    mcu="stm32wl55xx",
#    arch="cortex-m7",
#    file_type="linker",
#    options={
#        "dedicated_per_core": True,
#        "mount_on_ram": True,
#        "custom_url" : {
#            "branch" : "other-branch"
#        }
#    },
#)
#print(a())

