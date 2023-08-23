#!/bin/bash


cd "${PROJECT_NAME}/Startup"
# Iterate over all files in the current directory
for file in *; do
    # Convert the filename to lowercase and rename
    mv "$file" "${file,,}"
done

cd -

