FROM ubuntu:22.10 AS base

ARG GCC_ARM_NONE_EABI_VERSION_ARG
ARG TARGET_ARCHITECTURE_ARG

ENV DEBIAN_FRONTEND=noninteractive
ENV GCC_ARM_NONE_EABI_VERSION=$GCC_ARM_NONE_EABI_VERSION_ARG
ENV TARGET_ARCHITECTURE=$TARGET_ARCHITECTURE_ARG

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y pixz gcc g++ git cmake make build-essential ninja-build zsh 

FROM base AS additional

RUN apt-get update -y && \
    apt-get install -y gnupg libtool libusb-1.0.0 libncurses5 libncurses5-dev wget curl  \
        libasound2 libatk-bridge2.0-0 libatk1.0-0 \
        libcairo2 libdbus-1-3 libdrm2 libgbm1 libglib2.0-0 libgtk-3-0 \
        libnspr4 libnss3 libpango-1.0-0 libsecret-1-0 libx11-6 libxcb1 \
        libxcomposite1 libxdamage1 libxext6 libxfixes3 libxkbcommon0 libxkbfile1 \
        libxrandr2 xdg-utils pkg-config texinfo libgmp-dev libmpc-dev bash-completion \
        vim htop libreadline-dev tmux screen valgrind cppcheck clang-tidy lcov && \
    apt-get clean

FROM additional as copy_files
COPY setup/downloaded_packages /tmp/downloaded_packages
COPY setup/container_packages_installation_scripts /tmp/scripts
RUN chmod +x /tmp/scripts/*

FROM copy_files as install_arm_toolchain
RUN /tmp/scripts/install_arm_toolchain.sh

FROM install_arm_toolchain as install_vscode 
RUN /tmp/scripts/install_vscode.sh

FROM install_vscode as install_openocd
RUN /tmp/scripts/install_openocd.sh

FROM install_openocd as add_project_template
COPY setup/project_template /home/user/project_template

FROM add_project_template AS add_libusb
RUN apt-get update && \
    apt-get install libusb-dev libusb-1.0.0-dev




