#!/bin/bash
version=$(cat VERSION)
docker build -t "siakbary/dockergc_data:$version" -f Dockerfile .;