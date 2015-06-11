

cp apache-tomcat-8.0.23/conf/catalina.properties /tmp/cataling.properties
vi apache-tomcat-8.0.23/conf/catalina.properties

... Make changes 

diff -u /tmp/catalina.orig apache-tomcat-8.0.23/conf/catalina.properties > patches/tomcat-8.0.23.patch 

vi patches/tomcat-8.0.23.patch

Make the top have the same file name in both places:

--- apache-tomcat-8.0.23/conf/catalina.properties   2015-06-11 14:27:36.000000000 -0400
+++ apache-tomcat-8.0.23/conf/catalina.properties   2015-06-11 14:27:36.000000000 -0400

