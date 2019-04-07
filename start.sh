#!/bin/sh

export PATH=$PATH:$HOME/bin
export NODE_HOME="/usr/node-v10.13.0/bin"
export DOCSIFY_HOME="/usr/node-v10.13.0/node_global/lib/node_modules/docsify-cli"

PATH=$NODE_HOME/bin:$DOCSIFY_HOME/bin:$PATH


isRun=`ps -ef | grep "docsify" | grep -v grep | wc -l`
if [ $isRun = "1" ]; then
   echo "docsify is runing....."
   echo "automatically stop docsify service"
   ps -ef | grep "docsify" | grep -v grep | awk '{print $2}' | xargs kill -9
   echo "stoping service ends"
fi

#git pull 
echo "start docsify service...."
docsify serve --port 5000 docs


