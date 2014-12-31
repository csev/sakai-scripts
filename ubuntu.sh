
# This assumes mysql and mysql server are installed
# As in a LAMP distro from DigitalOcean

# The subversion should already be there, but it is OK to double check
sudo apt-get update
sudo apt-get -y install git
sudo apt-get -y install subversion
sudo apt-get -y install maven
sudo apt-get -y install curl
sudo apt-get -y install unzip
sudo apt-get -y install python-software-properties
sudo apt-get -y install openjdk-7-jdk

# for the Morpheus SASS support you need these as well
sudo apt-get -y install ruby
sudo apt-get -y install ruby-dev
sudo apt-get -y install make

