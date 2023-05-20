#/bin/bash

downloadWithCurl()
{
    curl -o "$PACKAGE_FILE_NAME.$PACKAGE_EXTENSION" -L $URL 
}

downloadWithWget()
{
    wget -O "$PACKAGE_FILE_NAME.$PACKAGE_EXTENSION" $URL
}

untarPackage()
{
    if [[ $PACKAGE_EXTENSION == "tar" ]]; then
        echo $(pwd)
        file="$PACKAGE_FILE_NAME.$PACKAGE_EXTENSION"
        echo "Decompressing package $file"
        tar -xJf $file --strip-components=1
        rm $file
        echo "Done"
    fi
}

downloadPackage()
{
    echo "<--------------------------------------------------------------------------------------->"
    echo "Downloading $PACKAGE_FILE_NAME"
    cd "$DOWNLOADED_PACKAGES_LOCATION/$PACKAGE_FILE_NAME"
    downloadWithWget
    #downloadWithCurl
    echo "Finished downloading $PACKAGE_FILE_NAME"
    echo "<--------------------------------------------------------------------------------------->"
    untarPackage
}

assertFolder()
{
    FOLDER="$DOWNLOADED_PACKAGES_LOCATION/$PACKAGE_FILE_NAME"
    if [ ! -d "$FOLDER"  ]; then
        mkdir -p "$FOLDER"    downloadWithWget
        echo "Creating directory for file $PACKAGE_FILE_NAME at $FOLDER"
        downloadPackage
    else
        echo "Directory $FOLDER already exist..."
    fi
}

assertFolder