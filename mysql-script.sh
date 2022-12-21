#!/bin/sh

MYSQL_BASE=/opt/mysql3307

export PATH=$MYSQL_BASE/bin:/usr/sbin:/usr/bin:/sbin:/bin

export LD_LIBRARY_PATH=$MYSQL_BASE/lib

if [ "$1" = "stop" ] ; then

$MYSQL_BASE/bin/mysqladmin --defaults-file=/opt/mysql3307/etc/my.cnf -uroot -p shutdown

elif [ "$1" = "restart" ]; then

$MYSQL_BASE/bin/mysqladmin --defaults-file=/opt/mysql3307/etc/my.cnf -uroot -p shutdown

$MYSQL_BASE/bin/mysqld_safe --defaults-file=/opt/mysql3307/etc/my.cnf &

elif [ "$1" = "start" ]; then

$MYSQL_BASE/bin/mysqld_safe --defaults-file=/opt/mysql3307/etc/my.cnf &

else

echo "usage: $0 start|stop|restart"

fi
