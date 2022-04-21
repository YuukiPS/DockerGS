#!/bin/bash
cd Grasscutter
version="dev-1.7";
update=false
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
if [ -d "resources" ] 
then
    echo "The resources folder already exists..."
    if [ $force = "yes" ]; then
     echo "But keep update it"
     update=true
    fi
    # TODO: check vaild file and update maybe next time? 
else
    update=true
fi

if $update
then 
    mkdir install && cd install 
    echo "Clone time..."
    git clone https://github.com/Dimbreath/GenshinData
    git clone https://github.com/radioegor146/gi-bin-output
    cd ..
    mkdir -p resources/BinOutput
    echo "Copy file 2.5"
    cp -rf install/gi-bin-output/2.2/Data/_BinOutput/*      resources/BinOutput
    cp -rf install/gi-bin-output/2.5.52/Data/_BinOutput/*   resources/BinOutput
    echo "Copy file 2.6"
    cp -rf install/GenshinData/*                            resources
    echo "Copy file missing"
    cp -rf missing/*                                        resources/ExcelBinOutput    
fi

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
fi

# Config ip
sed -i "s/0.0.0.0/$IPSERVER/" config.json
json -I -f config.json -e "this.DispatchServer.PublicIp='$IPSERVERPB'"
json -I -f config.json -e "this.GameServer.PublicIp='$IPSERVERPB'"

# Config game
json -I -f config.json -e "this.DispatchServer.AutomaticallyCreateAccounts='true'"
json -I -f config.json -e "this.GameServer.WelcomeMotd='$msgserver'"

json -I -f config.json -e "this.GameServer.Name='Yuuki|German'"
#json -I -f config.json -e "this.DispatchServer.RegionInfo.Title='German'"

#ls

java -jar grasscutter.jar