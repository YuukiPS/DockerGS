#!/bin/bash

# args
os=$1
metode=$2
versioncontrol=$3

# Project (We use Grasscutter Original as main project)
mainProject="dockergs"
useFolderProject="gc"
useOSProject="gc"
useData="GC-Data"
useStart="local"
useMetode="build"
useResFolder="GC-Resources"
# for version
useProject="GSServer-GCOriginal" # folder project
useShortProject="gc"
useBranchesProject="3.7"
useBranchesRes="3.7"

userHub="siakbary"

# Version Control by User
if [ "$2" != "version_action" ]; then

  if [ "$versioncontrol" = "16" ]; then # for private stable, TODO: move quest here or just keep in 17
    useBranchesProject="3.7"
    useBranchesRes="3.7"
    useShortProject="yuukips"
    useProject="GSServer-GC"
  elif [ "$versioncontrol" = "17" ]; then # for private quest (stable)
    useBranchesProject="3.7-quest"
    useBranchesRes="3.7"
    useShortProject="yuukips"
    useProject="GSServer-GC"
  elif [ "$versioncontrol" = "18" ]; then # for public (dev)
    useBranchesProject="3.7"
    useBranchesRes="3.7"
  elif [ "$versioncontrol" = "19" ]; then # for private (unstable)
    useBranchesProject="4.0"
    useBranchesRes="4.0"
    useShortProject="yuukips"
    useProject="GSServer-GC"
  elif [ "$versioncontrol" = "20" ]; then # for public (dev)
    useBranchesProject="4.0"
    useBranchesRes="4.0"
  fi

fi

# Version Control by Github Action (use tmp folder)
# #1=os for ubuntu,2 metode for version_action, 3 for version branches, 4 for version resources (normal not need)
if [ "$2" = "version_action" ]; then
  useProject="tmp"
  useBranchesProject=$3
  useBranchesRes=$4
fi

build_gc="$useProject/.gradle $useProject/bin $useProject/build $useProject/src/generated"
# $useProject/logs $useProject/resources $useProject/config.json $useProject/plugins

# Version
version_pjhash="unknown"
version_rshash="unknown"

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
if [ "$os" = "repo" ]; then

  echo "Start clone repo..."

  if [ "$metode" = "yuuki_gc" ]; then
    echo "~ Get GSServer-GC"
    git clone --depth=1 https://github.com/YuukiPS/GSServer-GC GSServer-GC
  fi

  if [ "$metode" = "gc" ]; then
    echo "~ Get GSServer-GCOriginal"
    git clone --depth=1 https://github.com/YuukiPS/Grasscutters-Original GSServer-GCOriginal
  fi

  if [ "$metode" = "gc_res" ]; then
    echo "~ Get Data Resources Grasscutter"
    git clone --depth=1 https://gitlab.com/YuukiPS/GC-Resources GC-Resources
  fi

  if [ "$metode" = "gc_data" ]; then
    echo "~ Get Data Resources"
    git clone --depth=1 https://gitlab.com/YuukiPS/GC-Data $useData
  fi

  echo "Clone repo done..."
  exit 1
fi

# Get Data GC (TODO: skip if not use gc)
if [ ! -d "$useData" ]; then
  echo "No Found Data, let's clone first"
  sh run.sh repo gc_data
fi

# for YuukiPS (cmd5)
if [ "$5" = "pv" ]; then
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
if [ "$branch_now" = "HEAD" ]; then
  echo "This seems to work on GitHub Action, or first time? so let's switch to original to check version"
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
if [ "$metode" = "res" ]; then
  cd $useResFolder
  branch_res_now=$(git rev-parse --abbrev-ref HEAD)
  if [ -z "$branch_res_now" ]; then
    echo "Error get name branch resources"
    exit 1
  fi

  # if HEAD
  if [ "$branch_res_now" = "HEAD" ]; then
    echo "This seems to work on GitHub Action, or first time? so let's switch to original to check version"
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
echo -n "$version_pjhash" >ver_$useProject-$useBranchesProject
if [ "$metode" = "res" ]; then
  echo -n "$version_rshash" >ver_$useBranchesRes
fi

# Copy TMP version
version_last_pj=$os-$useShortProject
version_last_sw=$version_last_pj-$useBranchesProject
version_last_commit=$version_last_sw-$version_pjhash

echo $version_last_commit
echo -n "$version_last_commit" >ver_tmp

if [ ! -d "$folderwork" ]; then
  echo "Make folder $folderwork"
  mkdir -p $folderwork
fi
if [ ! -d "$foldertodo" ]; then
  echo "Make folder $foldertodo"
  mkdir -p $foldertodo
fi

