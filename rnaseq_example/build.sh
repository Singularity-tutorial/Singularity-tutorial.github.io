#! /bin/bash
#> SYNOPSIS
#>     ./build.sh deffile imagename
set -e

function die {
    echo "$@" >&2
    exit 1
}

def_file=${1:-none}
[[ "$def_file" != "none" ]] || die "USAGE: build.sh deffile imagename size_mb"
image_name=${2:-none}
[[ "$image_name" != "none" ]] || die "USAGE: build.sh deffile imagename size_mb"
# final name of the image
image=${PWD}/${image_name}
# temp name for the image file when first created
[[ -e "$image" ]] && die "Image file already exists"

# tar was having issues with hard links and hidden files
size_mb=${3:-0}
[[ $size_mb -eq 0 ]] && die "please specify image size"
singularity create -s $size_mb $image
sudo singularity bootstrap $image $def_file

