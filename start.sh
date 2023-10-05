#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi
source config-dist.sh
if [ "$PORT" == "" ]; then 
    echo "Bad configuration or wrong shell"; 
    exit 
fi

source stop.sh

export JDK11_OPTS="--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED --add-exports=java.base/sun.nio.ch=ALL-UNNAMED --add-exports=java.management/com.sun.jmx.mbeanserver=ALL-UNNAMED --add-exports=jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED --add-exports=java.base/sun.reflect.generics.reflectiveObjects=ALL-UNNAMED --add-opens jdk.management/com.sun.management.internal=ALL-UNNAMED --illegal-access=permit"

# This may be reconfigured to be a different garbage collector, but it will auto select
export JDK11_GC="-Xlog:gc"
# This should either be development or deployment
export WICKET_CONFIG="development"
# Define where you sakai home is
export SAKAI_HOME="`pwd`/apache-tomcat-$TOMCAT/sakai"
echo $SAKAI_HOME

echo Timezone can be set in config.sh.  Currently:  $TIMEZONE

export JMX_REMOTE="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8089 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
export SAKAI_DEMO="-Dsakai.demo=false"

export JMX_REMOTE=""
export SAKAI_DEMO=""

# This starts up sakai with demo mode with 2g of ram
export JAVA_OPTS="-server -Xms1g -Xmx2g -Djava.awt.headless=true -XX:+UseCompressedOops -Dhttp.agent=Sakai -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false -Dsakai.home=${SAKAI_HOME} -Duser.timezone=${TIMEZONE} -Dsakai.cookieName=SAKAI2SESSIONID ${SAKAI_DEMO} ${JMX_REMOTE} -Dwicket.configuration=${WICKET_CONFIG} ${JDK11_OPTS} ${JDK11_GC}"

export CATALINA_OPTS="-server -Xms1g -Xmx2g -Djava.awt.headless=true -XX:+UseCompressedOops -Dhttp.agent=Sakai -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false -Dsakai.home=${SAKAI_HOME} -Duser.timezone=${TIMEZONE} -Dsakai.cookieName=SAKAI2SESSIONID ${SAKAI_DEMO} ${JMX_REMOTE} -Dwicket.configuration=${WICKET_CONFIG} ${JDK11_OPTS} ${JDK11_GC}"

# export JAVA_OPTS="$JAVA_OPTS -verbose:class"
echo JAVA_OPTS:
echo $JAVA_OPTS

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
