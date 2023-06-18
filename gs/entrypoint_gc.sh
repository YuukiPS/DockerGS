#!/bin/sh

help() {
  echo "Usage: TODO"
  exit 2
}

SHORT=db:,webip:,webport:,weburlssl:,gameip:,gameport:,msgwc,mailmsg:,dlres:,j:,ag:,lang:,loginpass:,po:,nmsv:,nmow:,nmrg:,ssl:,ac:,tk:,h
LONG=database:,web_ip:,web_port:,web_url_ssl:,game_ip:,game_port:,message_welcome:,mail_message:,download_resource:,java:,args:,language:,login_password:,player_online:,name_server:,name_owner:,name_region:,ssl:,autocreate:,token:,help
OPTS=$(getopt -a -n dockergs --options $SHORT --longoptions $LONG -- "$@")

VALID_ARGUMENTS=$# # Returns the count of arguments that are in short or long options

eval set -- "$OPTS"

while :; do
  case "$1" in
  # Server Database & Ip Config
  -db | --database)
    set_database="$2"
    shift 2
    ;;
  -webip | --web_ip)
    set_web_ip="$2"
    shift 2
    ;;
  -webport | --web_port)
    set_web_port="$2"
    shift 2
    ;;
  -weburlssl | --web_url_ssl)
    set_web_url_ssl="$2"
    shift 2
    ;;
  -ssl | --ssl)
    set_ssl="$2"
    shift 2
    ;;
  -ac | --autocreate)
    set_autoCreate="$2"
    shift 2
    ;;
  -gameip | --game_ip)
    set_game_ip="$2"
    shift 2
    ;;
  -gameport | --game_port)
    set_game_port="$2"
    shift 2
    ;;
  # Server Setup
  -dlres | --download_resource)
    set_download_resource="$2"
    shift 2
    ;;
  -j | --java)
    set_java="$2"
    shift 2
    ;;
  -ag | --args)
    set_args="$2"
    shift 2
    ;;
  -lang | --language)
    set_language="$2"
    shift 2
    ;;
  -loginpass | --login_password)
    set_login_password="$2"
    shift 2
    ;;
  -po | --player_online)
    set_player_online="$2"
    shift 2
    ;;
  -tk | --token)
    set_token="$2"
    shift 2
    ;;
  # Owner Server
  -nmsv | --name_server)
    set_name_server="$2"
    shift 2
    ;;
  -nmow | --name_owner)
    set_name_owner="$2"
    shift 2
    ;;
  -nmrg | --name_region)
    set_name_region="$2"
    shift 2
    ;;
  # Message Server
  -msgwc | --message_welcome)
    set_message_welcome="$2"
    shift 2
    ;;
  # Mail Message
  -mailmsg | --mail_message)
    set_mail_message="$2"
    shift 2
    ;;
  # Help
  -h | --help)
    help
    ;;
  --)
    shift
    break
    ;;
  *)
    echo "Unexpected option: $1"
    help
    ;;
  esac
done

folder_gc="/home/dockergs"
folder_resources="$folder_gc/resources"
fileres="$folder_resources/resources.zip"
update=false
timems=date

# ROOT GC
cd $folder_gc

OSVS=$(. /etc/os-release && printf '%s\n' "$NAME")
SUB="Alpine"
version=$(cat ver)
version_res="main"
resmd5="e7754c155a4668606fc3695aced65717"

# Switch RS
if echo "$version" | grep -F -w "2.6"; then
  version_res="2.6"
elif echo "$version" | grep -F -w "2.7"; then
  version_res="2.7"
elif echo "$version" | grep -F -w "2.8"; then
  version_res="2.8"
elif echo "$version" | grep -F -w "3.0"; then
  version_res="3.0"
elif echo "$version" | grep -F -w "3.1"; then
  version_res="3.1"
elif echo "$version" | grep -F -w "3.2"; then
  version_res="3.2"
