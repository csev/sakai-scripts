#! /bin/sh
source config-dist.sh

# sh nightly.sh 2>&1 | tee /tmp/nightly-`date '+%Y-%m-%dT%H:%M'`.out

echo "Starting nightly build process"
date

# rm -rf ~/.m2/repository/org/sakaiproject
rm -rf trunk
sh na.sh
sh co.sh

sh stop.sh
rm -f $LOG_DIRECTORY/*
sh db.sh

sh qmv.sh
sh start.sh

