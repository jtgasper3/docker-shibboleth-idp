#!/bin/sh
set -x

export JAVA_HOME=/opt/jre1.7.0_79
export JETTY_HOME=/opt/jetty/
export JETTY_BASE=/opt/iam-jetty-base/
export PATH=$PATH:$JAVA_HOME/bin

/etc/init.d/jetty run
