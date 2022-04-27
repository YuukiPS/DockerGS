#!/bin/bash

folder_gc="/home/Grasscutter"
folder_resources="$folder_gc/resources"

cd $folder_gc

OSVS=$(. /etc/os-release && printf '%s\n' "$NAME")
SUB="Alpine"
version=$(cat VERSION)

echo "Start server: version $version - $OSVS" #TODO: check if empty string

while getopts d:b:v:m: flag
do
    case "${flag}" in
        d) DBIP=${OPTARG};;
        b) IPSERVERPB=${OPTARG};;
        v) IPSERVER=${OPTARG};;
        m) msgserver=${OPTARG};;
    esac
done

if [ -z "$IPSERVER" ]
then
      IPSERVER=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
      echo "Server grasscutter run private $IPSERVER"
else
      # If you run grasscutter outside
      echo "Server grasscutter run private $IPSERVER"
fi

if [ -z "$IPSERVERPB" ]
then
      IPSERVERPB=localhost
      echo "Server grasscutter run public $IPSERVERPB"
else
      # If you run grasscutter outside
      echo "Server grasscutter run public $IPSERVERPB"
fi

if [ -z "$msgserver" ]
then
      msgserver="Hi, Welcome to Yuuki Server and thank Grasscutter Team for making this emulator we like you guys, please enjoy :). Currently running on server version $version"
fi

#TODO cek config

if [ ! -f "config.json" ]; then
 echo "create table id and config.json"
 java -jar grasscutter.jar -handbook
fi

if [ -z "$DBIP" ]
then
      echo "Server datebase run at localhost"
else
      # If you have a database outside
      echo "Set: Server Datebase MongoDB: $DBIP"
      json -I -f config.json -e "this.DatabaseUrl='$DBIP'"
      #json -I -f config.json -e "this.GameServer.DispatchServerDatabaseUrl='$DBIP'"
fi

# Config ip
sed -i "s/0.0.0.0/$IPSERVER/" config.json
json -I -f config.json -e "this.DispatchServer.PublicIp='$IPSERVERPB'"
json -I -f config.json -e "this.GameServer.PublicIp='$IPSERVERPB'"

# Config game
# json -I -f config.json -e "this.DispatchServer.UseSSL='false'"
json -I -f config.json -e "this.DispatchServer.AutomaticallyCreateAccounts='true'"
json -I -f config.json -e "this.GameServer.WelcomeMotd='$msgserver'"

json -I -f config.json -e "this.GameServer.Name='Yuuki|German'"
#json -I -f config.json -e "this.DispatchServer.RegionInfo.Title='German'"

java -jar grasscutter.jar