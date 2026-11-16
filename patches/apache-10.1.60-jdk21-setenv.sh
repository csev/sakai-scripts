export CATALINA_OPTS="-Dsakai.demo=false"

# JDK 21 --add-opens live in tomcat-env.sh. na.sh copies this file to
# apache-tomcat-*/bin/, so the scripts directory is two levels up.
# Skip the append when start-tomcat.sh already put the opens
# in JAVA_OPTS, so the JVM does not get the list twice.
_SAKAI_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [ -f "$_SAKAI_SCRIPTS/tomcat-env.sh" ]; then
    TOMCAT_ENV_JDK_ONLY=1
    source "$_SAKAI_SCRIPTS/tomcat-env.sh"
    unset TOMCAT_ENV_JDK_ONLY
    case " $JAVA_OPTS " in
        *" --add-opens=java.base/java.math="*) ;;
        *) JAVA_OPTS="$JAVA_OPTS $JDK21_OPTS" ;;
    esac
fi
