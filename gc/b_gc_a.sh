#!/bin/bash
sh b_gc_local.sh make
version=$(cat work/VERSION)
docker build -t "siakbary/dockergc:alpine-$version" -f alpine .;
if [ "$1" = "push" ];then
 docker push siakbary/dockergc:alpine-$version
fi