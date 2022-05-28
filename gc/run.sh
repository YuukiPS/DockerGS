#!/bin/bash
runit="local"

os=$1
metode=$2
usebranch=$3

filejson="work/config.json" 
filejson_res="todo/config.backup"
removeme="Grasscutter/bin Grasscutter/logs Grasscutter/resources Grasscutter/src/generated Grasscutter/config.json Grasscutter/plugins Grasscutter/.gradle"
switchbc="Patch-DEV"

version_gchash="unknown";

# OS
if [ -z "$os" ]; then
 os="local"
fi

# Metode
if [ -z "$metode" ]; then
 metode="build"
fi

# Branch
if [ "$usebranch" = "0" ];then
 switchbc="Patch-DEV"
fi
if [ "$usebranch" = "1" ];then
 switchbc="Patch-Early"
fi
if [ "$usebranch" = "2" ];then
 switchbc="Patch-2.7"
fi

echo OS: $os - Metode: $metode - Branch:$switchbc

# Check GC
cd Grasscutter
# Switch GC
#ls -a
branch_now=$(git rev-parse --abbrev-ref HEAD)
if [ -z "$branch_now" ]; then
 echo "Error get name branch"
 exit 1
fi
# if HEAD
if [ "$branch_now" = "HEAD" ];then
 echo "This seems to work on GitHub Action, or first time? so let's switch to original to check version";
fi
if [ "$switchbc" != "$branch_now" ]; then
 echo "Switch $branch_now to $switchbc"
 git switch $switchbc
else
 echo "You're already there $branch_now"
fi
# Get Hash GC
version_gchash=$(git rev-parse --short HEAD)
if [ -z "$version_gchash" ]; then
 echo "Error get hash"
 exit 1
fi
# Back to home
cd ..

# Copy Hash GC
echo -n "$version_gchash" > VERSION_$switchbc

# Copy TMP version
allto=$os-$switchbc-$version_gchash
echo $allto
echo -n "$allto" > VERSION_TMP

getres () {
 echo "Get Resources"
 git clone https://github.com/Koko-boya/Grasscutter_Resources
 #cp -rTf Grasscutter_Resources/Resources/* Grasscutter_Resources
}

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
  docker run --env tes2=aaaa --rm -it \
  -v $res:/home/Grasscutter/resources \
  -p 22102:22102/udp \
  -p 443:443/tcp \
  siakbary/dockergc:$allto \
  -d "mongodb://$ipdb" \
  -v "0.0.0.0" \
  -b "$ip"
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
 if [ -z "$whosm" ]; then
  whosm="Grasscutters"
 fi
 if [ -z "$getme" ]; then
  getme="development"
 fi
 git pull https://github.com/$whosm/Grasscutter.git $getme
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
   cekres
   cp -rTf Grasscutter_Resources/Resources work/resources

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
  echo -n "$allto" > VERSION_TMP
  cp -rTf VERSION_TMP work/VERSION

  # bulid
  docker build -t "siakbary/dockergc:$allto" -f os_$os .;
 fi
 
fi

# if push
if [ "$metode" = "push" ];then
 docker push siakbary/dockergc:$allto
fi