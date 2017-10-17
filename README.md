# Shell utilities

  1. `git-author-rewrite.sh -o <old email> -n <correct name> -e <correct email>` 

  1. `__svn_ps1`
      * SVN only
      * run shellcheck on the functions
      * use `svn info` as suggested by @pestophagous
      * possible usage in combination with `__git_ps1` (tested on Ubuntu 16.04):

      ```
          GIT_PS1_SHOWCOLORHINTS=1
          GIT_PS1_SHOWUPSTREAM="verbose"
          GIT_PS1_SHOWUNTRACKEDFILES=1
          GIT_PS1_SHOWSTASHSTATE=1
          GIT_PS1_SHOWDIRTYSTATE=1
      
          SVN_PS1_SHOWDIRTYSTATE=1
          PROMPT_COMMAND='__git_ps1 "${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]" "$(__svn_ps1)\\\$ "'
      ```

## License
Copyright (c) 2017 Matthieu Poullet

This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the COPYING file for more details.
