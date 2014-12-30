# I am not an expert here, but these helped me
# get started on ubuntu -- Chuck Sun Jan 23 11:00:22 EST 2011
# If you want to do this on Amazon EC2
# Pick a ami from this page:
# http://uec-images.ubuntu.com/releases/10.04/release/
# Matt suggested this ami for me:  ami-3e02f257
#
# Note from Seth - can use sun-java7-jdk instead fo java-7-openjdk
# See commented out sun versions below
cat << EOF 
Simple Startup Process For Ubuntu - Do this By Hand

-- Fix your .profile and re-log in, checking the JAVA_OPTS and MAVEN_OPTS

sudo apt-get install subversion
mkdir dev
cd dev
svn co https://source.sakaiproject.org/contrib//csev/trunk/scripts/sakai-full/
cd sakai-full 
sh ubuntu.sh

Then continue with a 
-- co.sh to check it all out 
-- na.sh to make a new tomcat
-- qmv.sh to compile it all
-- Then go start your Tomcat and apache.../bin/startup.sh
-- tail -f apache.../logs/catalina.out

EOF

# The subversion should already be there, but it is OK to double check
sudo apt-get install subversion
sudo apt-get install maven
sudo apt-get install curl
sudo apt-get install unzip
sudo apt-get install python-software-properties
sudo add-apt-repository "deb http://archive.canonical.com/ lucid partner"
sudo apt-get update
# sudo apt-get install sun-java7-jdk
sudo apt-get install openjdk-7-jdk

# for the Morpheus SASS support you need these as well
sudo apt-get install ruby
sudo apt-get install ruby-dev
sudo apt-get install make

echo 'You may also need JAVA_HOME=/usr/lib/jvm/default-java/; export JAVA_HOME'


