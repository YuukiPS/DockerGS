#!/bin/bash
version="dev-entity-2.4"
docker build -t "siakbary/dockergc:$version" -f Dockerfile .;
docker push siakbary/dockergc:$version