if [ "$metode" = "start" ]; then

  if [ "$os" = "local" ]; then

    rm -rf $filecache

    if test -f "$filejson_res"; then
      echo "Found file config.backup"
      cp -rTf $filejson_res $filejson
    fi

    cd $folderwork

    if [ "$4" = "debug" ]; then
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
      res="resources_$useOSProject-$useBranchesProject"
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
if [ "$metode" = "clean_work" ]; then
  rm -R -f $folderwork/*
fi

# if sync
if [ "$metode" = "sync" ]; then
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
    if [ "$useBranchesProject" = "4.0" ]; then
      getme="dev-4.0"
    else
      getme="development"
    fi
  fi
  echo "pull $useProject"
  # --allow-unrelated-histories only do it if it's really needed, because I hate conflicts so better use "git cherry-pick <first_commit>..<last_commit>"
  git pull https://github.com/$whosm/$dlrepo.git $getme
  cd ..
fi

# if put
if [ "$metode" = "put" ]; then
  cd $useProject
  git cherry-pick $4
fi

# if put
if [ "$metode" = "--continue" ]; then
  cd $useProject
  git cherry-pick --continue
fi

if [ "$metode" = "sync_raw" ]; then
  cd $useProject
  whosm=$4
  getme=$5
  git pull $whosm $getme
  cd ..
fi

if [ "$metode" = "check" ]; then
  cd $useProject
  npx prettier --config .prettierrc.json --check .
  cd ..
fi

if [ "$metode" = "fix" ]; then
  cd $useProject
  npx prettier --config .prettierrc.json --write .
  cd ..
fi

if [ "$metode" = "fix2" ]; then
  cd $useProject
  ./gradlew spotlessApply
  cd ..
fi

if [ "$metode" = "check2" ]; then
  cd $useProject
  ./gradlew spotlessDiagnose
  cd ..
fi

# Get version only
if [ "$metode" = "version_action" ]; then
  echo "ver1=$userHub/$mainProject:$version_last_commit" >>$GITHUB_ENV
  echo "ver2=$userHub/$mainProject:$version_last_sw" >>$GITHUB_ENV
  echo "shortpj=$useShortProject" >>$GITHUB_ENV
fi

# if build
if [ "$metode" = "build" ]; then

  # if localhost

  if [ "$os" = "local" ]; then

    # Windows User:
    # https://stackoverflow.com/a/49584404 & https://stackoverflow.com/a/64272135

    # Remove file
    we_clean_it=$4

    if [ "$we_clean_it" = "clean" ]; then

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

    # echo "Fix Permission"
    # chmod +x gradlew
    # git update-index --chmod=+x gradlew

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
    if [ "$4" = "multi" ]; then
      # for debug
      docker buildx build \
        -t "$userHub/$mainProject:$version_last_commit" \
        -f os-$os-$useOSProject \
        --platform $platform \
        --progress=plain \
        .
    elif [ "$4" = "push_multi" ]; then
      # Git action
      docker buildx build \
        -t "$userHub/$mainProject:$version_last_commit" \
        -t "$userHub/$mainProject:$version_last_sw" \
        -f os-$os-$useOSProject \
        --platform $platform \
        --push \
        .
    elif [ "$4" = "docker_action" ]; then

      if [ "$5" = "pv" ]; then
        echo "Private Mode2"
        userHub="repo.yuuki.me"
      fi

      echo "ver1=$userHub/$mainProject:$version_last_commit" >>$GITHUB_ENV
      echo "ver2=$userHub/$mainProject:$version_last_sw" >>$GITHUB_ENV
      sh run.sh local build $versioncontrol $4 $5

      # Version Docker
      echo "Copy file version docker"
      echo -n "$version_last_commit" >$folderwork/ver

    elif [ "$4" = "docker_loc" ]; then
      sh run.sh local build $versioncontrol $4 $5

      # Version Docker
      echo "Copy file version docker"
      echo -n "$version_last_commit" >$folderwork/ver

      docker build -t "$userHub/$mainProject:$version_last_commit" -f os-loc-$os-$useOSProject .

    elif [ "$4" = "docker_private_push" ]; then
      sh run.sh local build $versioncontrol $4 $5

      # Version Docker
      echo "Copy file version docker"
      echo -n "$version_last_commit" >$folderwork/ver

      docker build -t "repo.yuuki.me/$mainProject:$version_last_commit" -f os-loc-$os-$useOSProject .
      docker push repo.yuuki.me/$mainProject:$version_last_commit

    elif [ "$4" = "docker_debug" ]; then

      ls

      # for debug fast
      docker build \
        -t "$userHub/$mainProject:$version_last_commit" \
        -f os-$os-$useOSProject \
        --progress=plain \
        .

    else

      # sh run.sh local build $versioncontrol $4

      # for debug fast
      docker build \
        -t "$userHub/$mainProject:$version_last_commit" \
        -f os-loc-$os-$useOSProject \
        .
      # Tag to multi source
      #echo "Add image to repo public"
      #docker tag "$userHub/$mainProject:$version_last_commit" "$userHub/$mainProject:$version_last_commit"
      #docker tag "$userHub/$mainProject:$version_last_commit" "$userHub/$mainProject:$version_last_sw"
    fi

  fi

fi

# Push Public
if [ "$metode" = "push" ]; then
  docker push $userHub/$mainProject:$version_last_commit
  docker push $userHub/$mainProject:$version_last_sw
fi

# Push Private
if [ "$metode" = "private_push" ]; then
  echo "push private"
  docker push repo.yuuki.me/$mainProject:$version_last_commit
fi
