#!/bin/bash

if [ "$1" = "sync" ];then
 cd Grasscutter
 git pull https://github.com/Grasscutters/Grasscutter.git development
 #git pull https://github.com/Akka0/Grasscutter.git tower
 cd ..
fi

if [ "$1" = "clean_work" ];then
 rm -R -f work/*
 rm -R -f .gradle/*
 rm -R -f bin/*
fi

if [ "$1" = "make" ];then
 
 cd Grasscutter 

 # Windows User:
 # https://stackoverflow.com/a/49584404 & https://stackoverflow.com/a/64272135
 #./gradlew clean

 # Remove bulid stuff
 removeme="bin logs resources src/generated config.json plugins .gradle"
 rm -R -f $removeme

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
fi

if [ "$1" = "start" ];then
 cd work
 java -jar grasscutter.jar
fi