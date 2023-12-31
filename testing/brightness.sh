#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE:-}" ]]; then
    set -o xtrace
fi

# This script is used to test the brightness of lights in a room with a given
# sun elevation.

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <sun_elevation> <on> <off>"
    exit 1
fi

bmax=100
bmin=0
eon=$2
eoff=$3
erange=$((eoff - eon))
ecurr=$1

if [[ $ecurr -lt $eon ]]; then
    echo "on"
    echo $bmax
    exit 0
elif [[ $ecurr -gt $eoff ]]; then
    echo "off"
    echo $bmin
    exit 0
else
    echo "the inbetween"
    factor=$(bc -l <<< "1 - (($ecurr - $eon) / $erange)")
    echo "factor: $factor"
    value=$(bc -l <<< "$factor * $bmax")
    echo "value: $value"
    exit 0
fi