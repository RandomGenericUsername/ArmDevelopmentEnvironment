FROM ubuntu:20.04 as base


ARG GCC_ARM_NONE_EABI_VERSION_ARG
ARG TARGET_ARCHITECTURE_ARG

ENV DEBIAN_FRONTEND=noninteractive
ENV GCC_ARM_NONE_EABI_VERSION=$GCC_ARM_NONE_EABI_VERSION_ARG
ENV TARGET_ARCHITECTURE=$TARGET_ARCHITECTURE_ARG
ENV DOWNLOADED_PACKAGES_LOCATION=/home/.downloaded_packages
ENV INSTALLATION_SCRIPTS_LOCATION=/home/.scripts
ENV CREATE_PROJECT_SCRIPT=/home/.scripts
ENV PATH="${PATH}:${CREATE_PROJECT_SCRIPT}"

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y pixz wget curl gcc g++ git unzip subversion autoconf pkg-config automake libtool cmake make build-essential ninja-build zsh \
    libusb-1.0.0 libusb-dev libusb-1.0.0-dev gnupg libncursesw5 libncurses5-dev \
    expect tree bash-completion vim htop libreadline-dev clang clang-tidy lcov flawfinder cppcheck && \
    apt-get clean 

#install newer version of gcc
RUN echo "deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse" | tee -a /etc/apt/sources.list.d/jammy.list &&\
    apt update -y && \
    apt install -y -t jammy gcc && \
    rm /etc/apt/sources.list.d/jammy.list &&\
    apt update -y &&\
    apt-get clean

#copy packages to install and scripts
COPY setup/downloaded_packages ${DOWNLOADED_PACKAGES_LOCATION} 
COPY setup/container_packages_installation_scripts ${INSTALLATION_SCRIPTS_LOCATION}
#install scripts
RUN chmod +x ${INSTALLATION_SCRIPTS_LOCATION}/*
#install the arm toolchain
RUN /home/.scripts/install_arm_toolchain.sh
#install st-link
RUN /home/.scripts/install_stlink.sh
#
RUN /home/.scripts/install_stm_cube_cli.sh

#
#fix broken gdb 
RUN apt-get update && \
    apt-get -o Dpkg::Options::="--force-overwrite" install -y gdb-multiarch


# Set zsh as the default shell
RUN sed -i -e "s/bin\/bash/bin\/zsh/" /etc/passwd
#RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#this is in charge of creating the project
COPY setup/create_project ${CREATE_PROJECT_SCRIPT}





