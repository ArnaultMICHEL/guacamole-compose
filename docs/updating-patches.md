# How to regenrate patches

## renew 0.enable-tomcat-ssl.patch

1. Generate init/server.xml.orig and copy it to init/server.xml

   ```bash
   source .load.env
   # get the original server.xml
   touch init/server.xml.orig
   docker run --rm --name guacamole-setup \
     docker.io/guacamole/guacamole:${GUACAMOLE_VERSION} \
     cat /usr/local/tomcat/conf/server.xml > init/server.xml.orig

   # make a copy to patch
   cp init/server.xml.orig init/server.xml
   ```

2. modify **init/server.xml**

3. regenerate the patch

   ```bash
   diff -Naur init/server.xml.orig init/server.xml > config/guacamole/0.enable-tomcat-ssl.patch
   ```

## renew 1.add-guacadmin-email.patch

1. Generate init/initdb.sql.orig and copy it to init/initdb.sql

   ```bash
   source .load.env
   docker run --rm \
     docker.io/guacamole/guacamole:${GUACAMOLE_VERSION} \
       /opt/guacamole/bin/initdb.sh --postgresql > init/initdb.sql.orig
   cp init/initdb.sql.orig init/initdb.sql
   ```

2. modify **init/initdb.sql**

3. regenerate the patch

   ```bash
   diff -Naur init/initdb.sql.orig init/initdb.sql > config/guacamole/1.add-guacadmin-email.patch
   ```
