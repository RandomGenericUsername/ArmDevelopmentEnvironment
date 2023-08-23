#!/bin/bash

MCU_MAIN_TEMPLATE=$(cat <<- EOM
int main(void)
{

    return 0;
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

echo "$TEST_MAIN_TEMPLATE" > "${PROJECT_NAME}/Tests/main.cpp"

# Create directories based on MCU_SRC_DIRS array
for dir in "${MCU_SRC_DIRS[@]}"; do
    echo "$MCU_MAIN_TEMPLATE" > "${PROJECT_NAME}/Core/$dir/main_${dir}.cpp"
done

if [[ $IS_DUAL_CORE -eq 0 ]]; then
    cp syscalls.c sysmem.c "${PROJECT_NAME}/Core/Common"
else
    cp syscalls.c sysmem.c "${PROJECT_NAME}/Core/${MCU_SRC_DIR_DEFAULT}"
fi