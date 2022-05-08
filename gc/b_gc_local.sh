#!/bin/bash

if [ "$1" = "sync" ];then
 cd Grasscutter
 git pull https://github.com/Grasscutters/Grasscutter.git development
 #git pull https://github.com/Akka0/Grasscutter.git tower
 cd ..
fi

if [ "$1" = "make" ];then
 cd Grasscutter

 # Clean modul
 ./gradlew clean

 # Make jar
 ./gradlew jar

 # Back to home directory
 cd ..

 # Make work file
 mkdir -p work

 # Copy jar (onlu need data and key)
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