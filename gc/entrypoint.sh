#!/bin/sh

help()
{
    echo "Usage: TODO"
    exit 2
}

SHORT=db:,webip:,webport:,weburlssl:,gameip:,gameport:,msgwc,mailmsg:,dlres:,j:,lang:,loginpass:,po:,nmsv:,nmow:,nmrg:,ssl:,tk:,h
LONG=datebase:,web_ip:,web_port:,web_url_ssl:,game_ip:,game_port:,message_welcome:,mail_message:,download_resource:,java:,language:,login_password:,player_online:,name_server:,name_owner:,name_region:,ssl:,token:,help
OPTS=$(getopt -a -n dockergc --options $SHORT --longoptions $LONG -- "$@")

VALID_ARGUMENTS=$# # Returns the count of arguments that are in short or long options

if [ "$VALID_ARGUMENTS" -eq 0 ]; then
  help
fi

eval set -- "$OPTS"

while :
do
  case "$1" in
    # Server Datebase & Ip Config
    -db | --datebase )
      set_datebase="$2"
      shift 2
      ;;
    -webip | --web_ip )
      set_web_ip="$2"
      shift 2
      ;;
    -webport | --web_port )
      set_web_port="$2"
      shift 2
      ;;
    -weburlssl | --web_url_ssl )
      set_web_url_ssl="$2"
      shift 2
      ;;
    -ssl | --ssl )
      set_ssl="$2"
      shift 2
      ;;
    -gameip | --game_ip )
      set_game_ip="$2"
      shift 2
      ;;
    -gameport | --game_port )
      set_game_port="$2"
      shift 2
      ;;
    # Server Setup
    -dlres | --download_resource )
      set_download_resource="$2"
      shift 2
      ;;
    -j | --java )
      set_java="$2"
      shift 2
      ;;
    -lang | --language )
      set_language="$2"
      shift 2
      ;;
    -loginpass | --login_password )
      set_login_password="$2"
      shift 2
      ;;
    -po | --player_online )
      set_player_online="$2"
      shift 2
      ;;
    -tk | --token )
      set_token="$2"
      shift 2
      ;;
    # Owner Server
    -nmsv | --name_server )
      set_name_server="$2"
      shift 2
      ;;
    -nmow | --name_owner )
      set_name_owner="$2"
      shift 2
      ;;
    -nmrg | --name_region )
      set_name_region="$2"
      shift 2
      ;;
    # Message Server
    -msgwc | --message_welcome )
      set_message_welcome="$2"
      shift 2
      ;;
    # Mail Message
    -mailmsg | --mail_message )
      set_mail_message="$2"
      shift 2
      ;;
    # Help
    -h | --help)
      help
      ;;
    --)
      shift;
      break
      ;;
    *)
      echo "Unexpected option: $1"
      help
      ;;
  esac
done

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

# JVM sets its heap size to approximately 25% of the available RAM. In this example, it allocated 4GB on a system with 16GB. (-Xms50M -Xmx1G)
if [ -z "$set_java" ]; then
 set_java=""
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
if [ "$set_download_resource" = "yes" ]; then
     echo "Update"
     update=true
