#!/bin/bash
version="dev-entity-2.5"
docker build --build-arg version=${version} -t "siakbary/dockergc:$version" -f Dockerfile .;
#docker push siakbary/dockergc:$version