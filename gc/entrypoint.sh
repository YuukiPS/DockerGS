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

echo "$(date) - Start Server: version $version - $OSVS" #TODO: check if empty string

while getopts d:b:v:m:e:f:p: flag
do
    case "${flag}" in
        d) DBIP=${OPTARG};;
        b) IPSERVERPB=${OPTARG};;
        v) IPSERVER=${OPTARG};;
        m) msgserver=${OPTARG};;
        e) msgemail=${OPTARG};;
        f) force=${OPTARG};;
        p) proxy=${OPTARG};;
    esac
done

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

# Proxy Mode
if [ "$proxy" = "yes" ]; then
     echo "Proxy Server..."
     apt-get update && apt-get --no-install-recommends install -y python3 python3-pip && apt-get autoremove && apt-get clean
     pip3 install mitmproxy
     #sed -i "s/127.0.0.1/$IPSERVERPB/" proxy_config.py
     #sed -i "s/True/False/" proxy_config.py
     mitmdump -s proxy.py -k --allow-hosts ".*.yuanshen.com|.*.mihoyo.com|.*.hoyoverse.com" &
fi

if [ ! -f "config.json" ]; then
 # If there is no config file
 echo "No config file was found, try to use from command file"
 # get config.json
 java -jar grasscutter.jar -handbook

 # Ip private node to node
 if [ -z "$IPSERVER" ]; then
  IPSERVER=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
  echo "Server IP PRIVATE: $IPSERVER"
 else
  echo "Server IP PRIVATE: $IPSERVER"
 fi

 # ip public for user (Outside docker)
 if [ -z "$IPSERVERPB" ]; then
  IPSERVERPB=localhost
  echo "Server IP PUBLIC: $IPSERVERPB"
 else
  echo "Server IP PUBLIC: $IPSERVERPB"
 fi

 # Welcome message
 if [ -z "$msgserver" ]; then
  msgserver="Currently server run  in version $version \n\nUse !help for help\n\n~Yuuki"
 fi

 # Send Email When Registration
 if [ -z "$msgemail" ]; then
  msgemail="Hi, Thank you for registering on Yuuki Server, as a thank you to you we give you a gift, please enjoy. \nCheck out our:<type=\"browser\" text=\"Discord\" href=\"https://discord.gg/tRYMG7Nm2D\"/>\n\nThis server use <type=\"browser\" text=\"Grasscutter\" href=\"https://github.com/Grasscutters\"/>Please support them by giving stars"
 fi

 # Need database (Outside docker)
 if [ -z "$DBIP" ]; then
  echo "NO DATEBASE!"
  exit 1
 else      
  echo "Set: Server Datebase MongoDB: $DBIP"
  json -q -I -f config.json -e "this.DatabaseUrl='$DBIP'"
  json -q -I -f config.json -e "this.GameServer.DispatchServerDatabaseUrl='$DBIP'"
 fi

 # Config ip
 sed -i "s/0.0.0.0/$IPSERVER/" config.json
 json -q -I -f config.json -e "this.DispatchServer.PublicIp='$IPSERVERPB'"
 json -q -I -f config.json -e "this.GameServer.PublicIp='$IPSERVERPB'"

 # Config game
 json -q -I -f config.json -e "this.DispatchServer.defaultPermissions=['server.spawn','server.drop','player.give','player.godmode','player.clearinv','player.setstats','player.heal','player.changescene','player.givechar','player.setworldlevel','server.killall','player.giveall','player.resetconstellation']"
 json -q -I -f config.json -e "this.DispatchServer.AutomaticallyCreateAccounts='true'"

 # Config Email
 json -q -I -f config.json -e "this.GameServer.WelcomeMotd='$msgserver'"
 json -q -I -f config.json -e "this.GameServer.WelcomeMailContent='$msgemail'"
 json -q -I -f config.json -e 'this.GameServer.WelcomeMailItems=[{"itemId": 223,"itemCount": 1000,"itemLevel": 1},{"itemId": 224,"itemCount": 1000,"itemLevel": 1},{"itemId": 202,"itemCount": 1000000,"itemLevel": 1},{"itemId": 201,"itemCount": 10000,"itemLevel": 1},{"itemId": 1002,"itemCount": 1,"itemLevel": 1},{"itemId": 1066,"itemCount": 1,"itemLevel": 1},{"itemId": 1016,"itemCount": 1,"itemLevel": 1},{"itemId": 1052,"itemCount": 1,"itemLevel": 1}]'

 # [1002,1003,1005,1006,1007,1014,1015,1016,1020,1021,1022,1023,1024,1025,1026,1027,1029,1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1055,1056,1057,1058,1062,1063,1064]
 #json -I -f config.json -e "this.GameServer.Name='Yuuki'"
 #json -I -f config.json -e "this.GameServer.EnableOfficialShop=false"
 #json -I -f config.json -e "this.DispatchServer.RegionInfo.Title='German'"
 
else
 # If found config file
 echo "Found config files, ignore from command"
fi

ls

# Game Server
java -jar grasscutter.jar