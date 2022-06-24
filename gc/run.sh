#!/bin/bash
runit="local"

os=$1
metode=$2
usebranch=$3

filejson="work/config.json" 
filejson_res="todo/config.backup"
removeme="Grasscutter/bin Grasscutter/logs Grasscutter/resources Grasscutter/src/generated Grasscutter/config.json Grasscutter/plugins Grasscutter/.gradle"

switchbc="Patch-2.7"
switcres="2.7"

version_gchash="unknown";
version_rshash="unknown";

# Clone Data
if [ "$os" = "data" ];then

 echo "Start clone data..."

 if [ "$metode" = "core" ];then
  echo "~ Get Core"
  git clone https://github.com/akbaryahya/GCPrivate.git Grasscutter
 fi
 if [ "$metode" = "res" ];then
  echo "~ Get Resources"
  git clone https://gitlab.com/yukiz/GrasscutterResources Grasscutter_Resources
 fi
 if [ "$metode" = "data" ];then
  echo "~ Get Data Resources"
  git clone https://gitlab.com/yukiz/grasscutter-data Grasscutter_Data
 fi
 if [ "$metode" = "proxy" ];then
  echo "~ Get Data Proxy"
  git clone https://gitlab.com/yukiz/grasscutter-proxy Grasscutter_Proxy
 fi
 echo "EXIT NOW"
 exit 1
fi

# Get Data if not found
if [ ! -d "Grasscutter_Data" ]; then  
  echo "No Found Data, let's clone first"
  sh run.sh data data
fi

# OS
if [ -z "$os" ]; then
 os="local"
fi

# Metode
if [ -z "$metode" ]; then
 metode="build"
fi

# Branch Switch Version
if [ "$usebranch" = "0" ];then
 switchbc="Patch-2.6"
 switcres="2.6"
fi
if [ "$usebranch" = "1" ];then
 switchbc="Patch-2.6-Early"
 switcres="2.6"
fi
if [ "$usebranch" = "2" ];then
 switchbc="Patch-2.7"
 switcres="2.7"
fi
if [ "$usebranch" = "3" ];then
 switchbc="Patch-2.7-Early"
 switcres="2.7"
fi
if [ "$usebranch" = "4" ];then
 switchbc="Patch-2.8"
 switcres="2.8"
fi
if [ "$usebranch" = "5" ];then
 switchbc="Patch-2.8-Early"
 switcres="2.8"
fi

echo OS: $os - Metode: $metode - Branch:$switchbc

# Check GC
cd Grasscutter
# Switch GC
#ls -a
branch_now=$(git rev-parse --abbrev-ref HEAD)
if [ -z "$branch_now" ]; then
 echo "Error get name branch GC"
 exit 1
fi
# if HEAD
if [ "$branch_now" = "HEAD" ];then
 echo "This seems to work on GitHub Action, or first time? so let's switch to original to check version";
 # $branch_now = $switchbc
fi
if [ "$switchbc" != "$branch_now" ]; then
 echo "Switch $branch_now to $switchbc"
 git switch $switchbc
else
 echo "You're already there GC $branch_now"
fi
# Get Hash GC
version_gchash=$(git rev-parse --short=7 HEAD)
if [ -z "$version_gchash" ]; then
 echo "Error get hash"
 exit 1
fi
# Back to home
cd ..

# Check GC Resources (Only if need with metode res)
if [ "$metode" = "res" ];then
 cd Grasscutter_Resources
 branch_res_now=$(git rev-parse --abbrev-ref HEAD)
 if [ -z "$branch_res_now" ]; then
  echo "Error get name branch resources"
  exit 1
 fi
 # if HEAD
 if [ "$branch_res_now" = "HEAD" ];then
  echo "This seems to work on GitHub Action, or first time? so let's switch to original to check version";
  # $branch_res_now = $switcres
 fi
 if [ "$switcres" != "$branch_res_now" ]; then
  echo "Switch Resources $branch_res_now to $switcres"
  git switch $switcres
 else
  echo "You're already there resources $branch_res_now"
 fi
 # Get Hash GC
 version_rshash=$(git rev-parse --short=7 HEAD)
 if [ -z "$version_rshash" ]; then
  echo "Error Get Hash Resources"
  exit 1
 fi
 # Back to home
 cd ..
