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
if [ "$OSVS" = "Ubuntu" ]; then
  mv /etc/localtime /etc/localtime-old
  ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
fi

echo "This system run with OS $OSVS"

while getopts d:b:v:m:e:f:j:l:s:o:r: flag
do
    case "${flag}" in
        # server datebase and config ip
        d) DBIP=${OPTARG};;
        b) IPSERVERPB=${OPTARG};;
        v) IPSERVER=${OPTARG};;
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
    esac
done 

#  JVM sets its heap size to approximately 25% of the available RAM. In this example, it allocated 4GB on a system with 16GB.
if [ -z "$JAVA_OPTS" ]; then
 JAVA_OPTS="-Xms100M -Xmx10G"
 java -XX:+PrintFlagsFinal -version | grep -iE 'HeapSize|PermSize|ThreadStackSize'
fi

# Building Data Source and Generated Resources
if [ -d "$folder_resources/BinOutput" ] 
then
    echo "Resources folder already exists..."
else
    echo "Update?"
    update=true
fi
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
   rm -R -f resources/*
   git clone https://github.com/Koko-boya/Grasscutter_Resources
   cp -rf Grasscutter_Resources/Resources/* resources
   #chmod -R 775 resources
   rm -R -f Grasscutter_Resources
fi

# Check Folder Data
if [ ! -f "data/Drop.json" ]; then
 echo "No found folder Data (You can costume this later by mount folder)"
 git clone https://gitlab.com/yukiz/grasscutter-data
 cp -rf grasscutter-data/data/* data
 rm -R -f grasscutter-data
fi

if [ ! -f "config.json" ]; then
 # If there is no config file
 echo "No config file was found, try to use from command file"

 # languages
 if [ -z "$lang" ]; then
  lang="en_US"
 fi

 # Nama Server
 if [ -z "$name_server" ]; then
  name_server="Yuuki"
 fi

 # Nama Owner
 if [ -z "$name_owner" ]; then
  name_owner="Yuuki"
 fi

 # Region
 if [ -z "$name_region" ]; then
  name_region="Yuuki"
 fi

 # if no config just boot
 java -jar grasscutter.jar -boot
 
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
  msgserver="Welcome to Server $name_server\n\nUse !help for help\n\n~Yuuki"
 fi

 # Send Email When Registration
 if [ -z "$msgemail" ]; then
  msgemail="Hi, Thank you for registering on Yuuki Server, as a sign of gratitude for you we give gifts, you can also get more gifts with !giveall on console, please visit us for help and type !help for more info.<type=\"browser\" text=\"Discord\" href=\"https://discord.gg/tRYMG7Nm2D\"/>"
 fi

 # Need database (Outside docker)
 if [ -z "$DBIP" ]; then
  echo "No Datebase? exit!"
  exit 1
 else      
  echo "Server IP SERVER MongoDB: $DBIP"
  json -q -I -f config.json -e "this.databaseInfo.server.connectionUri='$DBIP'"
  json -q -I -f config.json -e "this.databaseInfo.game.connectionUri='$DBIP'"
 fi

 # Config ip
 json -q -I -f config.json -e "this.server.game.bindAddress='$IPSERVER'"
 json -q -I -f config.json -e "this.server.game.accessAddress='$IPSERVERPB'"
 json -q -I -f config.json -e "this.server.dispatch.bindAddress='$IPSERVER'"
 json -q -I -f config.json -e "this.server.dispatch.accessAddress='$IPSERVERPB'"

 # Config Game
 json -q -I -f config.json -e "this.language.language='$lang'"

 # Config Welcome Message
 json -q -I -f config.json -e "this.server.game.joinOptions.welcomeMessage='$msgserver'"

 # Config Welcome Email
 json -q -I -f config.json -e "this.server.game.joinOptions.welcomeMail.title='Welcome to Server $name_server'"
 json -q -I -f config.json -e "this.server.game.joinOptions.welcomeMail.sender='$name_owner'"
 json -q -I -f config.json -e "this.server.game.joinOptions.welcomeMail.content='$msgemail'"

else
 # If found config file (maybe restart?)
 echo "Found config files, ignore from command"
 rm -R -f logs/*
fi

#ls
#cat config.json

# Game Server
java -jar grasscutter.jar $JAVA_OPTS