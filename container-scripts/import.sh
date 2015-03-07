#!/bin/sh
echo "Checking for items to update (Shib conf, Shib credentials, Shib metadata, Shib webapp artifacts, Jetty keystore)."

if [ -d /external-mount/conf/ ];
then
	echo "Updading the Shibboleth IdP conf."
	cp -R /external-mount/conf/ /opt/shibboleth-idp/
fi

if [ -d /external-mount/credentials/ ];
then
	echo "Updating the Shibboleth credentials."
	cp -R /external-mount/credentials/ /opt/shibboleth-idp/
fi

if [ -d /external-mount/metadata/ ];
then
	echo "Updating the Shibboleth metadata."
	cp -R /external-mount/metadata/ /opt/shibboleth-idp/
fi

if [ -d /external-mount/webapp/ ];
then
	echo "Updating the Shibboleth webapp artifacts."
	cp -R /external-mount/webapp/ /opt/shibboleth-idp/webapp/

	echo "Rebuilding the idp.war file"
	cd /opt/shibboleth-idp
	bin/build.sh
fi

if [ -d /external-mount/keystore ];
then
	echo "Updating the Jetty keystore."
	cp /external-mount/keystore /opt/iam-jetty-base/etc/keystore
fi
