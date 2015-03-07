#!/bin/sh

cp -R /opt/shibboleth-idp/conf/ /external-mount/
cp -R /opt/shibboleth-idp/credentials/ /external-mount/
cp -R /opt/shibboleth-idp/metadata/ /external-mount/
cp -R /opt/iam-jetty-base/etc/keystore /external-mount/
cp -R /opt/shibboleth-idp/webapp/ /external-mount/


