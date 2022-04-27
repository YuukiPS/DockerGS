#!/bin/bash
version=$(cat VERSION)
docker build -t "siakbary/dockergc:alpine-$version" -f alpine .;