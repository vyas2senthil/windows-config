#!/bin/bash
convert  -verbose -colorspace RGB -interlace none -density 300 -resize  33.3% "$1" "${1/%.pdf/.jpg}"
gimp "${1/%.pdf/.jpg}"
