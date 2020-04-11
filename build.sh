#!/usr/bin/env bash

gb="$1"
printf 'assembling...\n' 
rgbasm "$gb".asm -o "$gb".o
printf 'linking...\n'
rgblink "$gb".o -o "$gb".gb
printf 'fixing...\n'
rgbfix -v -p0 "$gb".gb
