#!/bin/bash
# https://gist.github.com/mpoullet/c2936060b56be394f9f04785b25d1510
#set -x
set -euo pipefail

function rinse() {
    # Clean main repo
    git clean -xfd
    # Clean all submodules
    git submodule foreach --recursive git clean -xfd
    # Reset main repo
    git reset --hard
    # Reset all submodules
    git submodule foreach --recursive git reset --hard
    # Sync main repo
    if [ -x "$(command -v hub)" ]; then
        hub sync
    else
        git fetch --prune
    fi
    # Sync all submodules
    git submodule sync --recursive
    # Update main repo
    git pull --ff-only
    # Update all submodules
    git submodule update --init --recursive
}

function lfs() {
    git rm --cached -r .
    git reset --hard
    git rm .gitattributes
    git reset .
    git checkout .
    git lfs uninstall
    git reset --hard
    git lfs install
    git lfs pull
}

function main() {
    local -r arg1=${1:-}

    if [ "${arg1}" == "lfs" ]; then
        lfs
    fi

    rinse
}

main "$@"
