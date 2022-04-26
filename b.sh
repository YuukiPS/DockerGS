#!/bin/bash
version=$(cat VERSION)
docker build --build-arg version=${version} -t "siakbary/dockergc:$version" -f Dockerfile .;
#docker push siakbary/dockergc:$version