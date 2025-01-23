#! /bin/bash
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi
source config-dist.sh
if [ "$PORT" == "" ]; then
    echo "Bad configuration or wrong shell";
    exit
fi

bash stop.sh
bash start.sh
bash tail.sh
