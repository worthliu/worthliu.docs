#!/bin/sh
#
#Author: liuzcmf
#Date:2018/11/25
#Description: 版本控制发布

export PATH=$PATH:$HOME/bin
export BASH_ENV=$HOME/.bashrc
export NODE_HOME=/usr/node-v10.13.0
PATH=$NODE_HOME/bin:$PATH

export USERNAME=worthliu
export PATH

#从ruby上下文中获取分支版本信息
pversion=`git branch --no-color 2>/dev/null | awk '{print $2}'`

branchInfo=${pversion}
echo -e "\033[49;31;1;5m current branch is ${pversion}...\033[0m"

#########################################################################
##########     update code     ##########################################
#########################################################################

## initialize current base path
cd ..
gitdir=`pwd`
echo -e "\033[49;31;1;5m current base path is ${gitdir}...\033[0m"
###########################################
cd  ${gitdir}
if [ ! -d ${gitdir}/worthliu.docs ]; then
   git clone --branch=${branchInfo} --depth=1 git@github.com:worthliu/worthliu.docs.git
   cd ${gitdir}/worthliu.docs;
else
   cd ${gitdir}/worthliu.docs;
   git clean -fdx && git reset --hard
fi

git checkout -b ${branchInfo}
#git pull origin mirror:mirror
git pull origin  ${branchInfo}

echo -e "\033[49;31;1;5m The code pulled successfully ...\033[0m"

########################################################################
echo -e "\033[49;31;1;5m restart service beginning ...\033[0m"
nohup bash ./start.sh &
#
git reset --hard && git clean -fdx

#
cd ..