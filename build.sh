#!/usr/bin/env bash

gb="$1"

[[ "$gb" == "" ]] && {
    printf 'requires an argument\n'
    exit 0
}

printf 'assembling...\n' 
rgbasm "$gb".asm -o "$gb".o
printf 'linking...\n'
rgblink "$gb".o -o "$gb".gb
printf 'fixing...\n'
rgbfix -v -p0 "$gb".gb

printf 'emulate? y/n\n'
read -rsn1 emu

[[ "$emu" == "y" ]] && {
    ~/downloads/sameboy/SameBoy-0.12.3/build/bin/SDL/sameboy \
    "$gb".gb
}
