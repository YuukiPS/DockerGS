#!/bin/bash

# args
os=$1
metode=$2
versioncontrol=$3
isprivate=$5

# Project (We use Grasscutter as main project)
mainProject="dockergs"
useProject="GSServer-GC"
useFolderProject="gc"
useOSProject="gc"
useShortProject="yuukips"
useData="GC-Data"
useStart="local"
useMetode="build"
useBranchesProject="3.7"
useBranchesRes="3.7"
useResFolder="GC-Resources"

userHub="siakbary"

# Version Control
if [ "$versioncontrol" = "0" ];then
 useBranchesProject="Patch-2.6"
 useBranchesRes="2.6"
elif [ "$versioncontrol" = "1" ];then
 useBranchesProject="Patch-2.6-Early"
 useBranchesRes="2.6"
elif [ "$versioncontrol" = "2" ];then
 useBranchesProject="Patch-2.7"
 useBranchesRes="2.7"
elif [ "$versioncontrol" = "3" ];then
 useBranchesProject="Patch-2.7-Early"
 useBranchesRes="2.7"
elif [ "$versioncontrol" = "4" ];then
 useBranchesProject="Patch-2.8"
 useBranchesRes="2.8"
elif [ "$versioncontrol" = "5" ];then
 useBranchesProject="Patch-2.8-Early"
 useBranchesRes="2.8"
elif [ "$versioncontrol" = "6" ];then
 useBranchesProject="Patch-3.0-Early"
 useBranchesRes="3.0"
elif [ "$versioncontrol" = "7" ];then
 useBranchesProject="3.0"
 useBranchesRes="3.0"
elif [ "$versioncontrol" = "8" ];then
 useBranchesProject="3.1"
 useBranchesRes="3.1"
elif [ "$versioncontrol" = "9" ];then
 useBranchesProject="3.2"
 useBranchesRes="3.2"
elif [ "$versioncontrol" = "10" ];then
 useBranchesProject="3.3"
 useBranchesRes="3.3"
elif [ "$versioncontrol" = "11" ];then
 useBranchesProject="3.4"
 useBranchesRes="3.4"
elif [ "$versioncontrol" = "12" ];then
 useBranchesProject="3.5"
 useBranchesRes="3.5"
elif [ "$versioncontrol" = "13" ];then
 useBranchesProject="3.5-quest"
 useBranchesRes="3.5"
elif [ "$versioncontrol" = "14" ];then
 useBranchesProject="3.6"
 useBranchesRes="3.6"
elif [ "$versioncontrol" = "15" ];then
 useBranchesProject="3.6"
 useBranchesRes="3.6"
 useProject="GSServer-GCOriginal"
 useShortProject="gc"
elif [ "$versioncontrol" = "16" ];then
 useBranchesProject="3.7"
 useBranchesRes="3.7"
elif [ "$versioncontrol" = "17" ];then
 useBranchesProject="3.7"
 useBranchesRes="3.7"
 useProject="GSServer-GCOriginal"
 useShortProject="gc"
fi

build_gc="$useProject/.gradle $useProject/bin $useProject/build $useProject/src/generated"
# $useProject/logs $useProject/resources $useProject/config.json $useProject/plugins

# Version
version_pjhash="unknown";
version_rshash="unknown";

# Config file
folderwork="work_$useFolderProject"
foldertodo="todo_$useFolderProject"
folderworkdata="$folderwork/data"
filejson="$folderwork/config.json" 
filejson_res="$foldertodo/config.backup"
filecache="$folderwork/cache/TextMapCache.bin"
# Check OS
if [ -z "$os" ]; then
 os=$useStart
fi

# Check Metode
if [ -z "$metode" ]; then
 metode=$useMetode
fi

