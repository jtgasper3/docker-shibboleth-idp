#!/bin/sh

cd /opt/shibboleth-idp/bin

rm -rf ../credentials/
rm -rf ../metadata/
rm -rf ../conf/

./build.sh init gethostname metadata-gen
