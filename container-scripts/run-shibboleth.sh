#!/bin/sh
set -x

export JAVA_HOME=/opt/jre1.8.0_60
export JETTY_HOME=/opt/jetty/
export JETTY_BASE=/opt/iam-jetty-base/
export PATH=$PATH:$JAVA_HOME/bin

sed -i "s/^-Xmx.*$/-Xmx$JETTY_MAX_HEAP/g" /opt/iam-jetty-base/start.ini

/etc/init.d/jetty run
