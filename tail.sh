#! /bin/bash
source config-dist.sh

if [ "$LOG_DIRECTORY" != "" ]; then
    if [ -f $LOG_DIRECTORY/catalina.out ]; then
        echo Viewing $LOG_DIRECTORY/catalina.out
        echo
        tail -f $LOG_DIRECTORY/catalina.out
    else
        echo Could not find $LOG_DIRECTORY/catalina.out
    fi
else 
    if [ -f apache-tomcat-$TOMCAT/logs/catalina.out ]; then
        echo Viewing apache-tomcat-$TOMCAT/logs/catalina.out
        echo
        tail -f apache-tomcat-$TOMCAT/logs/catalina.out
    else 
        echo Could not find apache-tomcat-$TOMCAT/logs/catalina.out
    fi
fi
