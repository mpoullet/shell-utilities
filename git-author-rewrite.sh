#!/bin/bash

# Based on https://gist.github.com/octocat/0831f3fbd83ac4d46451#file-git-author-rewrite-sh

#set -x
set -e
set -u

usage() {
    echo "$0 -o <old email> -n <correct name> -e <correct email>"
}

if [ "$#" -ne 6 ]; then
   usage
   exit 1
fi

while getopts ":o:n:e:" opt; do
    case $opt in
        o)
            echo "OLD_EMAIL=$OPTARG" >&2
            OLD_EMAIL=$OPTARG
            ;;
        n)
            echo "CORRECT_NAME=$OPTARG" >&2
            CORRECT_NAME=$OPTARG
            ;;
        e)
            echo "CORRECT_EMAIL=$OPTARG" >&2
            CORRECT_EMAIL=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            exit 1
            ;;
    esac
done

FILTER="
    OLD_EMAIL=\"${OLD_EMAIL}\"
    CORRECT_NAME=\"${CORRECT_NAME}\"
    CORRECT_EMAIL=\"${CORRECT_EMAIL}\"
"

FILTER+='
    if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
    then
        export GIT_COMMITTER_NAME="$CORRECT_NAME"
        export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
    fi
    
    if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
    then
        export GIT_AUTHOR_NAME="$CORRECT_NAME"
        export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
    fi
'

git filter-branch -f --env-filter "${FILTER}" --tag-name-filter cat -- --branches --tags
