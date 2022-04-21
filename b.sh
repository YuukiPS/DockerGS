#!/bin/bash
version="dev-1.6"
docker build -t "siakbary/dockergc:$version" -f Dockerfile .;
#docker push siakbary/dockergc:$version