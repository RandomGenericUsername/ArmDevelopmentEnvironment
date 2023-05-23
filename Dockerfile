FROM ubuntu:20.04 AS base

ARG GCC_ARM_NONE_EABI_VERSION_ARG
ARG TARGET_ARCHITECTURE_ARG

ENV DEBIAN_FRONTEND=noninteractive
ENV GCC_ARM_NONE_EABI_VERSION=$GCC_ARM_NONE_EABI_VERSION_ARG
ENV TARGET_ARCHITECTURE=$TARGET_ARCHITECTURE_ARG
ENV DOWNLOADED_PACKAGES_LOCATION=/home/.downloaded_packages
ENV INSTALLATION_SCRIPTS_LOCATION=/home/.scripts
ENV PROJECT_TEMPLATE_LOCATION=/home/template_project

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y pixz wget curl gcc g++ git autoconf pkg-config automake libtool cmake make build-essential ninja-build zsh \
    libusb-1.0.0 libusb-dev libusb-1.0.0-dev gnupg libncursesw5 libncurses5-dev \
    bash-completion vim htop libreadline-dev && \
    apt-get clean

COPY setup/downloaded_packages ${DOWNLOADED_PACKAGES_LOCATION} 
COPY setup/container_packages_installation_scripts ${INSTALLATION_SCRIPTS_LOCATION}
RUN chmod +x ${INSTALLATION_SCRIPTS_LOCATION}/*

FROM base as install_openocd
RUN /home/.scripts/install_openocd.sh

FROM install_openocd as install_python
RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update -y && \
    apt-get install python3.7 -y && \
    apt-get clean

FROM install_python as install_arm_toolchain
RUN /home/.scripts/install_arm_toolchain.sh

FROM install_arm_toolchain as additional_utilities
RUN apt-get update -y && \
        apt-get upgrade -y && \
        apt-get install -y clang-tidy lcov flawfinder cppcheck && \
        apt-get clean
        
FROM additional_utilities as fix_gdb_installation
RUN apt-get update && \
    apt-get -o Dpkg::Options::="--force-overwrite" install -y gdb-multiarch

FROM fix_gdb_installation as add_project_template
COPY setup/project_template ${PROJECT_TEMPLATE_LOCATION} 





