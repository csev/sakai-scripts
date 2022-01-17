#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

source config-dist.sh
if [ "$PORT" == "" ]; then 
    echo "Bad configuration or wrong shell"; 
    exit 
fi

# lsof -i 4tcp:8080 -sTCP:LISTEN
PROCESS_ID=`lsof -i :$PORT | grep -v PID | awk '{print $2}'`
if [ "$PROCESS_ID" == "" ]; then
    echo There is no process on $PORT checking for hung tomcat processes
    # Try a second time
    PROCESS_ID=`ps -a | grep tomcat | grep sakai | grep -v sakai:deploy |  awk '{print $1}'`
    if [ "$PROCESS_ID" == "" ]; then
        echo Did not find tomcat processes. Checking for any process on $PORT ...
        # lsof -i 4tcp:8080 -sTCP:LISTEN
        PROCESS_ID=`lsof -i :$PORT | grep -v PID | awk '{print $2}'`
        if [ "$PROCESS_ID" == "" ]; then
            echo Did not find any process on 8080...
            return 2>/dev/null || exit
        else
            echo Found process on $PORT
            lsof -i 4tcp:8080 -sTCP:LISTEN
            echo Shutting down non-tomcat process on $PROCESS_ID
            kill $PROCESS_ID
        fi
    else
        echo Shutting down process $PROCESS_ID
        ps -a | grep tomcat | grep sakai  | grep -v sakai:deploy
        kill $PROCESS_ID
    fi
    return 2>/dev/null || exit
fi

if [ -f apache-tomcat-$TOMCAT/bin/shutdown.sh ]; then 
    echo "Stopping Tomcat"
    ./apache-tomcat-$TOMCAT/bin/shutdown.sh
fi

# wait 2 seconds and see if we are down
sleep 2
PROCESS_ID=`lsof -i :$PORT | grep -v PID | awk '{print $2}'`
if [ "$PROCESS_ID" == "" ]; then
    return 2>/dev/null || exit
else
    echo Stopping process $PROCESS_ID
    lsof -i :$PORT | grep -v PID
    kill $PROCESS_ID
    sleep 2
fi

# Try a second time
PROCESS_ID=`lsof -i :$PORT | grep -v PID | awk '{print $2}'`
if [ "$PROCESS_ID" == "" ]; then
    return 2>/dev/null || exit
else
    lsof -i :$PORT | grep -v PID
    echo Waiting for process $PROCESS_ID
    sleep 5
    echo Shutting down process $PROCESS_ID
    kill -9 $PROCESS_ID
fi


