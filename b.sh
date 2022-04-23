#!/bin/bash
version="dev-2.0"
docker build -t "siakbary/dockergc:$version" -f Dockerfile .;
#docker push siakbary/dockergc:$version