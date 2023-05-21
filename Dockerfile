FROM ubuntu:22.10 AS base

ARG VAR

ENV DEBIAN_FRONTEND=noninteractive
ENV GCC_ARM_NONE_EABI_VERSION=$VAR

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y gcc g++ gdb-multiarch cmake make build-essential && \
    apt-get clean

FROM base AS additional

RUN apt-get update -y && \
    apt-get install -y gnupg libtool libncurses5 libncurses5-dev wget curl && \
        pixz libasound2 libatk-bridge2.0-0 libatk1.0-0 \
        libcairo2 libdbus-1-3 libdrm2 libgbm1 libglib2.0-0 libgtk-3-0 \
        libnspr4 libnss3 libpango-1.0-0 libsecret-1-0 libx11-6 libxcb1 \
        libxcomposite1 libxdamage1 libxext6 libxfixes3 libxkbcommon0 libxkbfile1 \
        libxrandr2 xdg-utils pkg-config texinfo libgmp-dev libmpc-dev && \
    apt-get clean

FROM additional as copy_files

COPY setup/downloaded_packages /tmp/downloaded_packages
COPY setup/container_packages_installation_scripts /tmp/scripts

#RUN chmod +x /tmp/scripts/* && \
#    /tmp/scripts/install_openocd.sh && \
#    /tmp/scripts/install_arm_toolchain.sh $GCC_ARM_NONE_EABI_VERSION && \
#    /tmp/scripts/install_vscode.sh