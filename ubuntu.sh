
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

# git should be there - but lets double check - most
# will have installed git by hand to get this script
# in the first place

sudo apt-get update
sudo apt-get -y install git
sudo apt-get -y install openjdk-8-jdk
sudo apt-get -y install maven
sudo apt-get -y install curl
sudo apt-get -y install unzip
sudo apt-get -y install python-software-properties

# Install mysql
# Make the password root - or override the root password in 
# config.sh - a copied and edited version of config-dist.php
sudo apt-get install mysql-server
sudo apt-get install mysql-client
sudo apt-get install libmysql-java

# for the Morpheus SASS support you need these as well
sudo apt-get -y install ruby
sudo apt-get -y install ruby-dev
sudo apt-get -y install make

