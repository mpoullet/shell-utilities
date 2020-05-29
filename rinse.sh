#!/bin/bash
# https://gist.github.com/mpoullet/c2936060b56be394f9f04785b25d1510
#set -x
set -euo pipefail

git clean -xfd
git submodule foreach --recursive git clean -xfd
git reset --hard
git submodule foreach --recursive git reset --hard
git submodule update --init --recursive
if [ -x "$(command -v hub)" ]; then
    hub sync
fi
