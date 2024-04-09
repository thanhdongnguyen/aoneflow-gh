#!/bin/bash

set -e

TEMP_PATH="/tmp/gh"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "gh is only supported on macOS"
    exit 1
fi

clean() {
    echo "clean file temp"
    rm -rf 
}

download() {
    rm -rf $TEMP_PATH
    echo "installing...."
    curl https://raw.githubusercontent.com/thanhdongnguyen/aoneflow-gh/main/gh.sh >> "${TEMP_PATH}"
    chmod +x "${TEMP_PATH}"
    echo "Copy path to bin"
    sudo mv "${TEMP_PATH}" "/usr/local/bin/gh"
    echo "Copy success to bin"
}


download
clean

echo "Install gh success"
echo "Press gh to terminal"