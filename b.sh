#!/bin/bash
version="dev-1.8"
docker build -t "siakbary/dockergc:$version" -f Dockerfile .;
docker push siakbary/dockergc:$version