# Clone Repo
if [ "$os" = "repo" ];then

 echo "Start clone repo..."
 
 if [ "$metode" = "java" ];then
  echo "~ Get GSServer-GC"
  git clone --depth=1 https://github.com/YuukiPS/GSServer-GC GSServer-GC
 fi

 if [ "$metode" = "ts" ];then
  echo "~ Get GSServer-HuTao"
  git clone --depth=1 https://github.com/YuukiPS/GSServer-HuTao GSServer-HuTao
 fi

 if [ "$metode" = "res_ts" ];then
  echo "~ Get Data Resources Java for HuTaoGS (TS)"
  git clone --depth=1 https://github.com/NotArandomGUY/HuTao-GD Resources-TS
 fi

 if [ "$metode" = "res_java" ];then
  echo "~ Get Data Resources Java for Grasscutter (Java)"
  git clone --depth=1 https://gitlab.com/YuukiPS/GC-Resources GC-Resources
 fi

 if [ "$metode" = "data" ];then
  echo "~ Get Data Resources"
  git clone --depth=1 https://gitlab.com/YuukiPS/GC-Data $useData
 fi

 echo "EXIT NOW"
 exit 1
fi

# Get Data if not found (TODO: add Resources too?)
if [ ! -d "$useData" ]; then  
  echo "No Found Data, let's clone first"
  sh run.sh repo data
fi

if [ "$isprivate" = "pv" ];then
    echo "Private Mode0"
    userHub="repo.yuuki.me"
fi

echo "OS: $os - Metode: $metode - Branch: $useBranchesProject - Project: $useProject ($useShortProject) > $userHub"

# Check Folder Project
cd $useProject

# Switch Branch Project
# ls -a
branch_now=$(git rev-parse --abbrev-ref HEAD)
if [ -z "$branch_now" ]; then
 echo "Error get name branch project"
 exit 1
fi

# if HEAD
if [ "$branch_now" = "HEAD" ];then
 echo "This seems to work on GitHub Action, or first time? so let's switch to original to check version";
 # $branch_now = $useBranchesProject
fi

if [ "$useBranchesProject" != "$branch_now" ]; then
 echo "Switch $branch_now to $useBranchesProject"
 git switch $useBranchesProject
else
 echo "You're already there project $branch_now"
fi

# Get Hash Project
version_pjhash=$(git rev-parse --short=7 HEAD)
if [ -z "$version_pjhash" ]; then
 echo "Error get hash"
 exit 1
fi
# Back to home
cd ..

# Check Resources (Only if need with metode res)
if [ "$metode" = "res" ];then
 cd $useResFolder
 branch_res_now=$(git rev-parse --abbrev-ref HEAD)
 if [ -z "$branch_res_now" ]; then
  echo "Error get name branch resources"
  exit 1
 fi

 # if HEAD
 if [ "$branch_res_now" = "HEAD" ];then
  echo "This seems to work on GitHub Action, or first time? so let's switch to original to check version";
  # $branch_res_now = $useBranchesRes
 fi

 if [ "$useBranchesRes" != "$branch_res_now" ]; then
  echo "Switch Resources $branch_res_now to $useBranchesRes"
  git switch $useBranchesRes
 else
  echo "You're already there resources $branch_res_now"
 fi

 # Get Hash Res
 version_rshash=$(git rev-parse --short=7 HEAD)
 if [ -z "$version_rshash" ]; then
  echo "Error Get Hash Resources"
  exit 1
 fi
 # Back to home
 cd ..
fi

# Copy Hash
echo -n "$version_pjhash" > ver_$useProject-$useBranchesProject
if [ "$metode" = "res" ];then
 echo -n "$version_rshash" > ver_$useBranchesRes
fi

# Copy TMP version
version_last_pj=$os-$useShortProject
version_last_sw=$version_last_pj-$useBranchesProject
version_last_commit=$version_last_sw-$version_pjhash

echo $version_last_commit
echo -n "$version_last_commit" > ver_tmp

if [ ! -d "$folderwork" ]; then
 echo "Make folder $folderwork"
 mkdir -p $folderwork
fi
if [ ! -d "$foldertodo" ]; then
 echo "Make folder $foldertodo"
 mkdir -p $foldertodo
fi

