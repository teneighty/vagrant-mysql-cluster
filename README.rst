What it is
----------

this vagrant setup enables you to try very easy a mysql cluster v7.2.12 setup with 3 machines. The machines are automatically build with vagrant and puppet. The machines will utilize ubuntu 10.04

There are 2 data nodes and 1 management node. See also some reference information form oracle_

.. _oracle: http://downloads.mysql.com/tutorials/cluster/mysql_wp_cluster_quickstart_linux.pdf

How to start
------------

prerequisites vagrant version 1.1.5 ( < 1.2 )

checkout this into a project

::

    git clone git@github.com:sassman/vagrant-mysql-cluster.git


lets build the machines and grab the mysql cluster direct from oracle

::
    
    cd vagrant-mysql-cluster
    ./startup.sh

this may take some time.


form the mangement node you can see if everything is connected correctly

::

    cd mgmt && vagrant ssh

    ndb_mgm -e show
    Connected to Management Server at: localhost:1186
    Cluster Configuration
    ---------------------
    [ndbd(NDB)]     2 node(s)
    id=2    @192.168.33.20  (mysql-5.5.30 ndb-7.2.12, Nodegroup: 0, Master)
    id=3    @192.168.33.30  (mysql-5.5.30 ndb-7.2.12, Nodegroup: 0)

    [ndb_mgmd(MGM)] 1 node(s)
    id=1    @192.168.33.10  (mysql-5.5.30 ndb-7.2.12)

    [mysqld(API)]   2 node(s)
    id=4    @192.168.33.20  (mysql-5.5.30 ndb-7.2.12)
    id=5    @192.168.33.30  (mysql-5.5.30 ndb-7.2.12)


or you want to connect to one the two api nodes

::

    cd node1 && vagrant ssh
    mysql -u root


if you are done you may want to shutdown the machines

::
    
    ./shutdown.sh