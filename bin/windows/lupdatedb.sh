#!/bin/bash

mkdir -p "${HOME}"/tmp/locate

if ! [[ -z "$1" ]]; then
    LOCATE_DIRS="$1"
else 
    lupdatedb.sh /cygdrive/c
    lupdatedb.sh /cygdrive/d
    lupdatedb.sh /cygdrive/e
fi
mkdir -p ~/tmp/locate

#get rid of `/' at the end
while [[ "${LOCATE_DIRS: -1}" == / ]]; do 
    LOCATE_DIRS="${LOCATE_DIRS: 0 : ${#LOCATE_DIRS} -1}"
done
echo updating "$LOCATE_DIRS"
/bin/updatedb --localpaths="$LOCATE_DIRS" --prunepaths='.+/.svn .+/CVS .+/tmp .+/temp' --output="${HOME}"/tmp/locate/"`gcachesum \"$LOCATE_DIRS\"`" 
