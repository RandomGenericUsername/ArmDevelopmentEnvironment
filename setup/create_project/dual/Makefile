
SUBDIRS := Core/m4 Core/m7

build_test: 
	$(MAKE) -C Core/m4 build_test

clean_test: 
	$(MAKE) -C Core/m4 clean_test

run_test: 
	$(MAKE) -C Core/m4 run_test

all_m4: 
	$(MAKE) -C Core/m4 all

build_project_m4: 
	$(MAKE) -C Core/m4 build_project

flash_m4: 
	$(MAKE) -C Core/m4 flash

clean_m4: 
	$(MAKE) -C Core/m4 clean

all_m7: 
	$(MAKE) -C Core/m7 all

build_project_m7: 
	$(MAKE) -C Core/m7 build_project

flash_m7: 
	$(MAKE) -C Core/m7 flash

clean_m7: 
	$(MAKE) -C Core/m7 clean

all: all_m4 all_m7 
	

build_projects: build_project_m4 build_project_m7 
	

flash: flash_m4 flash_m7 
	

clean: clean_m4 clean_m7 
	
