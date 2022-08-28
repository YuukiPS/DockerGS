#!/bin/bash

# args
os=$1
metode=$2
versioncontrol=$3

# Project (We use Grasscutter as main project)
mainProject="dockergs"
useProject="Grasscutter-Yuuki"
useShortProject="gc"
useStart="local"
useMetode="build"
useBranchesProject="3.0"
useBranchesRes="3.0"
useResFolder="Resources-JAVA"

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
fi

build_gc="$useProject/bin $useProject/logs $useProject/resources $useProject/config.json $useProject/plugins $useProject/.gradle"

# Version
version_pjhash="unknown";
version_rshash="unknown";

# Config file
folderwork="work_$useShortProject"
foldertodo="todo_$useShortProject"
filejson="$folderwork/config.json" 
filejson_res="$foldertodo/config.backup"

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
  echo "~ Get Grasscutter-Yuuki"
  git clone https://github.com/akbaryahya/Grasscutter-Yuuki Grasscutter-Yuuki
 fi

 if [ "$metode" = "ts" ];then
  echo "~ Get HuTaoGS-Yuuki"
  git clone https://github.com/akbaryahya/HuTaoGS-Yuuki HuTaoGS-Yuuki
 fi

 if [ "$metode" = "res_ts" ];then
  echo "~ Get Data Resources Java for HuTaoGS (TS)"
  git clone https://github.com/NotArandomGUY/HuTao-GD Resources-TS
 fi

 if [ "$metode" = "res_java" ];then
  echo "~ Get Data Resources Java for Grasscutter (Java)"
  git clone https://gitlab.com/yukiz/GrasscutterResources Resources-JAVA
 fi

 echo "EXIT NOW"
 exit 1
fi

echo "OS: $os - Metode: $metode - Branch: $useBranchesProject - Project: $useProject ($useShortProject)"

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
echo -n "$version_pjhash" > ver_$useShortProject-$useBranchesProject
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

  if test -f "$filejson_res"; then
    echo "Found file config.backup"
    cp -rTf $filejson_res $filejson
  fi
  
  cd $folderwork
  
  if [ "$4" = "debug" ];then 
   # -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005 -cp bin 
   java -jar grasscutter.jar -debug
  else
   java -jar grasscutter.jar -handbook
   java -jar grasscutter.jar
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
   res="resources_$useShortProject-$useBranchesProject"
  fi
  echo "Start Docker with IP $ip"
  # --args "-debug" \
  docker run \
  --rm -it \
  -v $res:/home/dockergs/resources \
  -p 22102:22102/udp \
  -p 443:443/tcp \
  -p 80:80/tcp \
  siakbary/$mainProject:$version_last_commit \
  --database "mongodb://$ipdb" \  
  --web_ip "$ip" \
  --game_ip "$ip" \
  --ssl "false" \
  --web_url_ssl "false" \
  --token "local" \
  --login_password "true"

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
  if [ "$useBranchesProject" = "3.0" ];then
   getme="development"
  elif [ "$useBranchesProject" = "3.0-Early" ];then
   getme="development"
   # git rebase --ignore-whitespace
  else
   getme="2.6"
  fi
 fi
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
   rm -R -f $build_gc
   echo "Remove file $folderwork folder (ending)"   
   rm -R -f $folderwork/*

  fi

  echo "Start bulid..."
  cd $useProject

  # Linux User
  # chmod +x gradlew

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

  echo "Copy jar file..."  
  cp -rTf $useProject/grasscutter*.jar $folderwork/grasscutter.jar

  echo "Remove jar Grasscutter"  
  rm $useProject/grasscutter*.jar

  echo "Copy file version local"
  cp -rTf ver_tmp $folderwork/ver

  echo "Copy file SSL Key"
  cp -rf $useProject/keystore.p12 $folderwork/

 else

  # make local file
  sh run.sh local build $versioncontrol $4

  # Version Docker
  echo "Copy file version docker"
  echo -n "$version_last_commit" > $folderwork/ver

  # Bulid Local
  docker build -t "$mainProject:$version_last_commit" -f os-$os-$useShortProject .;
  
  # Tag to multi source
  echo "Add image to repo public"  
  docker tag "$mainProject:$version_last_commit" "siakbary/$mainProject:$version_last_commit"
  docker tag "$mainProject:$version_last_commit" "siakbary/$mainProject:$version_last_sw"

  # Private Repo
  echo "Add image to private repo"  
  docker tag "$mainProject:$version_last_commit" "repo.yuuki.me/$mainProject:$version_last_commit"

 fi
 
fi

# Push Public
if [ "$metode" = "push" ];then
 docker push siakbary/$mainProject:$version_last_commit
 docker push siakbary/$mainProject:$version_last_sw
fi

# Push Private
if [ "$metode" = "private_push" ];then
 echo "push private"  
 docker push repo.yuuki.me/$mainProject:$version_last_commit
fi