if [ "$metode" = "start" ];then

 if [ "$os" = "local" ];then

  rm -rf $filecache

  if test -f "$filejson_res"; then
    echo "Found file config.backup"
    cp -rTf $filejson_res $filejson
  fi
  
  cd $folderwork
  
  if [ "$4" = "debug" ];then 
   # -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005 -cp bin 
   java -Dfile.encoding=UTF-8 -jar grasscutter.jar -debug
  else
   java -Dfile.encoding=UTF-8 -jar grasscutter.jar
  fi

 else

  ip=$4
  ipdb=$5
  res=$6  
  if [ -z "$ip" ]; then
   ip="127.0.0.1"
  fi
  if [ -z "$ipdb" ]; then
   ipdb="$ip:27017"
  fi
  if [ -z "$res" ]; then
   res="resources4_$useOSProject-$useBranchesProject"
  fi
  echo "Start Docker with IP $ip"
  # --args "-debug" \
  # --login_password "true" \
  # -v $res:/home/dockergs/resources \
  # //c/Users/Administrator/Desktop/Projek/Docker/GS/gs/todo_gc/config.backup
  docker run \
  --rm -it \
  -v $res:/home/dockergs/resources \
  -p 22102:22102/udp \
  -p 443:443/tcp \
  -p 80:80/tcp \
  $userHub/$mainProject:$version_last_commit \
  --database "mongodb://$ipdb" \
  --web_ip "$ip" \
  --game_ip "$ip" \
  --ssl "false" \
  --web_url_ssl "false" \
  --token "local"

 fi

fi

