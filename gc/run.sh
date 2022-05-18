#!/bin/bash
runit="local"
version=$(cat VERSION)
os=$1
metode=$2
filejson="work/config.json" 
filejson_res="todo/config.backup"
removeme="Grasscutter/bin Grasscutter/logs Grasscutter/resources Grasscutter/src/generated Grasscutter/config.json Grasscutter/plugins Grasscutter/.gradle"

# select os
if [ -z "$os" ]; then
 os="local"
fi

# select metode
if [ -z "$metode" ]; then
 metode="build"
fi

echo OS: $os - Metode: $metode

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
  ip=$3
  ipdb=$4
  res=$5
  if [ -z "$ip" ]; then
   ip="127.0.0.1"
  fi
  if [ -z "$ipdb" ]; then
   ipdb="$ip:27017"
  fi
  if [ -z "$res" ]; then
   res="resources_gc_tes"
  fi
  docker run --env tes2=aaaa --rm -it \
  -v $res:/home/Grasscutter/resources \
  -p 22102:22102/udp \
  -p 443:443/tcp \
  siakbary/dockergc:$os-$version \
  -d "mongodb://$ipdb" \
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
 whosm=$3
 getme=$4
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
  we_clean_it=$3
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

  ls   

  echo "Copy jar file..."
  cp -rTf Grasscutter/grasscutter*.jar work/grasscutter.jar && rm Grasscutter/grasscutter*.jar
  echo "Copy file version & key"
  cp -rf VERSION Grasscutter/keys Grasscutter/keystore.p12 work/
  echo "Copy file data"
  cp -rTf Grasscutter_Data/data work/data
  
  # Back to work directory to check file
  cd work
  ls -a
  cd ..

  we_tes=$4
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
  sh run.sh local build clean
  # bulid
  docker build -t "siakbary/dockergc:$os-$version" -f os_$os .;  
 fi
 
fi

# if push
if [ "$metode" = "push" ];then
 docker push siakbary/dockergc:$os-$version
fi