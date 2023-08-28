#!/bin/bash

MCU_MAIN_TEMPLATE=$(cat <<- EOM

extern "C"{

    void SystemInit(void);
}

int main(void)
{

    return 0;
}


void SystemInit(void)
{
    
}

EOM
)

TEST_MAIN_TEMPLATE=$(cat <<- EOM
#include <iostream>

int main(void)
{
    std::cout << "Test is working" << std::endl;
    return 0;
}

EOM
)

echo "$TEST_MAIN_TEMPLATE" > "${PROJECT_NAME}/${TESTS_DIR}/main.cpp"

# Create directories based on MCU_SRC_DIRS array
for dir in "${MCU_SRC_DIRS[@]}"; do
    if [[ ${#MCU_SRC_DIRS[@]} -eq 1  ]]; then
        S=""
        s="Src"
    else
        S="_${dir}"
        s=$dir
    fi
    echo "$MCU_MAIN_TEMPLATE" > "${PROJECT_NAME}/${CORE_DIR}/$s/main${S}.cpp"
done

for dir in "${MCU_SRC_DIRS[@]}"; do
    if [[ ${#MCU_SRC_DIRS[@]} -eq 1 ]]; then
        cp syscalls.c sysmem.c "${PROJECT_NAME}/${CORE_DIR}/${MCU_SRC_DIR_DEFAULT}"
    else
        cp syscalls.c sysmem.c "${PROJECT_NAME}/${CORE_DIR}/${COMMON_DIR}"
    fi
done