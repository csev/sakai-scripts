#! /bin/bash
# Cron-safe Tomcat watchdog.
#
# If nothing is listening on $PORT and no Bootstrap process for this
# Tomcat is already running, start it. Quiet when Tomcat is up, so cron
# does not mail you every run.
#
# Calls start-tomcat.sh, not start.sh. start.sh runs stop.sh, deletes
# logs, and tails catalina.out until the job is killed.
#
# Touch watchdog.off in this directory to pause checks (for example
# while nightly.sh is rebuilding).
#
# Requires a local config.sh. Refuses to run on config-dist.sh defaults.
#
# crontab -e
#
#     */5 * * * * /absolute/path/to/watchdog.sh
#
# The path has to be absolute. Cron starts in $HOME. This script cds to
# its own directory. On dev1 that entry is:
#
#     */5 * * * * /root/sakai-scripts/watchdog.sh
#
# Restarts are appended to watchdog.log next to this script. A healthy
# Tomcat prints nothing, so cron stays quiet.

if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

# cron's PATH is tiny. lsof lives in /usr/sbin on macOS.
# Append these directories. Prepending /usr/bin hides a newer java
# already on PATH while JAVA_HOME still points at Java 17.
export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/usr/local/bin"

cd "$(dirname "$0")" || exit 1
DIR="$(pwd)"
LOG="$DIR/watchdog.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') watchdog: $*" | tee -a "$LOG"
}

if [ ! -f "$DIR/config.sh" ]; then
    log "config.sh is missing. Copy config-dist.sh to config.sh and edit it."
    exit 1
fi

if [ -f "$DIR/watchdog.off" ]; then
    exit 0
fi

# config-dist.sh exits the shell on failure, and it is chatty about sdkman.
# Probe in a subshell so a Java/sdkman failure is logged instead of vanishing.
if ! bash -c 'source ./config-dist.sh' >"$DIR/watchdog-config.err" 2>&1; then
    log "config-dist.sh failed"
    tee -a "$LOG" < "$DIR/watchdog-config.err"
    exit 1
fi
rm -f "$DIR/watchdog-config.err"
source config-dist.sh >/dev/null 2>&1
if [ "$PORT" = "" ]; then
    log "bad configuration or wrong shell"
    exit 1
fi

CATALINA_HOME="$DIR/apache-tomcat-$TOMCAT"
export CATALINA_HOME
export CATALINA_BASE="$CATALINA_HOME"
export CATALINA_PID="$CATALINA_BASE/temp/catalina.pid"

if [ ! -x "$CATALINA_HOME/bin/startup.sh" ]; then
    log "no $CATALINA_HOME/bin/startup.sh — run na.sh first"
    exit 1
fi

if ! command -v lsof >/dev/null 2>&1; then
    log "lsof is not installed"
    exit 1
fi

listening() {
    lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1
}

# A live JVM that has not bound the port yet (Sakai is slow) must not
# be joined by a second Tomcat.
bootstrap_running() {
    ps axww -o command= 2>/dev/null | grep -F -- "-Dcatalina.base=$CATALINA_BASE" | grep -F -- "org.apache.catalina.startup.Bootstrap" >/dev/null 2>&1
}

if listening; then
    exit 0
fi

if bootstrap_running; then
    log "port $PORT is not listening, but Tomcat is already starting; leaving it alone"
    exit 0
fi

# One watchdog at a time. mkdir is atomic. Drop a stale lock after 15 minutes
# so a killed cron job cannot wedge restarts forever.
LOCK="$CATALINA_BASE/temp/watchdog.lock"
mkdir -p "$CATALINA_BASE/temp"
if ! mkdir "$LOCK" 2>/dev/null; then
    if [ -d "$LOCK" ]; then
        now=$(date +%s)
        locked=$(stat -f %m "$LOCK" 2>/dev/null || stat -c %Y "$LOCK" 2>/dev/null || echo "$now")
        if [ $((now - locked)) -gt 900 ]; then
            log "removing stale lock $LOCK"
            rmdir "$LOCK" 2>/dev/null || rm -rf "$LOCK"
            mkdir "$LOCK" 2>/dev/null || exit 0
        else
            exit 0
        fi
    else
        exit 0
    fi
fi
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

log "Tomcat is down (nothing listening on $PORT). Starting $CATALINA_HOME"
if bash "$DIR/start-tomcat.sh" >> "$LOG" 2>&1; then
    log "start-tomcat.sh returned. catalina.out is under $CATALINA_HOME/logs"
else
    log "start-tomcat.sh failed with status $?"
    exit 1
fi
