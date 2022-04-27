#!/bin/bash
version=$(cat VERSION)
docker build -t "siakbary/dockergc:debian-$version" -f debian .;