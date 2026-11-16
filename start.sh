#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi
source config-dist.sh
if [ "$PORT" == "" ]; then
    echo "Bad configuration or wrong shell";
    exit
fi

source stop.sh

source tomcat-env.sh
echo $SAKAI_HOME

echo Timezone can be set in config.sh.  Currently:  $TIMEZONE

# export JAVA_OPTS="$JAVA_OPTS -verbose:class"
echo JAVA_OPTS:
echo $JAVA_OPTS

# If the first argument is -debugger, then start Tomcat in debug mode on port 8000
if [ "$1" = "-debugger" ]; then
    echo "Starting Tomcat in debug mode on port 8000"
    export JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000"
    export CATALINA_OPTS="$CATALINA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000"
fi

if [ -f apache-tomcat-$TOMCAT/bin/startup.sh ]; then
    echo "Removing logs"
    if [ "$LOG_DIRECTORY" != "" ]; then
        rm -f $LOG_DIRECTORY/*
    else
        rm -f apache-tomcat-$TOMCAT/logs/*
    fi

    echo "Starting Tomcat"
    rm ./apache-tomcat-$TOMCAT/logs/*
    # JAVA_OPTS is already exported, including -debugger. Pass PORT so
    # start-tomcat.sh does not source config-dist.sh a second time.
    export PORT TOMCAT TIMEZONE
    bash start-tomcat.sh "$@"
fi

echo
echo Starting tail of catalina.out...
sleep 5

if [ "$LOG_DIRECTORY" != "" ]; then
    if [ -f $LOG_DIRECTORY/catalina.out ]; then
        echo Viewing $LOG_DIRECTORY/catalina.out
        echo
        tail -f -n +1 $LOG_DIRECTORY/catalina.out
    else
        echo Could not find $LOG_DIRECTORY/catalina.out
    fi
else
    if [ -f apache-tomcat-$TOMCAT/logs/catalina.out ]; then
        echo Viewing apache-tomcat-$TOMCAT/logs/catalina.out
        echo
        tail -f -n +1 apache-tomcat-$TOMCAT/logs/catalina.out
    else
        echo Could not find apache-tomcat-$TOMCAT/logs/catalina.out
    fi
fi
