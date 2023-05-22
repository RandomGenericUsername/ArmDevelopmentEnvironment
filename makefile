#declare environment variables 
export SCRIPTS_PERSMISSIONS := 711
export DOWNLOADED_PACKAGES_LOCATION := setup/downloaded_packages
export SCRIPTS_LOCATION := setup/scripts
export GCC_ARM_NONE_EABI_VERSION := 12.2
export TARGET_ARCHITECTURE := x86_64

# Default target
install: install_requirements make_executables download_packages build_docker_image

make_executables:
	@ chmod ${SCRIPTS_PERSMISSIONS} ${SCRIPTS_LOCATION}/*

download_packages:
	@ ./${SCRIPTS_LOCATION}/download_packages.sh

install_requirements:
	@ ./${SCRIPTS_LOCATION}/install_requirements.sh

build_docker_image:
	@sudo docker build -t arm_env -f Dockerfile --platform linux/${TARGET_ARCHITECTURE} --build-arg GCC_ARM_NONE_EABI_VERSION_ARG=$(GCC_ARM_NONE_EABI_VERSION) --build-arg TARGET_ARCHITECTURE_ARG=$(TARGET_ARCHITECTURE) .

delete_all_images:
	@sudo docker stop $$(docker ps -aq)
	@sudo docker rm $$(docker ps -aq)
	@sudo docker rmi $$(docker images -aq)

run_container:
	@sudo docker run --rm -it --privileged -v /dev/bus/usb:/dev/bus/usb arm_env




.PHONY: install add_to_gitignore make_executables download_packages install_requirements build_docker_image
