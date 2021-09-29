
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

# If you have git, 

# git clone	https://github.com/csev/sakai-scripts.git
# cd sakai-scripts 
# bash ubuntu.sh

# If you don't have git - type these two commands and then

apt-get update
apt-get -y install git curl unzip zip vim

# git clone	https://github.com/csev/sakai-scripts.git
# cd sakai-scripts 
# bash ubuntu.sh

# Install sdkman
curl -s "https://get.sdkman.io" | bash
source "/root/.sdkman/bin/sdkman-init.sh"

sdk install java 11.0.12-tem
sdk install maven

source "/root/.sdkman/bin/sdkman-init.sh"

# Install mysql
# Make the password root - or override the root password in 
# config.sh - a copied and edited version of config-dist.php
apt-get -y install mariadb-server
apt-get -y install mariadb-client

service mysql start

# for chrome headless you need this
## apt-get install -y libgbm-dev libxkbcommon-x11-0 libgtk-3-0

# for the Morpheus SASS support you need these as well
# Is this needed for Sakai 22 / JDK 11
## apt-get -y install ruby ruby-dev install make

