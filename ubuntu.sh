
if [ "$BASH" = "" ] ;then echo "Please run with bash"; exit 1; fi

# If you have git, 

# git clone	https://github.com/csev/sakai-scripts.git
# cd sakai-scripts 
# bash ubuntu.sh

# If you don't have git - type these two commands and then

apt-get update
apt-get -y install git curl unzip zip vim
apt install mariadb-client-core-10.6
apt-get install -y nfs-common

# In Ubuntu 20 the fonts may not get installed out of the box
# https://github.com/adoptium/adoptium-support/issues/70
apt-get install cabextract fonts-liberation libfontenc1 x11-common xfonts-encodings xfonts-utils
apt-get install fontconfig

# Install sdkman
curl -s "https://get.sdkman.io" | bash
source "/root/.sdkman/bin/sdkman-init.sh"

sdk install java 17.0.13-tem
sdk install maven 3.8.1
sdk install mvnd

source "/root/.sdkman/bin/sdkman-init.sh"

# Installing certbot - https://certbot.eff.org/lets-encrypt/ubuntufocal-apache
snap install core
snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot


