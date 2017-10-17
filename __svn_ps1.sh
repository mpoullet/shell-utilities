#!/bin/bash

set -e
set -u
#set -x
SVN_PS1_SHOWDIRTYSTATE=1

### SVN ###
#
# If you want to see svn modifications:
# export SVN_PS1_SHOWDIRTYSTATE=1

# Subversion prompt function
__svn_ps1() {
    local s=
    if [ "$(__svn_info_str)" ]; then
        local r
        r="$(__svn_rev)"
        local b
        b="$(__svn_branch)"
        s=" SVN[$b:$r]"
        echo -n "$s"
    fi
}

__svn_info_str() {
  svn info --show-item wc-root 2>/dev/null
  # possibly necessary for older versions of svn that can't do wc-root:
  # svn info 2>/dev/null | grep '[A-Z]' | cut -c 1 | head -1
}

# Outputs the current trunk, branch, or tag
__svn_branch() {
    local url=
    if [ "$(__svn_info_str)" ]; then
        url=$(svn info | awk '/^Relative URL:/ {print $3}')
        echo "${url//\^\//}"
    fi
}

# Outputs the current revision
__svn_rev() {
    local r
    r=$(svn info | awk '/Revision:/ {print $2}')

    if [ ! -z "$SVN_PS1_SHOWDIRTYSTATE" ]; then
        local svnst
        svnst=$(svn status | grep '^\s*[?ACDMR?!]')
        if [ ! -z "$svnst" ]; then
            r="$r *"
        fi
    fi
    echo "$r"
}
###########

__svn_ps1
