#! /bin/bash
# Launch this Tomcat and return. No stop, no log wipe, no tail.
# start.sh and watchdog.sh both call this.

if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

cd "$(dirname "$0")" || exit 1

# A fresh process (watchdog, or this script run by hand) has to load
# config itself. start.sh exports PORT after sourcing config-dist.sh,
# and also exports JAVA_OPTS, including -debugger when requested.
if [ "$PORT" = "" ]; then
    source config-dist.sh
    if [ "$PORT" = "" ]; then
        echo "Bad configuration or wrong shell"
        exit 1
    fi
fi

if [ "$JAVA_OPTS" = "" ]; then
    source tomcat-env.sh
fi

if [ "$1" = "-debugger" ]; then
    case " $JAVA_OPTS " in
        *-agentlib:jdwp=*) ;;
        *)
            echo "Starting Tomcat in debug mode on port 8000"
            export JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000"
            export CATALINA_OPTS="$CATALINA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000"
            ;;
    esac
fi

if [ ! -x "apache-tomcat-$TOMCAT/bin/startup.sh" ]; then
    echo "no apache-tomcat-$TOMCAT/bin/startup.sh — run na.sh first"
    exit 1
fi

export CATALINA_HOME="$(pwd)/apache-tomcat-$TOMCAT"
export CATALINA_BASE="$CATALINA_HOME"
export CATALINA_PID="$CATALINA_BASE/temp/catalina.pid"
mkdir -p "$CATALINA_BASE/temp"

./apache-tomcat-$TOMCAT/bin/startup.sh
