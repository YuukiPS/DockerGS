#!/bin/sh

folder_gc="/home/Grasscutter"
folder_resources="$folder_gc/resources"
update=false
timems=date

cd $folder_gc

OSVS=$(. /etc/os-release && printf '%s\n' "$NAME")
SUB="Alpine"
version=$(cat VERSION)
version_res="main"

echo $version

# Switch RS
if echo "$version" | grep -q "2.6"; then
 echo "Use res 2.6"
 version_res="2.6"
elif echo "$version" | grep -q "2.7"; then
 echo "Use res 2.7"
 version_res="2.7"
elif echo "$version" | grep -q "2.8"; then
 echo "Use res 2.8"
 version_res="2.8"
fi

# Time Server
if [ "$OSVS" = "Ubuntu" ]; then
  mv /etc/localtime /etc/localtime-old
  ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
fi

echo "This system run with OS $OSVS"

while getopts d:b:g:p:m:e:f:j:l:s:o:r:u: flag
do
    case "${flag}" in
        # server datebase and config ip
        d) DBIP=${OPTARG};;
        b) IPSERVERPB=${OPTARG};;
        g) IPGAME=${OPTARG};;
        p) IPPORTGAME=${OPTARG};;
        # msg server
        m) msgserver=${OPTARG};;
        e) msgemail=${OPTARG};;
        # force update resources
        f) force=${OPTARG};;
        # java stuff limiting ram
        j) JAVA_OPTS=${OPTARG};;
        # language server
        l) lang=${OPTARG};;
        # for server name
        s) name_server=${OPTARG};;
        o) name_owner=${OPTARG};;
        r) name_region=${OPTARG};;
        u) useronline=${OPTARG};;
    esac
done

# JVM sets its heap size to approximately 25% of the available RAM. In this example, it allocated 4GB on a system with 16GB. (-Xms50M -Xmx1G)
if [ -z "$JAVA_OPTS" ]; then
 JAVA_OPTS=""
fi

# Building Data Source and Generated Resources
if [ -d "$folder_resources/BinOutput" ] 
then
    ls $folder_resources
    echo "Resources folder already exists..."
else
    echo "Update?"
    update=true
fi

# Foce Mode
if [ "$force" = "yes" ]; then
     echo "Update"
     update=true
fi
if [ "$force" = "no" ]; then
     echo "skip"
     update=false
fi

if $update
then

   id
   ls -l $folder_gc

   git clone -b $version_res https://gitlab.com/yukiz/GrasscutterResources.git
   cp -rf GrasscutterResources/Resources/* $folder_resources
   rm -R -f GrasscutterResources
fi

if [ ! -f "config.json" ]; then

 # If there is no config file
 echo "No config file was found, try to use from command file"

 # languages
 if [ -z "$lang" ]; then
  lang="en_US"
 fi

 # online
 if [ -z "$useronline" ]; then
  useronline="-1"
 fi

 # Nama Server
 if [ -z "$name_server" ]; then
  name_server="YuukiPS"
 fi

 # Nama Owner
 if [ -z "$name_owner" ]; then
  name_owner="Ayaka"
 fi

 # Region
 if [ -z "$name_region" ]; then
  name_region="localhost"
 fi

 # if no config just boot
 java -jar grasscutter.jar -boot

 # ip/domain public for web (Outside docker)
 if [ -z "$IPSERVERPB" ]; then
  IPSERVERPB=localhost  
 fi
 echo "Server Web Public: $IPSERVERPB"

 # ip public for game (Outside docker)
 if [ -z "$IPGAME" ]; then
  IPGAME=$IPSERVERPB
 fi

 echo "Server Ip Game: $IPGAME"

 # Ip game port
 if [ -z "$IPPORTGAME" ]; then
  IPPORTGAME="22102"
 fi

 echo "Server Game Port: $IPPORTGAME"

 # Welcome message
 if [ -z "$msgserver" ]; then
  msgserver="Welcome to $name_server\n\nUse !help for help\n\nRegion: $name_region\nCommunity: discord.yuuki.me"
 fi

 # Send Email When Registration
 if [ -z "$msgemail" ]; then
  msgemail="Hi, Thank you for registering on Yuuki Server, as a sign of gratitude for you we give gifts, you can also get more gifts with /give all on console, please visit us for help and type !help for more info.<type=\"browser\" text=\"Discord\" href=\"https://discord.yuuki.me\"/>"
 fi

 # Need database (Outside docker)
 if [ -z "$DBIP" ]; then
  echo "No Datebase? exit!"
  exit 1
 else      
  echo "Server MongoDB: $DBIP"
  json -q -I -f config.json -e "this.databaseInfo.server.connectionUri='$DBIP'"
  json -q -I -f config.json -e "this.databaseInfo.game.connectionUri='$DBIP'"
 fi

 # Config IP Game
 json -q -I -f config.json -e "this.server.game.accessAddress='$IPGAME'"
 json -q -I -f config.json -e "this.server.game.bindPort='$IPPORTGAME'" 

 # Config Game Web
 json -q -I -f config.json -e "this.server.http.accessAddress='$IPSERVERPB'"

 # Config Language Server
 json -q -I -f config.json -e "this.language.language='$lang'"

 # Config max number of player online
 json -q -I -f config.json -e "this.account.maxPlayer='$useronline'"

 # Config Welcome Message
 json -q -I -f config.json -e "this.server.game.joinOptions.welcomeMessage='$msgserver'"

 # Config Welcome Email
 json -q -I -f config.json -e "this.server.game.joinOptions.welcomeMail.title='Welcome to $name_server'"
 json -q -I -f config.json -e "this.server.game.joinOptions.welcomeMail.sender='$name_owner'"
 json -q -I -f config.json -e "this.server.game.joinOptions.welcomeMail.content='$msgemail'"

 # Config Console
 json -q -I -f config.json -e "this.server.game.serverAccount.signature='Console $name_server ($name_region)'"
 json -q -I -f config.json -e "this.server.game.serverAccount.nickName='$name_owner'"

else
 # If found config file (maybe restart?)
 echo "Found config files, ignore from command"
 rm -R -f logs/*
fi

# Game Server
java $JAVA_OPTS -jar grasscutter.jar