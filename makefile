#declare environment variables 
export SCRIPTS_PERSMISSIONS := 711
export DOWNLOADED_PACKAGES_LOCATION := setup/downloaded_packages
export SCRIPTS_LOCATION := setup/scripts
export GCC_ARM_NONE_EABI_VERSION := 12.2

# Default target
install: add_to_gitignore install_requirements make_executables download_packages build_docker_image

# Setup target to be executed only the first time
add_to_gitignore: 
	@echo "" >> .gitignore;
	@echo -e "# Exclude downloaded packages" >> .gitignore;
	@echo "${DOWNLOADED_PACKAGES_LOCATION}" >> .gitignore;

make_executables:
	@ chmod ${SCRIPTS_PERSMISSIONS} ${SCRIPTS_LOCATION}/*

download_packages:
	@ ./${SCRIPTS_LOCATION}/download_packages.sh

install_requirements:
	@ ./${SCRIPTS_LOCATION}/install_requirements.sh

build_docker_image:
	@sudo docker build -f Dockerfile --build-arg VAR=$(GCC_ARM_NONE_EABI_VERSION) .