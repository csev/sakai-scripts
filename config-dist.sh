#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

# This branch demands Java 21.  Check sdkman first, before config.sh.
EXPECTED_JAVA_MAJOR=21
EXPECTED_SDK_JAVA=21.0.12-tem

if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]
then
    echo "Setting up sdkman..."
    export HOME=~
    unset SDKMAN_DIR
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    echo JAVA_HOME $JAVA_HOME
    if command -v sdk >/dev/null 2>&1
    then
        sdk current java 2>/dev/null || true
    fi
else
    echo "sdkman is not installed. This branch expects Java $EXPECTED_JAVA_MAJOR via sdkman."
    echo
    echo curl -s \"https://get.sdkman.io\" \| bash
    echo source ~/.sdkman/bin/sdkman-init.sh
    echo sdk install java $EXPECTED_SDK_JAVA
    echo sdk use java $EXPECTED_SDK_JAVA
    echo
    exit 1
fi

JAVA_MAJOR=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
if [[ "$JAVA_MAJOR" != "$EXPECTED_JAVA_MAJOR" ]];
then
    echo "This branch expects Java $EXPECTED_JAVA_MAJOR (Sakai jakarta / 26)."
    java --version 2>/dev/null || true
    echo
    if [ -d "$HOME/.sdkman/candidates/java/$EXPECTED_SDK_JAVA" ]
    then
        echo "$EXPECTED_SDK_JAVA is installed. Activate it:"
        echo
        echo sdk use java $EXPECTED_SDK_JAVA
    elif ls -d "$HOME/.sdkman/candidates/java/$EXPECTED_JAVA_MAJOR"* >/dev/null 2>&1
    then
        echo "A Java $EXPECTED_JAVA_MAJOR SDK is installed. Activate it:"
        echo
        ls -1 "$HOME/.sdkman/candidates/java" | grep "^$EXPECTED_JAVA_MAJOR"
        echo
        echo sdk use java $EXPECTED_SDK_JAVA
    else
        echo "Install and activate Java $EXPECTED_JAVA_MAJOR:"
        echo
        echo sdk install java $EXPECTED_SDK_JAVA
        echo sdk use java $EXPECTED_SDK_JAVA
    fi
    echo
    exit 1
fi

# If you want to change this file (and you should)
# Simply copy it to config.sh and make your changes
# there so git ignores your local copy.
#
# Do not put Java or Tomcat versions in config.sh.  This branch owns those.
# A leftover config.sh from main cannot change them or reject Java 21.
# To force a different Tomcat zip only, set TOMCAT_OVERRIDE in config.sh.

# Local config.sh is settings only (repo, mysql, ports).  Java gates in a
# leftover copy are skipped by sourcing from "Settings start here".
USE_DIST_SETTINGS=1
if [ -f "config.sh" ]
then
    echo "Taking configuration from local config.sh"
    if grep -q '^# Settings start here' config.sh
    then
        CONFIG_SETTINGS=$(mktemp)
        sed -n '/^# Settings start here/,$p' config.sh > "$CONFIG_SETTINGS"
        source "$CONFIG_SETTINGS"
        rm -f "$CONFIG_SETTINGS"
        USE_DIST_SETTINGS=0
    else
        echo "WARNING: config.sh has no 'Settings start here' marker; using branch defaults"
    fi
else
    echo
    echo "Using setup defaults from config-dist.sh."
    echo "If you want to override configuration settings, copy"
    echo "config-dist.sh to config.sh and edit config.sh"
    echo
fi

# Settings start here (repo, mysql, ports, etc.).  Not Java.  Not Tomcat.
if [ "$USE_DIST_SETTINGS" = "1" ]
then
    # Change GIT_REPO and replace "sakaiproject" with your git user name
    # so that you checkout your forked sakai repository
    GIT_REPO=https://github.com/sakaiproject/sakai.git

    TIMEZONE="US/Eastern"

    # Set this to the MYSQL root passsword.  MAMP's default
    # is root so you can leave it alone if you are using MAMP
    MYSQL_ROOT_PASSWORD=root
    MYSQL_ROOT_USER=root
    MYSQL_HOST=localhost
    MYSQL_PORT=3306
    LOCAL_HOST_ACCESS=localhost

    MYSQL=8.0.25
    MYSQL=maria
    THREADS=1

    # Leave LOG_DIRECTORY value empty to leave the logs inside tomcat
    # LOG_DIRECTORY=/var/www/html/sakai/logs/tomcat
    LOG_DIRECTORY=
    PORT=8080
    SHUTDOWN_PORT=8005
    MYSQL_DATABASE=sakai25
    MYSQL_USER=sakaiuser
    MYSQL_PASSWORD=sakaipass

    # Defaults for Mac/MAMP MySQL
    if [ -f "/Applications/MAMP/Library/bin/mysql80/bin/mysql" ] ; then
        echo "You are using MAMP..."
        MYSQL_PORT=8889
        MYSQL_SOURCE="jdbc:mariadb://127.0.0.1:8889/$MYSQL_DATABASE?useUnicode=true\&characterEncoding=UTF-8"
        MYSQL_COMMAND="/Applications/MAMP/Library/bin/mysql80/bin/mysql -S /Applications/MAMP/tmp/mysql/mysql.sock -u $MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWORD"
        HIBERNATE_DIALECT=org.hibernate.dialect.MySQLDialect

    # Defaults for Mac/MAMP MySQL on 3306
    elif [ -f "/Applications/XAMPP/xamppfiles/bin/mysql" ] ; then
        echo "You are using XAMPP..."
        MYSQL_ROOT_PASSWORD=
        MYSQL_SOURCE="jdbc:mariadb://$MYSQL_HOST:3306/$MYSQL_DATABASE?useUnicode=true\&characterEncoding=UTF-8"
        MYSQL_COMMAND="/Applications/XAMPP/xamppfiles/bin/mysql  --port=$MYSQL_PORT"
        HIBERNATE_DIALECT=org.hibernate.dialect.MySQLDialect

    # Ubuntu / normal 3306 MariaDB
    else
        echo "Using command line SQL"
        MYSQL_COMMAND="mysql -u $MYSQL_ROOT_USER --host=$MYSQL_HOST --port=$MYSQL_PORT --password=$MYSQL_ROOT_PASSWORD"
        MYSQL_SOURCE="jdbc:mariadb://$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DATABASE?useUnicode=true\&characterEncoding=UTF-8"
        HIBERNATE_DIALECT=org.hibernate.dialect.MariaDBDialect
    fi

    # Override if auto-detect is wrong (MAMP/XAMPP=MySQL, Linux=MariaDB)
    # HIBERNATE_DIALECT=org.hibernate.dialect.MariaDBDialect
    # HIBERNATE_DIALECT=org.hibernate.dialect.MySQLDialect

    # TOMCAT_OVERRIDE=10.1.60
fi

# This branch demands these versions.  Always applied last.
if [ -n "$TOMCAT" ] && [ "$TOMCAT" != "10.1.60" ] && [ -z "$TOMCAT_OVERRIDE" ]
then
    echo "Ignoring TOMCAT=$TOMCAT from config.sh; this branch uses 10.1.60"
fi

TOMCAT=10.1.60
if [ -n "$TOMCAT_OVERRIDE" ]
then
    echo "Using TOMCAT_OVERRIDE=$TOMCAT_OVERRIDE"
    TOMCAT=$TOMCAT_OVERRIDE
fi
