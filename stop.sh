#! /bin/bash
source config-dist.sh

PROCESS_ID=`lsof -i :$PORT | grep java | awk '{print $2}'`
if [ "$PROCESS_ID" == "" ]; then
    echo There is no process on $PORT
    return 2>/dev/null || exit
fi

if [ -f apache-tomcat-$TOMCAT/bin/shutdown.sh ]; then 
    echo "Stopping Tomcat"
    ./apache-tomcat-$TOMCAT/bin/shutdown.sh
fi

# wait 2 seconds and see if we are down
sleep 2
PROCESS_ID=`lsof -i :$PORT | grep java | awk '{print $2}'`
if [ "$PROCESS_ID" == "" ]; then
    return 2>/dev/null || exit
else
    echo Stopping process $PROCESS_ID
    kill $PROCESS_ID
    sleep 2
fi

# Try a second time
PROCESS_ID=`lsof -i :$PORT | grep java | awk '{print $2}'`
if [ "$PROCESS_ID" == "" ]; then
    return 2>/dev/null || exit
else
    echo Waiting for process $PROCESS_ID
    sleep 5
    echo Shutting down process $PROCESS_ID
    kill -9 $PROCESS_ID
fi

