#!/bin/bash
#set -x
set -euo pipefail

usage() {
    echo "$0 <.tap file> <dirname>"
}

if [ "$#" -ne 2 ]; then
    usage
    exit 1
fi

function abspath() {
    # https://stackoverflow.com/a/23002317/
    # generate absolute path from relative path
    # $1     : relative filename
    # return : absolute path
    if [ -d "$1" ]; then
        # dir
        (
            cd "$1"
            pwd
        )
    elif [ -f "$1" ]; then
        # file
        if [[ $1 = /* ]]; then
            echo "$1"
        elif [[ $1 == */* ]]; then
            echo "$(
                cd "${1%/*}"
                pwd
            )/${1##*/}"
        else
            echo "$(pwd)/$1"
        fi
    fi
}

# "$_" expands to the last argument to the previous command
gu-clone stable/master "$2" && cd "$_"
gu-setref --tap "$(abspath "../$1")"
gu-build --keep --kl="$(sed -ne 's/.*kl=\(\S\+\).*/\1/p;T;q' "../$1")" -t new_build @all img
