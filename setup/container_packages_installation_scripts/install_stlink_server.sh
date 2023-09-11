#!/usr/bin/expect -f

# Set the timeout for waiting for a response. Adjust this if needed.
set timeout 300

# Fetch the environment variable
set location $env(DOWNLOADED_PACKAGES_LOCATION)
cd $location/stlink-server
system chmod +x ./st-stlink-server.2.1.0-1-linux-amd64.install.sh
# Launch the STM32CubeIDE installation script.
spawn ./st-stlink-server.2.1.0-1-linux-amd64.install.sh

# Wait for the --More-- prompt from 'more' and send the "q" key to quit.
expect -exact "--More--" { send "q" }

# Now, wait for the license agreement prompt and send the "y" key for "I ACCEPT".
expect -- "I ACCEPT (y) / I DO NOT ACCEPT (N)" { send "y\r" }

# Wait for the script to complete.
expect eof