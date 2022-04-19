#!/bin/bash
IPSERVERDB="$1"
if [ -z "$IPSERVERDB" ]
then
      echo "Server datebase run at localhost"
else
      # If you have a database outside
      sed -i "s/localhost:27017/$IPSERVERDB/" config.json
      echo "Server datebase at $IPSERVERDB"
fi

# Yup
java -jar grasscutter.jar