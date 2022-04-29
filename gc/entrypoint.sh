#!/bin/sh

folder_gc="/home/Grasscutter"
folder_resources="$folder_gc/resources"
update=false
timems=date

cd $folder_gc

OSVS=$(. /etc/os-release && printf '%s\n' "$NAME")
SUB="Alpine"
version=$(cat VERSION)

# Time Server
mv /etc/localtime /etc/localtime-old
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 

echo "$(date) - Start server: version $version - $OSVS" #TODO: check if empty string

while getopts d:b:v:m:e:f: flag
do
    case "${flag}" in
        d) DBIP=${OPTARG};;
        b) IPSERVERPB=${OPTARG};;
        v) IPSERVER=${OPTARG};;
        m) msgserver=${OPTARG};;
        e) msgemail=${OPTARG};;
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
      msgserver="Currently running on server version $version , Use !help for help ~ Yuuki"
fi

if [ -z "$msgemail" ]
then
      msgemail="Hi, Thank you for registering on Yuuki Server, as a thank you to you we give you a gift, please enjoy. \r\n\r\nCheck out our:<type=\"browser\" text=\"Discord\" href=\"https://discord.gg/tRYMG7Nm2D\"/>\r\n\r\nThis server use <type=\"browser\" text=\"Grasscutter\" href=\"https://github.com/Grasscutters\"/>Please support them by giving stars"
fi

# Building Data Source and Generated Resources
if [ -d "$folder_resources" ] 
then
    echo "Resources folder already exists..."
    if [ "$force" = "yes" ]; then
     echo "But keep update it"
     update=true
    fi
    # TODO: check vaild file and update maybe next time? 
else
    update=true
fi

if $update
then 
   git clone https://gitlab.com/akbaryahya91/dockergc-data.git
   ls
   cp -rf dockergc-data/resources/* resources   
   rm -R -f dockergc-data ls
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
      #json -I -f config.json -e "this.GameServer.DispatchServerDatabaseUrl='$DBIP'"
fi

# Config ip
sed -i "s/0.0.0.0/$IPSERVER/" config.json
json -I -f config.json -e "this.DispatchServer.PublicIp='$IPSERVERPB'"
json -I -f config.json -e "this.GameServer.PublicIp='$IPSERVERPB'"

# Config game
json -I -f config.json -e "this.DispatchServer.defaultPermissions=['server.spawn','server.drop','player.give','player.godmode','player.clearinv','player.setstats','player.heal','player.changescene','player.givechar','player.setworldlevel','server.killall','player.giveall','player.resetconstellation']"
#json -I -f config.json -e "this.DispatchServer.AutomaticallyCreateAccounts='true'"
json -I -f config.json -e "this.GameServer.WelcomeMotd='$msgserver'"

#json -I -f config.json -e "this.GameServer.Name='Yuuki'"
#json -I -f config.json -e "this.GameServer.EnableOfficialShop=false"
json -I -f config.json -e "this.GameServer.WelcomeMailContent='$msgemail'"
#json -I -f config.json -e "this.GameServer.WelcomeMailItems=[1002,1003,1005,1006,1007,1014,1015,1016,1020,1021,1022,1023,1024,1025,1026,1027,1029,1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1055,1056,1057,1058,1062,1063,1064]"
#json -I -f config.json -e "this.DispatchServer.RegionInfo.Title='German'"
#cat config.json

# Game Server
java -jar grasscutter.jar