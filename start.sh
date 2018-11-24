#!/bin/sh

export PATH=$PATH:$HOME/bin
export NODE_HOME="/usr/node-v10.13.0/bin"
PATH=$NODE_HOME/bin:$PATH

isRun=`ps -ef | grep "docsify" | grep -v grep | wc -l`

if [ $isRun = "1" ]; then
   echo "docsify is runing....."
else
   echo "start docsify service...."
   git pull 
   docsify serve --port 5000 docs &
fi


