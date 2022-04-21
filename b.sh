#!/bin/bash
version="dev-1.7"
docker build -t "siakbary/dockergc:$version" -f Dockerfile .;
#docker push siakbary/dockergc:$version