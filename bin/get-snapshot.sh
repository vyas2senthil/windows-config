#!/bin/bash
set -e
cd ${1:-.}

ignore_pat='\.~.*#$'
newest=$(ls -t -A | grep -v -e "$ignore_pat" | head -n 1)
readlink -m "$newest"
mp >/dev/null 2>&1 "$newest" </dev/null