elif echo "$version" | grep -F -w "3.3"; then
  version_res="3.3"
elif echo "$version" | grep -F -w "3.4"; then
  version_res="3.4"
elif echo "$version" | grep -F -w "3.5"; then
  version_res="3.5"
elif echo "$version" | grep -F -w "3.6"; then
  version_res="3.6"
elif echo "$version" | grep -F -w "3.7"; then
  version_res="3.7"
fi

echo "Runs with OS $OSVS"
echo "Runs with Resources $version_res in Game Server $version"

res_url="https://gitlab.com/YuukiPS/GC-Resources/-/archive/$version_res/GC-Resources-$version_res.zip"

# JVM sets its heap size to approximately 25% of the available RAM. In this example, it allocated 4GB on a system with 16GB. (-Xms50M -Xmx1G)
if [ -z "$set_java" ]; then
  set_java=""
fi

# Building Data Source and Generated Resources
if [ -d "$folder_resources/BinOutput" ]; then
  # ls $folder_resources
  echo "Resources folder already exists..."
else
  # Update res zip
  if test -f "$fileres"; then

    echo "check md5 now"
    res_hash_now=$(md5sum "$fileres" | awk '{print $1}')

    echo "Resources file already exists with md5 $res_hash_now"

    #URLCheckRes="https://gitlab.com/YuukiPS/GC-Resources/-/archive/$version_res/GC-Resources-$version_res.zip"

    # Get the first 1MB of the file
    #echo "download tmp file for check md5"
    #datatmpres=$(curl -sSL -r 0-1048576 "$URLCheckRes")

    # Calculate MD5 hash of the data
    #echo "check md5 update"
    #res_hash_update=$(echo "$datatmpres" | md5sum | awk '{print $1}')

    # Compare the calculated hash with the expected hash
    if [ "$resmd5" = "$res_hash_now" ]; then
      echo "Resources already update"
    else
      echo "MD5 hash does not match so update it, Your file $res_hash_now and update $resmd5"
      update=true
    fi

  else
    echo "No found file resources.zip ..."
    update=true
  fi
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

if $update; then
  echo "Download Resources: $version_res > $res_url"
  curl -o $fileres $res_url
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

  # PASSWORD
  if [ -z "$set_login_password" ]; then
    set_login_password="false"
  fi

  # PASSWORD
  if [ -z "$set_autoCreate" ]; then
    set_autoCreate="true"
  fi

  # if no config just boot
  java -jar grasscutter.jar -version

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
  echo "Server Password: $set_login_password"
  echo "Server Auto Create Acc: $set_autoCreate"

  # Welcome message
  if [ -z "$set_message_welcome" ]; then
    set_message_welcome="Welcome to $set_name_server\n\nUse !help for help\n\nRegion: $set_name_region\nCommunity: discord.yuuki.me"
  fi

  # Send Email When Registration
  if [ -z "$set_mail_message" ]; then
    set_mail_message="Hi, Thank you for registering on Yuuki Server, as a sign of gratitude for you we give gifts, you can also get more gifts with /give all on console, please visit us for help and type !help for more info.<type=\"browser\" text=\"Discord\" href=\"https://discord.yuuki.me\"/>"
  fi

  # Need database (Outside docker)
  if [ -z "$set_database" ]; then
    echo "No Database? exit!"
    exit 1
  else
    echo "Server MongoDB: $set_database"
    json -q -I -f config.json -e "this.databaseInfo.server.connectionUri='$set_database'"
    json -q -I -f config.json -e "this.databaseInfo.game.connectionUri='$set_database'"
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

  # Config Password
  json -q -I -f config.json -e "this.account.EXPERIMENTAL_RealPassword='$set_login_password'"

  # Config Auto Create
  json -q -I -f config.json -e "this.account.autoCreate='$set_autoCreate'"

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
java $set_java -Dfile.encoding=UTF-8 -jar grasscutter.jar $set_args