fi
if [ "$set_download_resource" = "no" ]; then
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
 if [ -z "$set_language" ]; then
  set_language="en_US"
 fi

 # online
 if [ -z "$set_player_online" ]; then
  set_player_online="-1"
 fi

 # Nama Server
 if [ -z "$set_name_server" ]; then
  set_name_server="YuukiPS"
 fi

 # Token Server aka Super Admin
 if [ -z "$set_token" ]; then
  set_token="melon"
 fi

 # Nama Owner
 if [ -z "$set_name_owner" ]; then
  set_name_owner="Ayaka"
 fi

 # Region
 if [ -z "$set_name_region" ]; then
  set_name_region="localhost"
 fi

 # SSL
 if [ -z "$set_ssl" ]; then
  set_ssl="false"
 fi

 # URL SSL
 if [ -z "$web_url_ssl" ]; then
  web_url_ssl="false"
 fi

 # if no config just boot
 java -jar grasscutter.jar -boot

 # ip/domain public for web (Outside docker)
 if [ -z "$set_web_ip" ]; then
  set_web_ip=localhost  
 fi

 # Ip web port
 if [ -z "$set_web_port" ]; then
  set_web_port="80"
 fi

 echo "Server Web Public: $set_web_ip:$set_web_port"
 echo "URL SSL Web Public: $web_url_ssl"

 # ip public for game (Outside docker)
 if [ -z "$set_game_ip" ]; then
  set_game_ip=$set_web_ip
 fi 

 # Ip game port
 if [ -z "$set_game_port" ]; then
  set_game_port="22102"
 fi

 echo "Server Ip Game: $set_game_ip:$set_game_port"

 # Welcome message
 if [ -z "$set_message_welcome" ]; then
  set_message_welcome="Welcome to $set_name_server\n\nUse !help for help\n\nRegion: $set_name_region\nCommunity: discord.yuuki.me"
 fi

 # Send Email When Registration
 if [ -z "$set_mail_message" ]; then
  set_mail_message="Hi, Thank you for registering on Yuuki Server, as a sign of gratitude for you we give gifts, you can also get more gifts with /give all on console, please visit us for help and type !help for more info.<type=\"browser\" text=\"Discord\" href=\"https://discord.yuuki.me\"/>"
 fi

 # Need database (Outside docker)
 if [ -z "$set_datebase" ]; then
  echo "No Datebase? exit!"
  exit 1
 else      
  echo "Server MongoDB: $set_datebase"
  json -q -I -f config.json -e "this.databaseInfo.server.connectionUri='$set_datebase'"
  json -q -I -f config.json -e "this.databaseInfo.game.connectionUri='$set_datebase'"
 fi

 # Config IP Game
 json -q -I -f config.json -e "this.server.game.accessAddress='$set_game_ip'"
 json -q -I -f config.json -e "this.server.game.bindPort='$set_game_port'" 

 # Config Game Web
 json -q -I -f config.json -e "this.server.http.accessAddress='$set_web_ip'"
 json -q -I -f config.json -e "this.server.http.bindPort='$set_web_port'"

 # SSL
 json -q -I -f config.json -e "this.server.http.encryption.useEncryption='$set_ssl'"
 json -q -I -f config.json -e "this.server.http.encryption.useInRouting='$set_web_url_ssl'"

 # Config Language Server
 json -q -I -f config.json -e "this.language.language='$set_language'"

 # Config max number of player online
 json -q -I -f config.json -e "this.account.maxPlayer='$set_player_online'"
 
 # Config password
 json -q -I -f config.json -e "this.account.EXPERIMENTAL_RealPassword='$set_login_password'" 

 # Config Welcome Message
 json -q -I -f config.json -e "this.server.game.joinOptions.welcomeMessage='$set_message_welcome'"

 # Config Welcome Email
 json -q -I -f config.json -e "this.server.game.joinOptions.welcomeMail.title='Welcome to $set_name_server'"
 json -q -I -f config.json -e "this.server.game.joinOptions.welcomeMail.sender='$set_name_owner'"
 json -q -I -f config.json -e "this.server.game.joinOptions.welcomeMail.content='$set_mail_message'"

 # Config Console
 json -q -I -f config.json -e "this.server.game.serverAccount.signature='Console $set_name_server ($set_name_region)'"
 json -q -I -f config.json -e "this.server.game.serverAccount.nickName='$set_name_owner'"
 json -q -I -f config.json -e "this.server.game.serverAccount.token='$set_token'"

else
 # If found config file (maybe restart?)
 echo "Found config files, ignore from command"
 rm -R -f logs/*
fi

# Game Server
java $set_java -jar grasscutter.jar