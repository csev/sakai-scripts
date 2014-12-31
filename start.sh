#! /bin/bash
source config-dist.sh

source stop.sh

if [ -f apache-tomcat-$TOMCAT/bin/startup.sh ]; then 
    echo "Removing logs"
    if [ "$LOG_DIRECTORY" != "" ]; then
        rm -f $LOG_DIRECTORY/*
    else 
        rm -f apache-tomcat-$TOMCAT/logs/*
    fi

    echo "Starting Tomcat"
    rm ./apache-tomcat-$TOMCAT/logs/*
    ./apache-tomcat-$TOMCAT/bin/startup.sh
fi
