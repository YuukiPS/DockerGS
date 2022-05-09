#!/bin/bash

runit="local"
version=$(cat VERSION)
os=$1
metode=$2

# select os
if [ -z "$os" ]; then
 os="local"
fi

# select metode
if [ -z "$metode" ]; then
 metode="build"
fi

if [ "$metode" = "start" ];then

 if [ "$os" = "local" ];then
  cd work
  java -jar grasscutter.jar
 else
  ip=$3
  res=$4
  if [ -z "$ip" ]; then
   ip="127.0.0.1"
  fi
  if [ -z "$res" ]; then
   res="resources_gc_tes"
  fi
  docker run --env tes2=aaaa --rm -it \
  -v $res:/home/Grasscutter/resources \
  -p 22102:22102/udp \
  -p 443:443/tcp \
  siakbary/dockergc:$os-$version \
  -d "mongodb://$ip:27017" \
  -b "$ip"
 fi

fi

# if clean
if [ "$metode" = "clean_work" ];then
 rm -R -f work/*
 rm -R -f .gradle/*
 rm -R -f bin/*
fi

# if sync
if [ "$metode" = "sync" ];then
 cd Grasscutter
 git pull https://github.com/Grasscutters/Grasscutter.git development
 #git pull https://github.com/Akka0/Grasscutter.git tower
 cd ..
fi

# if build
if [ "$metode" = "build" ];then
 
 # if localhost
 if [ "$os" = "local" ];then

  cd Grasscutter 

  # Windows User:
  # https://stackoverflow.com/a/49584404 & https://stackoverflow.com/a/64272135
  #./gradlew clean

  # Remove bulid stuff
  removeme="bin logs resources src/generated config.json plugins .gradle"
  rm -R -f $removeme

  # Linux User
  # chmod +x gradlew

  # generated proto and lib
  ./gradlew

  # Make jar
  ./gradlew jar

  # try remove bulid
  rm -R -f $removeme

  # Back to home directory
  cd ..

  # Make work file
  mkdir -p work

  # Copy jar (only need data and key)
  cp Grasscutter/grasscutter-*.jar work/grasscutter.jar && rm Grasscutter/grasscutter-*.jar
  cp -r -rf VERSION Grasscutter/data Grasscutter/keys Grasscutter/keystore.p12 work/

  # Clean modul
  cd Grasscutter
  ./gradlew clean
  cd ..

 else
  docker build -t "siakbary/dockergc:$os-$version" -f os_$os .;
 fi
 
fi

# if push
if [ "$metode" = "push" ];then
 docker push siakbary/dockergc:$os-$version
fi