#! /bin/bash
source config-dist.sh

source stop.sh

if [ -f apache-tomcat-$TOMCAT/bin/startup.sh ]; then 
    echo "Starting Tomcat"
    ./apache-tomcat-$TOMCAT/bin/startup.sh
fi
