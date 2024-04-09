#!/bin/bash

set -e

TEMP_PATH="/tmp/gh"
BIN_PATH="/usr/local/bin/gh"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "gh is only supported on macOS"
    exit 1
fi

clean() {
    echo "Clean file temp"
    rm -rf 
}

check_exist() {
    if [[ -f "$BIN_PATH" ]]; then
        echo "Remove gh existed"
        rm -rf "${BIN_PATH}"
    fi
}

download() {
    rm -rf $TEMP_PATH
    curl -sL https://raw.githubusercontent.com/thanhdongnguyen/aoneflow-gh/main/gh.sh >> "${TEMP_PATH}"
    chmod +x "${TEMP_PATH}"
    echo "Copy path to bin"
    sudo mv "${TEMP_PATH}" "${BIN_PATH}"
    echo "Copy success to bin"
}

check_exist
download
clean

echo "Install gh success"
echo "Press gh to terminal"