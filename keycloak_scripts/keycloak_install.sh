#! /bin/sh

. /tmp/keycloak_config/DEFAULTS.sh
if [ -f /tmp/keycloak_config/CONFIG.sh ] ; then
	. /tmp/keycloak_config/CONFIG.sh
fi

# Install java 11

yum -y install java-11-openjdk

# install keycloak

groupadd keycloak
useradd -r -g keycloak -d /opt/keycloak -s /sbin/nologin keycloak

cd /opt
curl -L -o keycloak-$KEYCLOAK_VERSION.zip https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.zip
unzip keycloak-$KEYCLOAK_VERSION.zip
mv keycloak-$KEYCLOAK_VERSION keycloak

chown -R keycloak:keycloak keycloak

tar -C /tmp/keycloak_config/fs -cf - . | tar -C / -xf -
chmod a+x /opt/keycloak/bin/launch.sh

sed -i -e "s/jboss.http.port:8080/jboss.http.port:$HTTP_PORT/" /opt/keycloak/standalone/configuration/standalone.xml
sed -i -e "s#\${keycloak.frontendUrl:}#http://${SERVER_NAME}:${HTTP_PORT}/auth#" /opt/keycloak/standalone/configuration/standalone.xml

/opt/keycloak/bin/add-user-keycloak.sh -r master -u $ADMIN_USER -p $ADMIN_PW

systemctl daemon-reload
systemctl enable keycloak
systemctl start keycloak

sleep 10

/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:$HTTP_PORT/auth \
	--realm master --user $ADMIN_USER --password $ADMIN_PW

/opt/keycloak/bin/kcadm.sh update realms/master -s sslRequired=NONE

LOCAL_REALM=local-$(echo $RANDOM)
/opt/keycloak/bin/kcadm.sh create realms -s realm=$LOCAL_REALM -s enabled=true -o
/opt/keycloak/bin/kcadm.sh create users -s username=localuser -s enabled=true -s email=localuser@local.domain -s firstName=Local -s lastName=User -r $LOCAL_REALM
/opt/keycloak/bin/kcadm.sh set-password -r $LOCAL_REALM --username localuser -p localpass
/opt/keycloak/bin/kcadm.sh create clients -r $LOCAL_REALM -f /tmp/keycloak_config/samltest-client.json


DOMINO_REALM=domino-$(echo $RANDOM)
/opt/keycloak/bin/kcadm.sh create realms -s realm=$DOMINO_REALM -s enabled=true -o
/opt/keycloak/bin/kcadm.sh create clients -r $DOMINO_REALM -f /tmp/keycloak_config/samltest-client.json

