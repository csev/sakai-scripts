#! /bin/sh
source condig-dist.sh

# rm -rf ~/.m2/repository/org/sakaiproject
rm -rf trunk
sh db.sh
sh na.sh
sh co.sh
sh qmv.sh
