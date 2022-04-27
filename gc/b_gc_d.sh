#!/bin/bash
version=$(cat VERSION)
docker build -t "siakbary/dockergc:debian-$version" -f debian .;
if [ "$1" == "push" ];then
 docker push siakbary/dockergc:debian-$version
fi