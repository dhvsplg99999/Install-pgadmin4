#!/bin/bash


cd ~

# Set up EPEL Repository
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
echo "set up epel - DONE "
echo "================================================="



# Set Set up PostgreSQL Repository (PostgreSQL 10 )
yum install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm -y 
echo "============================================"

# Install pgAdmin 4 
yum install pgadmin4 -y 
echo "============================================"
# Configure pgAdmin 4

## Copy the pgAdmin 4 sample configuration.
cp /etc/httpd/conf.d/pgadmin4.conf.sample /etc/httpd/conf.d/pgadmin4.conf
echo " configuaration DONE "
echo "============================================"


## Create a pgAdmin log and data directorie
mkdir /var/log/pgadmin4/ 
mkdir /var/lib/pgadmin4/
echo " create DONE "
echo "============================================"



##Create/Edit config_local.py file.
touch /usr/lib/python2.7/site-packages/pgadmin4-web/config_local.py
cat >> /usr/lib/python2.7/site-packages/pgadmin4-web/config_local.py << EOF
LOG_FILE = '/var/log/pgadmin4/pgadmin4.log'
SQLITE_PATH = '/var/lib/pgadmin4/pgadmin4.db'
SESSION_DB_PATH = '/var/lib/pgadmin4/sessions'
STORAGE_DIR = '/var/lib/pgadmin4/storage'
EOF
echo " edit config_local.py DONE "
echo "============================================"
 
## Add rules to firewall
systemctl start firewalld
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

echo " ADD rules compelete !"
echo "============================================"


## Change permissions of directories so that Apache can write data into it 
chown -R apache:apache /var/lib/pgadmin4/
chown -R apache:apache /var/log/pgadmin4/
echo " change permission compelete !"
echo "============================================"

##Run the following command to create a user account for the pgAdmin 4 web interface.
python /usr/lib/python2.7/site-packages/pgadmin4-web/setup.py

# Configure SELinux

chcon -R -t httpd_sys_content_rw_t "/var/log/pgadmin4/"
chcon -R -t httpd_sys_content_rw_t "/var/lib/pgadmin4/"


# Restart httpd service 
systemctl restart httpd

echo "Done"
