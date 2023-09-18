FROM ubuntu:20.04 as base


ARG GCC_ARM_NONE_EABI_VERSION_ARG
ARG TARGET_ARCHITECTURE_ARG

ENV DEBIAN_FRONTEND=noninteractive
ENV GCC_ARM_NONE_EABI_VERSION=$GCC_ARM_NONE_EABI_VERSION_ARG
ENV TARGET_ARCHITECTURE=$TARGET_ARCHITECTURE_ARG
ENV DOWNLOADED_PACKAGES_LOCATION=/home/.downloaded_packages
ENV INSTALLATION_SCRIPTS_LOCATION=/home/.scripts
ENV CREATE_PROJECT_SCRIPT_LOCATION=/home/.create_project
ENV ST_LINK_CLT_PATH=/opt/st/stm32cubeclt
#ENV SETUP_DIR=setup
#ENV DOWNLOADED_PACKAGES_DIR=downloaded_packages
#ENV DOWNLOADED_PACKAGES_PATH=${SETUP_DIR}/{DOWNLOADED_PACKAGES_DIR}

#copy packages to install and scripts
COPY setup/downloaded_packages ${DOWNLOADED_PACKAGES_LOCATION} 
COPY setup/container_packages_installation_scripts ${INSTALLATION_SCRIPTS_LOCATION}

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y pixz wget curl gcc g++ git unzip subversion autoconf pkg-config automake libtool cmake make build-essential ninja-build zsh \
    libusb-1.0.0 libusb-dev libusb-1.0.0-dev gnupg libncursesw5 libncurses5-dev \
    expect tree bash-completion vim htop libreadline-dev clang clang-tidy lcov flawfinder cppcheck mongodb mongodb-server python3 python3-pip &&\
    apt-get clean 

# Install the MongoDB Python driver
RUN pip3 install pymongo

#install newer version of gcc
RUN echo "deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse" | tee -a /etc/apt/sources.list.d/jammy.list &&\
    apt update -y && \
    apt install -y -t jammy gcc && \
    rm /etc/apt/sources.list.d/jammy.list &&\
    apt update -y &&\
    apt-get clean


#install scripts
RUN chmod +x ${INSTALLATION_SCRIPTS_LOCATION}/*

##install st-link
RUN /home/.scripts/install_stlink.sh

#install stmcube cli
RUN /home/.scripts/install_stm_cube_cli.sh

#install the arm toolchain
RUN /home/.scripts/install_arm_toolchain.sh

#fix broken gdb 
RUN apt-get update && \
    apt-get -o Dpkg::Options::="--force-overwrite" install -y gdb-multiarch

#this is in charge of creating the project
COPY setup/create_project ${CREATE_PROJECT_SCRIPT_LOCATION}
ENV PATH="${PATH}:${CREATE_PROJECT_SCRIPT_LOCATION}"

# Copy your Python script to populate MongoDB
#COPY populate_mongo.py ${INSTALLATION_SCRIPTS_LOCATION}/populate_mongo.py

# Copy the entrypoint script
#COPY entrypoint.sh ${INSTALLATION_SCRIPTS_LOCATION}/entrypoint.sh

#RUN chmod +x /home/entrypoint.sh

# Set the entrypoint script as the default command
#ENTRYPOINT ["/home/entrypoint.sh"]


## Set zsh as the default shell
#RUN sed -i -e "s/bin\/bash/bin\/zsh/" /etc/passwd
## Installs ohmyzsh
##RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#





