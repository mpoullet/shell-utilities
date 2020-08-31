#!/bin/bash
# https://gist.github.com/mpoullet/c2936060b56be394f9f04785b25d1510
#set -x
set -euo pipefail

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
    git fetch
fi
# Sync all submodules
git submodule sync --recursive
# Update main repo
git pull --ff-only
# Update all submodules
git submodule update --init --recursive
