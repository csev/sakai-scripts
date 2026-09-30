Tomcat 10.1.60 patches for this jakarta branch.

context.xml, setenv.sh, and catalina.properties are named
`apache-10.1.60-*`.  `na.sh` copies them into a fresh Tomcat.

server-localhost-10.xml is the default `server.xml`.
HTTPS samples are the `-internal-https-10`, `-external-https-10`,
and `-self-signed-10` files.

To refresh catalina.properties after a Tomcat upgrade:

    cp apache-tomcat-10.1.60/conf/catalina.properties /tmp/catalina.orig
    # add serializer.jar to jarsToSkip
    diff -u /tmp/catalina.orig apache-tomcat-10.1.60/conf/catalina.properties
