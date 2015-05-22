#!/bin/bash

function create_db()
{
#"/var/lib/mysql/.mysql-configured"

if [ ! -f "/tmp/zbx-db-flag" ]; then

        #mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
        #mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';"
        if ! mysql -h mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e 'use zabbix'; then
    	    mysql -h mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "CREATE DATABASE zabbix"

    	    echo "=> Executing Zabbix MySQL script files ..."
    	    local ZABBIX_MYSQL_V="/usr/share/zabbix-mysql"
    	    mysql -h mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD zabbix < "${ZABBIX_MYSQL_V}/schema.sql"
    	    mysql -h mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD zabbix < "${ZABBIX_MYSQL_V}/images.sql"
    	    mysql -h mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD zabbix < "${ZABBIX_MYSQL_V}/data.sql"
    	    echo "=> Done"
    	    mysql -h mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "CREATE USER 'zabbix'@'%' IDENTIFIED BY 'zabbix'"
    	    mysql -h mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix'"
    	    mysql -h mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%'"
    	    mysql -h mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost'"
	fi
        #mysqladmin -uroot shutdown
    else
        echo "DB already initialized..."
    fi
touch /tmp/zbx-db-flag
}

create_db

echo "=> Executing Monit..."
exec monit -d 10 -Ic /etc/monitrc
