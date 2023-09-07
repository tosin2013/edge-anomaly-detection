#!/bin/bash

## checkForProgramAndInstallOrExit detects binaries available in the system path, if not available installs it
function checkForProgramAndInstallOrExit() {
    command -v $1 > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        printf '  %-72s %-7s\n' $1 "PASSED!";
    else
        printf '  %-72s %-7s\n' $1 "NOT FOUND!";
        echo "    Attempting to install $1 via $2..."
        sudo dnf install -yq $2
        if [[ $? -eq 0 ]]; then
            printf '  %-72s %-7s\n' $1 "PASSED!";
        else
            printf '  %-72s %-7s\n' $1 "FAILED!";
            echo -e "\n  Missing required $1 binary and unable to install!\n";
            exit 1
        fi
    fi
}