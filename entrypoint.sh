#!/bin/bash
# docker run -e BOT="false" -e DEBUG_BOT="true" -e NOTIF="false" -e DEBUG_NOTIF="true" -e DEBUG_LIVE="true" -e DEBUG_LIVE_MORE="false" --rm -it -p 3000:3000/tcp repo.volcanoyt.com/vyt_early:last

while getopts d:b:v: flag
do
    case "${flag}" in
        d) DBIP=${OPTARG};;
        b) IPSERVERPB=${OPTARG};;
        v) IPSERVER=${OPTARG};;
    esac
done

if [ -z "$DBIP" ]
then
      echo "Server datebase run at localhost"
else
      # If you have a database outside
      sed -i "s/localhost:27017/$DBIP/" config.json
      echo "Server datebase: $DBIP"
fi

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
      echo "Server grasscutter run publik $IPSERVERPB"
fi

sed -i "s/127.0.0.1/$IPSERVER/" config.json

# Public ip stuff
json -I -f config.json -e "this.DispatchServerPublicIp='$IPSERVERPB'"
json -I -f config.json -e "this.GameServerPublicIp='$IPSERVERPB'"

java -jar grasscutter.jar