# if clean work
if [ "$metode" = "clean_work" ];then
 rm -R -f $folderwork/*
fi

# if sync
if [ "$metode" = "sync" ];then
 cd $useProject
 whosm=$4
 getme=$5
 dlrepo=$6
 if [ -z "$dlrepo" ]; then
  dlrepo="Grasscutter"
 fi
 if [ -z "$whosm" ]; then
  whosm="Grasscutters"
 fi
 if [ -z "$getme" ]; then
  if [ "$useBranchesProject" = "3.7" ];then
   getme="development"
  else
   getme="unstable"
  fi
 fi
 echo "pull $useProject"
 # --allow-unrelated-histories only do it if it's really needed, because I hate conflicts so better use "git cherry-pick <first_commit>..<last_commit>"
 git pull https://github.com/$whosm/$dlrepo.git $getme
 cd ..
fi

# if put
if [ "$metode" = "put" ];then
 cd $useProject
 git cherry-pick $4
fi

# if put
if [ "$metode" = "--continue" ];then
 cd $useProject
 git cherry-pick --continue
fi

if [ "$metode" = "sync_raw" ];then
 cd $useProject
 whosm=$4
 getme=$5
 git pull $whosm $getme
 cd ..
fi

if [ "$metode" = "check" ];then
 cd $useProject
 npx prettier --config .prettierrc.json --check .
 cd ..
fi

if [ "$metode" = "fix" ];then
 cd $useProject
 npx prettier --config .prettierrc.json --write .
 cd ..
fi

if [ "$metode" = "fix2" ];then
 cd $useProject
 ./gradlew spotlessApply
 cd ..
fi

if [ "$metode" = "version" ];then
 echo "ver1=$userHub/$mainProject:$version_last_commit" >> $GITHUB_ENV
 echo "ver2=$userHub/$mainProject:$version_last_sw" >> $GITHUB_ENV
fi

# if build
if [ "$metode" = "build" ];then 
 
 # if localhost

 if [ "$os" = "local" ];then    

  # Windows User:
  # https://stackoverflow.com/a/49584404 & https://stackoverflow.com/a/64272135  

  # Remove file
  we_clean_it=$4

  if [ "$we_clean_it" = "clean" ];then   

   if test -f "$filejson"; then
    echo "Found file config.json backup it"
    cp -rTf $filejson $filejson_res
   fi

   echo "Remove File Build GC (beginning)"
   rm -rf $build_gc
   echo "Remove file $folderwork folder (ending)"   
   rm -rf $folderwork/*

  fi

  echo "Start bulid..."
  cd $useProject
  
  echo "Update lib stuff"
  ./gradlew

  # Make jar
  echo "Make file jar..."
  ./gradlew jar

  # Back to home directory
  cd ..

  #ls   

  echo "Remove $folderwork file..."
  rm -R -f $folderwork/*

  if [ ! -d "$folderworkdata" ]; then
   echo "Make folder $folderworkdata"
   mkdir -p $folderworkdata
  fi

  echo "Copy jar file..."  
  cp -rTf $useProject/grasscutter*.jar $folderwork/grasscutter.jar

  echo "Copy res file..." # TODO: remove this or get better gc
  # cp -rf $useProject/src/main/resources/defaults/data/* $folderworkdata/
  cp -rf $useData/data/* $folderworkdata/

  echo "Remove jar Grasscutter"  
  rm $useProject/grasscutter*.jar

  echo "Copy file version local"
  cp -rTf ver_tmp $folderwork/ver

  echo "Copy file SSL Key"
  cp -rf $useProject/keystore.p12 $folderwork/

 else

  platform="linux/amd64,linux/arm64" # linux/arm/v7 error with "Couldn't iterate through the jurisdiction policy files: unlimited"

  # Bulid Docker Image
  if [ "$4" = "multi" ];then
   # for debug
   docker buildx build \
    -t "$userHub/$mainProject:$version_last_commit" \
    -f os-$os-$useOSProject \
    --platform $platform \
    --progress=plain \
    .;
  elif [ "$4" = "push_multi" ];then
   # Git action
   docker buildx build \
    -t "$userHub/$mainProject:$version_last_commit" \
    -t "$userHub/$mainProject:$version_last_sw" \
    -f os-$os-$useOSProject \
    --platform $platform \
    --push \
    .;
  elif [ "$4" = "docker_action" ];then

   if [ "$5" = "pv" ];then
    echo "Private Mode2"
    userHub="repo.yuuki.me"
   fi

   echo "ver1=$userHub/$mainProject:$version_last_commit" >> $GITHUB_ENV
   echo "ver2=$userHub/$mainProject:$version_last_sw" >> $GITHUB_ENV
   sh run.sh local build $versioncontrol $4 $5

   # Version Docker
   echo "Copy file version docker"
   echo -n "$version_last_commit" > $folderwork/ver

  elif [ "$4" = "docker_loc" ];then
   sh run.sh local build $versioncontrol $4 $5

   # Version Docker
   echo "Copy file version docker"
   echo -n "$version_last_commit" > $folderwork/ver

   docker build -t "$userHub/$mainProject:$version_last_commit" -f os-loc-$os-$useOSProject .;

   elif [ "$4" = "docker_private_push" ];then
   sh run.sh local build $versioncontrol $4 $5

   # Version Docker
   echo "Copy file version docker"
   echo -n "$version_last_commit" > $folderwork/ver

   docker build -t "repo.yuuki.me/$mainProject:$version_last_commit" -f os-loc-$os-$useOSProject .;
   docker push repo.yuuki.me/$mainProject:$version_last_commit

  elif [ "$4" = "docker_debug" ];then

   ls

   # for debug fast
   docker build \
   -t "$userHub/$mainProject:$version_last_commit" \
   -f os-$os-$useOSProject \
   --progress=plain \
   .;

  else

   # sh run.sh local build $versioncontrol $4

   # for debug fast
   docker build \
   -t "$userHub/$mainProject:$version_last_commit" \
   -f os-loc-$os-$useOSProject \
   .;
   # Tag to multi source
   #echo "Add image to repo public"  
   #docker tag "$userHub/$mainProject:$version_last_commit" "$userHub/$mainProject:$version_last_commit"
   #docker tag "$userHub/$mainProject:$version_last_commit" "$userHub/$mainProject:$version_last_sw"
  fi

 fi
 
fi

# Push Public
if [ "$metode" = "push" ];then
 docker push $userHub/$mainProject:$version_last_commit
 docker push $userHub/$mainProject:$version_last_sw
fi

# Push Private
if [ "$metode" = "private_push" ];then
 echo "push private"  
 docker push repo.yuuki.me/$mainProject:$version_last_commit
fi