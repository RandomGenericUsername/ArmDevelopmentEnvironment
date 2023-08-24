#!/bin/bash

if [[ -f "$DOWNLOAD_RESOURCES_SCRIPT_NAME" ]]; then
    source "$DOWNLOAD_RESOURCES_SCRIPT_NAME"
else
    echo "Error: Script $DOWNLOAD_RESOURCES_SCRIPT_NAME not found!"
fi