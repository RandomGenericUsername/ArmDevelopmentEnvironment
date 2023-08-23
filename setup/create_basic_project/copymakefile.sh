#!/bin/bash

# The original Makefile
SRC_MAKEFILE="makefile"

# The destination Makefile
DEST_MAKEFILE="makefile.copy"

# Check if the source Makefile exists
if [ ! -f "$SRC_MAKEFILE" ]; then
    echo "Error: $SRC_MAKEFILE not found!"
    exit 1
fi

# Copy the Makefile to the destination
cp "$SRC_MAKEFILE" "$DEST_MAKEFILE"

# Loop through all arguments
for arg in "$@"; do
    # Split the argument into NAME and VALUE
    IFS="=" read -ra PARTS <<< "$arg"
    NAME="${PARTS[0]}"
    VALUE="${PARTS[1]}"

    # Replace the variable in the destination Makefile
    sed -i "s/^\($NAME\s*:=\).*/\1 $VALUE/" "$DEST_MAKEFILE"

done

echo "Makefile copied and variables replaced."
