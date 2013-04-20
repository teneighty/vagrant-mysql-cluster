#!/bin/bash

MYSQL_CLUSTER=manifests/mysql-cluster-gpl-7.2.12-linux2.6-x86_64.tar.gz
MYSQL_CLUSTER_URL=http://dev.mysql.com/get/Downloads/MySQL-Cluster-7.2/mysql-cluster-gpl-7.2.12-linux2.6-x86_64.tar.gz/from/http://mysql.he.net/

if [ ! $(which vagrant) ]; then
	echo "vagrant required!"
	exit 1
fi

if [ ! $(vagrant box list | grep "lucid64") ]; then
	vagrant box add lucid64 http://files.vagrantup.com/lucid64.box
fi

if [ ! -e $MYSQL_CLUSTER ]; then
	wget $MYSQL_CLUSTER_URL -O $MYSQL_CLUSTER
fi

for d in mgmt node1 node2; do
	cd $d
	vagrant up	
	cd ..
done
