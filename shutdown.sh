#!/bin/bash

for d in mgmt node1 node2; do
	cd $d
	vagrant halt	
	cd ..
done
