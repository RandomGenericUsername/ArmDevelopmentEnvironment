#declare environment variables 
export SCRIPTS_PERSMISSIONS := 711
export DOWNLOADED_PACKAGES_LOCATION := setup/downloaded_packages
export SCRIPTS_LOCATION := setup/scripts


# Default target
install: add_to_gitignore make_executables download_packages

# Setup target to be executed only the first time
add_to_gitignore: 
	@echo "" >> .gitignore;
	@echo -e "# Exclude downloaded packages" >> .gitignore;
	@echo "${DOWNLOADED_PACKAGES_LOCATION}" >> .gitignore;

make_executables:
	@ chmod ${SCRIPTS_PERSMISSIONS} ${SCRIPTS_LOCATION}/*

download_packages:
	@ ./${SCRIPTS_LOCATION}/download_packages.sh

#add to gitignore