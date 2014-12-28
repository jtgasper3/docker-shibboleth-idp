#!/bin/sh
set -x

export JAVA_HOME=/opt/jre1.7.0_71
export JETTY_HOME=/opt/jetty/
export JETTY_BASE=/opt/iam-jetty-base/
export PATH=$PATH:$JAVA_HOME/bin

/etc/init.d/jetty start

#Override the exit command to prevent accidental container destruction.
echo 'alias exit="This will kill the container. Use Ctrl+p, Ctrl+q to detach or Ctrl+p, Ctrl+d to exit"' > ~/.bashrc
bash 