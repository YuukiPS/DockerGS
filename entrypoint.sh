#!/bin/bash

version="dev-2.3";
update=false

folder_gc="/home/Grasscutter"
folder_resources="$folder_gc/resources"

cd $folder_gc

while getopts d:b:v:m:f: flag
do
    case "${flag}" in
        d) DBIP=${OPTARG};;
        b) IPSERVERPB=${OPTARG};;
        v) IPSERVER=${OPTARG};;
        m) msgserver=${OPTARG};;
        f) force=${OPTARG};;
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

# Building Data Source and Generated Resources
if [ -d "$folder_resources" ] 
then
    echo "Resources folder already exists..."
    if [ $force = "yes" ]; then
     echo "But keep update it"
     update=true
    fi
    # TODO: check vaild file and update maybe next time? 
else
    update=true
fi

CP() {
    mkdir -p $(dirname "$2") && cp -rf "$1" "$2"
}

if $update
then 
    apk add --no-cache git wget
    mkdir install && cd install 
    echo "Clone time..."
    GSDATA="https://github.com/Dimbreath/GenshinData"
    git clone $GSDATA
    git clone https://github.com/radioegor146/gi-bin-output
    git clone https://github.com/Grasscutters/Grasscutter-Protos
    echo "Copy file Protos"
    mkdir -p $folder_gc/proto && cp -rf Grasscutter-Protos/proto/*                         $folder_gc/proto
    echo "Copy file 2.5"
    mkdir -p $folder_resources/BinOutput && cp -rf gi-bin-output/2.2/Data/_BinOutput/*     $folder_resources/BinOutput
                                            cp -rf gi-bin-output/2.5.52/Data/_BinOutput/*  $folder_resources/BinOutput
    echo "Copy file 2.6"
    mkdir -p $folder_resources/TextMap &&        cp -rf GenshinData/TextMap/*              $folder_resources/TextMap
    mkdir -p $folder_resources/Subtitle &&       cp -rf GenshinData/Subtitle/*             $folder_resources/Subtitle
    mkdir -p $folder_resources/Readable &&       cp -rf GenshinData/Readable/*             $folder_resources/Readable
    mkdir -p $folder_resources/ExcelBinOutput && cp -rf GenshinData/ExcelBinOutput/*       $folder_resources/ExcelBinOutput
                                                 cp -rf GenshinData/BinOutput/*            $folder_resources/BinOutput
    echo "Copy file miss (fix main stats and sub stats by switch branches)"
    id_main_stats="104c21c6530885e450975b13830639e9ca649799"
    id_sub_stats="a92b5842daa911c095f47ef235b2bcd4b388d65a"
    wget --backups=1 $GSDATA/raw/$id_main_stats/ExcelBinOutput/ReliquaryMainPropExcelConfigData.json -P $folder_resources/ExcelBinOutput/
    wget --backups=1 $GSDATA/raw/$id_sub_stats/ExcelBinOutput/ReliquaryAffixExcelConfigData.json -P $folder_resources/ExcelBinOutput/
    echo "remove file no need"
    rm -R -f *
    apk del git wget
    cd ..
fi

ls

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