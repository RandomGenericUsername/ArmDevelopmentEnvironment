
#!/usr/bin/env python3
from stm_mcu_families import *
import argparse

def validate_args(mcu, pname):
    assert isinstance(mcu, str), "MCU must be a string"
    assert isinstance(pname, str), "PNAME must be a string"
    print(f"MCU: {mcu}, Project name: {pname}")

def main():
    parser = argparse.ArgumentParser(description="Script to validate -mcu and -pname arguments.")
    parser.add_argument("-mcu", required=True, help="MCU argument", type=str)
    parser.add_argument("-pname", required=True, help="Project name argument", type=str)

    args = parser.parse_args()
    validate_args(args.mcu, args.pname)

    mcu = args.mcu
    project_name = args.pname


if __name__ == "__main__":
    main()
