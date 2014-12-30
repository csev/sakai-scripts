#! /bin/bash
source config-dist.sh

# sh nightly.sh 2>&1 | tee /tmp/nightly-`date '+%Y-%m-%dT%H:%M'`.out

echo "Starting nightly build process"
date

# rm -rf ~/.m2/repository/org/sakaiproject
rm -rf trunk
bash na.sh
bash co.sh

bash stop.sh
rm -f $LOG_DIRECTORY/*
bash db.sh

bash qmv.sh
bash start.sh