fi

# Copy Hash
echo -n "$version_gchash" > VERSION_GC_$switchbc
if [ "$metode" = "res" ];then
 echo -n "$version_rshash" > VERSION_RS_$switcres
fi

# Copy TMP version
version_last_commit=$os-$switchbc-$version_gchash
version_last_sw=$os-$switchbc
echo $version_last_commit
echo -n "$version_last_commit" > VERSION_TMP

cekres () {
 echo "Check folder..."
 if [ ! -d "resources/BinOutput" ]; then  
  getres
 fi
}

if [ ! -d "work" ]; then
 echo "Make folder work.."
 mkdir -p work
fi
if [ ! -d "todo" ]; then
 echo "Make folder todo.."
 mkdir -p todo
fi

if [ "$metode" = "start" ];then

 if [ "$os" = "local" ];then

  if test -f "$filejson_res"; then
    echo "Found file config.backup"
    cp -rTf $filejson_res $filejson
  fi
  
  cd work
  java -jar grasscutter.jar
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
   res="resources_gc_$switchbc"
  fi
  echo "Start Docker with IP $ip"
  docker run --env tes2=aaaa --rm -it \
  -v $res:/home/Grasscutter/resources \
  -p 22102:22102/udp \
  -p 443:443/tcp \
  siakbary/dockergc:$version_last_commit \
  -d "mongodb://$ipdb" \
  -b "$ip" \
  -g "$ip"
 fi

fi

# if clean
if [ "$metode" = "clean_work" ];then
 rm -R -f work/*
 rm -R -f .gradle/*
 rm -R -f bin/*
fi

# if sync
if [ "$metode" = "sync" ];then
 cd Grasscutter
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
  if [ "$switchbc" = "Patch-2.7" ];then
   getme="development"
  elif [ "$switchbc" = "Patch-2.7-Early" ];then
   getme="development"
   # git rebase --ignore-whitespace
  else
   getme="2.6"
  fi
 fi
 git pull https://github.com/$whosm/$dlrepo.git $getme
 cd ..
fi

if [ "$metode" = "sync_raw" ];then
 cd Grasscutter
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
    echo "Found file config.json"
    cp -rTf $filejson $filejson_res
   fi
   echo "Remove file build (beginning)"
   rm -R -f $removeme
   echo "Remove file work (ending)"   
   rm -R -f work/*
  fi

  echo "Start bulid..."
  cd Grasscutter   

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

  echo "Remove work file..."
  rm -R -f work/*
  echo "Copy jar file..."
  cp -rTf Grasscutter/grasscutter*.jar work/grasscutter.jar
  echo "Remove jar Grasscutter"
  rm Grasscutter/grasscutter*.jar
  echo "Copy file version local"
  cp -rTf VERSION_TMP work/VERSION
  echo "Copy file SSL Key"
  cp -rf Grasscutter/keystore.p12 work/
  echo "Copy file data"
  cp -rTf Grasscutter_Data/data work/data
  
  # Back to work directory to check file
  #cd work
  #ls -a
  #cd ..

  we_tes=$5
  if [ "$we_tes" = "test" ];then

   # TODO: check if config file
   echo "Doing Testing, so need copy resources"
   #cp -rTf Grasscutter_Resources/Resources work/resources

   cd work

   # Generated stuff
   echo "Testing Generated..."
   java -jar grasscutter.jar -boot

   # rm -R -f resources

   cd ..
  fi

 else
  # make jar local
  sh run.sh local build $usebranch $4

  # Version Docker
  echo "Copy file version docker"  
  echo -n "$version_last_commit" > work/VERSION

  # bulid
  docker build -t "siakbary/dockergc:$version_last_commit" -f os_$os .;
  docker build -t "siakbary/dockergc:$version_last_sw" -f os_$os .;
 fi
 
fi

# if push
if [ "$metode" = "push" ];then
 docker push siakbary/dockergc:$version_last_commit
 docker push siakbary/dockergc:$version_last_sw
fi