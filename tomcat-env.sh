#! /bin/bash
# Shared Tomcat runtime flags. start-tomcat.sh sources this, and
# start.sh sources it too so it can print JAVA_OPTS before the launch.
# Source this after config-dist.sh, from the scripts directory.

if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

export JDK11_OPTS="--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED --add-exports=java.base/sun.nio.ch=ALL-UNNAMED --add-exports=java.management/com.sun.jmx.mbeanserver=ALL-UNNAMED --add-exports=jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED --add-exports=java.base/sun.reflect.generics.reflectiveObjects=ALL-UNNAMED --add-opens jdk.management/com.sun.management.internal=ALL-UNNAMED --illegal-access=permit"

# This may be reconfigured to be a different garbage collector, but it will auto select
export JDK11_GC="-Xlog:gc"
# This should either be development or deployment
export WICKET_CONFIG="development"
# Define where your sakai home is
export SAKAI_HOME="$(pwd)/apache-tomcat-$TOMCAT/sakai"

# JMX and demo are left off. The empty expansions keep JAVA_OPTS
# identical to the historical start.sh line.
export JMX_REMOTE=""
export SAKAI_DEMO=""

export JAVA_OPTS="-server -Xms1g -Xmx2g -Djava.awt.headless=true -XX:+UseCompressedOops -Dhttp.agent=Sakai -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false -Dsakai.home=${SAKAI_HOME} -Duser.timezone=${TIMEZONE} -Dsakai.cookieName=SAKAI2SESSIONID ${SAKAI_DEMO} ${JMX_REMOTE} -Dwicket.configuration=${WICKET_CONFIG} ${JDK11_OPTS} ${JDK11_GC}"
export CATALINA_OPTS="$JAVA_OPTS"
