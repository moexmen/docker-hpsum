#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Desc: This script downloads only the firmware from HPE's Software Delivery Repo"
  echo "Usage:"
  echo "1. Update the 'src_url' variable in the shell script"
  echo "2. Run '$0 dst_dir' where 'dst_dir' is the destination folder"
  exit
fi

#### Config
## Update this config
src_url="http://downloads.linux.hpe.com/SDR/repo/spp-gen9/2018.09.0/packages/"

#### Main
dst_dir="$1"

## chdir to destination dir
[[ -d "$dst_dir" ]] || mkdir -p "$dst_dir"
cd "$dst_dir"

## Get URLs
echo "+ Retrieving URLs"
hrefs=$(wget -qO - "$src_url" | egrep -o 'href="[^"]+"' | sort | uniq)

## Filter the firmware and its .compsig files
firmware=$(egrep -o '[^"]*firmware-[^"]+\.[^"]+' <<< "$hrefs")

## Download firmware
file_count=$(wc -l <<< "$firmware" | egrep -o "[0-9]+")
echo "+ Downloading $file_count firmware files"
wget -c --base="$src_url" -i - <<< "$firmware"
