#!/bin/sh
#
# @(#)$Id: chkhdr.sh,v 1.2 2010/04/24 16:52:59 jleffler Exp $
#
# Check whether a header can be compiled standalone

# URL: https://stackoverflow.com/a/1892332/496459

set -e
set -u
set -x

tmp=chkhdr-$$
trap 'rm -f $tmp.?; exit 1' 0 1 2 3 13 15

cat >$tmp.c <<EOF
#include HEADER /* Check self-containment */
#include HEADER /* Check idempotency */
int main(void){return 0;}
EOF

options=
for file in "$@"
do
    case "$file" in
    (-*)    options="$options $file";;
    (*)     echo "$file:"
            gcc "$options" -DHEADER="\"$file\"" -c $tmp.c
            ;;
    esac
done

rm -f $tmp.?
trap 0
