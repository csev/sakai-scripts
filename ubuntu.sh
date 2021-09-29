
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

# git should be there - but lets double check - most
# will have installed git by hand to get this script
# in the first place

apt-get update
apt-get -y install git curl unzip zip

# Install sdkman
curl -s "https://get.sdkman.io" | bash
source "/root/.sdkman/bin/sdkman-init.sh"

sdk install java 11.0.12-tem
sdk install maven

# Install mysql
# Make the password root - or override the root password in 
# config.sh - a copied and edited version of config-dist.php
apt-get -y install mariadb-server
apt-get -y install mariadb-client

# for chrome headless you need this
apt-get install -y libgbm-dev libxkbcommon-x11-0 libgtk-3-0

# for the Morpheus SASS support you need these as well
# Is this needed for Sakai 22 / JDK 11
apt-get -y install ruby ruby-dev install make

