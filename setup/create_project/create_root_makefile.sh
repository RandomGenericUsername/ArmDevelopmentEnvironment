#!/bin/bash


populate()
{
    local tmp=""
    for src_dirs in ${MCU_SRC_DIRS[@]}; do
        if [[ ${#MCU_SRC_DIRS[@]} -eq 1 ]]; then
            tmp=$MCU_SRC_DIR_DEFAULT
        fi
        tmp+="${CORE_DIR}/$src_dirs "
    done
    echo $tmp
}

create_rule() {
    local target=""
    local dependencies=""
    local command=""

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -t|--target) target="$2"; shift ;;
            -d|--dependencies) dependencies="$2"; shift ;;
            -c|--command) command="$2"; shift ;;
            *) echo "Unknown parameter passed: $1"; exit 1 ;;
        esac
        shift
    done

    echo -e "\n$target: $dependencies\n\t$command" >> Makefile
}

src_dirs_str="$(populate)"

echo "" > Makefile
echo "SUBDIRS := ${src_dirs_str}" >> Makefile

for dir in "${MCU_SRC_DIRS[@]}"; do
    suffix="_${dir}"
    if [[ ${#MCU_SRC_DIRS[@]} -eq 1 ]]; then
        dir=$MCU_SRC_DIR_DEFAULT
        suffix=""
    fi
    create_rule --target "all${suffix}" --command "\$(MAKE) -C ${CORE_DIR}/${dir} all"
    create_rule --target "build_project${suffix}" --command "\$(MAKE) -C ${CORE_DIR}/${dir} build_project"
    create_rule --target "build_test${suffix}" --command "\$(MAKE) -C ${CORE_DIR}/${dir} build_test"
    create_rule --target "flash${suffix}" --command "\$(MAKE) -C ${CORE_DIR}/${dir} flash"
    create_rule --target "clean${suffix}" --command "\$(MAKE) -C ${CORE_DIR}/${dir} clean"
    create_rule --target "clean_test${suffix}" --command "\$(MAKE) -C ${CORE_DIR}/${dir} clean_test"
    build_all_deps+="all${suffix} "
    build_project_deps+="build_project${suffix} "
    build_test_deps+="build_test${suffix} "
    flash_deps+="flash${suffix} "
    clean_deps+="clean${suffix} "
    clean_test_deps+="clean_test${suffix} "
done

if [[ ${#MCU_SRC_DIRS[@]} -gt 1 ]]; then
    create_rule --target "all" --dependencies "${build_all_deps}"
    create_rule --target "build_projects" --dependencies "${build_project_deps}"
    create_rule --target "build_tests" --dependencies "${build_test_deps}"
    create_rule --target "flash" --dependencies "${flash_deps}"
    create_rule --target "clean" --dependencies "${clean_deps}"
    create_rule --target "clean_tests" --dependencies "${clean_test_deps}"
fi



