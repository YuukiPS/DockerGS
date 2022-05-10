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

echo OS: $os - Metode: $metode

if [ "$metode" = "start" ];then

 if [ "$os" = "local" ];then
  cd work
  java -jar grasscutter.jar
 else
  ip=$3
  ipdb=$4
  res=$5
  if [ -z "$ip" ]; then
   ip="127.0.0.1"
  fi
  if [ -z "$ipdb" ]; then
   ipdb="127.0.0.1:27017"
  fi
  if [ -z "$res" ]; then
   res="resources_gc_tes"
  fi
  docker run --env tes2=aaaa --rm -it \
  -v $res:/home/Grasscutter/resources \
  -p 22102:22102/udp \
  -p 443:443/tcp \
  siakbary/dockergc:$os-$version \
  -d "mongodb://$ipdb" \
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

  echo "Start bulid..."

  # Remove bulid stuff
  we_clean_it=$3
  removeme="bin logs resources src/generated config.json plugins .gradle"

  cd Grasscutter 

  # Windows User:
  # https://stackoverflow.com/a/49584404 & https://stackoverflow.com/a/64272135

  if [ "$we_clean_it" = "clean" ];then 
   echo "Remove file build (nofinal)"
   #./gradlew clean
   rm -R -f $removeme
  fi

  # Linux User
  # chmod +x gradlew

  echo "Update lib stuff"
  ./gradlew

  # Make jar
  echo "Make file jar..."
  ./gradlew jar

  if [ "$we_clean_it" = "clean" ];then
   echo "Remove file bulid (final)"
   rm -R -f $removeme
  fi

  # Back to home directory
  cd ..

  echo "Make folder work.."
  mkdir -p work

  echo "Copy jar file..."
  cp Grasscutter/grasscutter-*.jar work/grasscutter.jar && rm Grasscutter/grasscutter-*.jar
  echo "Copy file data & key"
  cp -r -rf VERSION Grasscutter/data Grasscutter/keys Grasscutter/keystore.p12 work/

  cd Grasscutter

  if [ "$we_clean_it" = "clean" ];then
   echo "Clean build (final)"
   ./gradlew clean
  fi

  cd ..

 else
  docker build -t "siakbary/dockergc:$os-$version" -f os_$os .;
 fi
 
fi

# if push
if [ "$metode" = "push" ];then
 docker push siakbary/dockergc:$os-$version
fi