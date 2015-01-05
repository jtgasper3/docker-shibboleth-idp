#!/bin/sh
echo "Checking for items to update (Shib conf, Shib credentials, Shib metadata, Shib webapp artifacts, Jetty keystore)."

if [ -d /data-import/conf/ ];
then
	echo "Updading the Shibboleth IdP conf."
	cp -R /data-import/conf/ /opt/shibboleth-idp/
fi

if [ -d /data-import/credentials/ ];
then
	echo "Updating the Shibboleth credentials."
	cp -R /data-import/credentials/ /opt/shibboleth-idp/
fi

if [ -d /data-import/metadata/ ];
then
	echo "Updating the Shibboleth metadata."
	cp -R /data-import/metadata/ /opt/shibboleth-idp/
fi

if [ -d /data-import/webapp/ ];
then
	echo "Updating the Shibboleth webapp artifacts."
	cp -R /data-import/webapp/ /opt/shibboleth-identityprovider-2.4.3/src/main/

	echo "Rebuilding the idp.war file"
	cd /opt/shibboleth-identityprovider-2.4.3
	printf '\n\n' | ./install.sh 
fi

if [ -d /data-import/keystore ];
then
	echo "Updating the Jetty keystore."
	cp /data-import/keystore /opt/iam-jetty-base/etc/keystore
fi
