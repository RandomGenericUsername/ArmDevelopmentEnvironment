#!/usr/bin/expect -f

# Set the timeout for waiting for a response. Adjust this if needed.
set timeout 300

# Fetch the environment variable
set location $env(DOWNLOADED_PACKAGES_LOCATION)
cd $location/stm-cube-cli
system chmod +x ./stm_cube_cli.sh
# Launch the STM32CubeIDE installation script.
spawn ./stm_cube_cli.sh

# Wait for the --More-- prompt from 'more' and send the "q" key to quit.
expect -exact "--More--" { send "q" }

# Now, wait for the license agreement prompt and send the "y" key for "I ACCEPT".
expect -- "I ACCEPT (y) / I DO NOT ACCEPT (N)" { send "y\r" }

# Wait for the STM32CubeCLT install directory prompt and just press "Enter".
#expect -- "STM32CubeCLT install dir?.*" { send "\r" }


# Wait for the script to complete.
expect eof