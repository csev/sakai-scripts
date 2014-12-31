#! /bin/bash
source config-dist.sh
if [ "$PORT" == "" ]; then 
    echo "Bad configuration or wrong shell"; 
    exit 
fi

# bash nightly.sh 2>&1 | tee /tmp/nightly-`date '+%Y-%m-%dT%H:%M'`.out

echo "Starting nightly build process"
date

rm -rf trunk
bash co.sh

bash stop.sh
bash db.sh
rm -f $LOG_DIRECTORY/*
bash na.sh

rm -rf ~/.m2/repository/org/sakaiproject
bash qmv.sh
bash start.sh

