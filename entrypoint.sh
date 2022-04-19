#!/bin/bash

# If you have a database outside
sed -i 's/localhost:27017/2.0.0.100/' config.json

# Yup
java -jar grasscutter.jar