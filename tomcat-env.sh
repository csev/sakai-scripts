#! /bin/bash
# Shared Tomcat runtime flags. start-tomcat.sh sources this, and
# start.sh sources it too so it can print JAVA_OPTS before the launch.
# Source this after config-dist.sh, from the scripts directory.
#
# setenv.sh sources it with TOMCAT_ENV_JDK_ONLY=1 so a direct
# startup.sh still gets the JDK 21 opens without rebuilding JAVA_OPTS.

if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

export JDK21_OPTS="\
--add-opens=java.base/java.io=ALL-UNNAMED \
--add-opens=java.base/java.lang=ALL-UNNAMED \
--add-opens=java.base/java.lang.invoke=ALL-UNNAMED \
--add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
--add-exports=java.base/java.lang.reflect=ALL-UNNAMED \
--add-opens=java.base/java.math=ALL-UNNAMED \
--add-opens=java.base/java.net=ALL-UNNAMED \
--add-opens=java.base/java.nio=ALL-UNNAMED \
--add-opens=java.base/java.text=ALL-UNNAMED \
--add-opens=java.base/java.time=ALL-UNNAMED \
--add-opens=java.base/java.util=ALL-UNNAMED \
--add-opens=java.base/java.util.concurrent=ALL-UNNAMED \
--add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED \
--add-opens=java.base/java.util.concurrent.locks=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.access=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.misc=ALL-UNNAMED \
--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED \
--add-opens=java.base/sun.nio.ch=ALL-UNNAMED \
--add-exports=java.base/sun.nio.ch=ALL-UNNAMED \
--add-opens=java.base/sun.reflect.generics.reflectiveObjects=ALL-UNNAMED \
--add-exports=java.base/sun.reflect.generics.reflectiveObjects=ALL-UNNAMED \
--add-opens=java.base/sun.util.calendar=ALL-UNNAMED \
--add-opens=java.desktop/java.awt.font=ALL-UNNAMED \
--add-opens=java.desktop/javax.swing.tree=ALL-UNNAMED \
--add-opens=java.management/com.sun.jmx.mbeanserver=ALL-UNNAMED \
--add-exports=java.management/com.sun.jmx.mbeanserver=ALL-UNNAMED \
--add-opens=java.management/sun.management=ALL-UNNAMED \
--add-opens=java.sql/java.sql=ALL-UNNAMED \
--add-opens=jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED \
--add-exports=jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED \
--add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED"

if [ "$TOMCAT_ENV_JDK_ONLY" = "1" ]; then
    return 0
fi

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

export JAVA_OPTS="-server -Xms1g -Xmx2g -Djava.awt.headless=true -XX:+UseCompressedOops -Dhttp.agent=Sakai -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false -Dsakai.home=${SAKAI_HOME} -Duser.timezone=${TIMEZONE} -Dsakai.cookieName=SAKAI2SESSIONID ${SAKAI_DEMO} ${JMX_REMOTE} -Dwicket.configuration=${WICKET_CONFIG} ${JDK21_OPTS} ${JDK11_GC}"
export CATALINA_OPTS="$JAVA_OPTS"
