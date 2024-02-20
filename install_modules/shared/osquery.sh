#!/bin/bash


PROJECT_ROOT_DIR=$1
OS_TYPE=$2
PACKAGE_MGR=$3


if [[ $PACKAGE_MGR == 'deb' ]]; 
then
	wget --directory-prefix=/tmp https://pkg.osquery.io/deb/osquery_5.8.2-1.linux_amd64.deb
	DEBIAN_FRONTEND=noninteractive apt install -y /tmp/osquery_5.8.2-1.linux_amd64.deb

elif [[  $PACKAGE_MGR == 'rpm' ]]; then
	wget --directory-prefix=/tmp https://pkg.osquery.io/rpm/osquery-5.8.2-1.linux.x86_64.rpm
	rpm -i /tmp/osquery-5.8.2-1.linux.x86_64.rpm
	
else
	echo "No pkg manager specified. Exit"
fi

# mkdir /etc/osquery/packs/
# mkdir /etc/osquery/packs/core/
# mkdir /etc/osquery/packs/premium/
# mkdir /etc/osquery/packs/custom/

cp -r $PROJECT_ROOT_DIR/build/shared/osquery/* /etc/osquery

chmod 755 /var/log/osquery
systemctl start osqueryd
systemctl enable osqueryd


## Discarded 
# touch /var/osquery/syslog_pipe
#cp -r $PROJECT_ROOT_DIR/build/shared/osquery/packs/core/mitre/* /etc/osquery/packs/core
#cp $PROJECT_ROOT_DIR/build/shared/osquery/osquery.conf /etc/osquery/
#cp -r $PROJECT_ROOT_DIR/build/shared/osquery/packs_unified/* /usr/share/osquery/packs
#sed -i '/LINUX_BINARY_PATH =/c\LINUX_BINARY_PATH = "/opt/osquery/bin/osqueryd"' ./managerd/venv/lib/python3.9/site-packages/osquery/management.py

## Install via repository 

# if [[ $OS_TYPE == 'ubuntu' || $OS_TYPE == 'debian' || $OS_TYPE = "linuxmint" ]]; 
# then
# 	export OSQUERY_KEY=1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B
# 	DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys $OSQUERY_KEY
# 	DEBIAN_FRONTEND=noninteractive add-apt-repository -y 'deb [arch=amd64] https://pkg.osquery.io/deb deb main'
# 	DEBIAN_FRONTEND=noninteractive apt-get update -y
# 	DEBIAN_FRONTEND=noninteractive apt-get install -y osquery 

# elif [[  $OS_TYPE == 'centos' ]]; then
# 	curl -L https://pkg.osquery.io/rpm/GPG | sudo tee /etc/pki/rpm-gpg/RPM-GPG-KEY-osquery
# 	yum-config-manager --add-repo -y https://pkg.osquery.io/rpm/osquery-s3-rpm.repo
# 	yum-config-manager --enable osquery-s3-rpm
# 	yum install -y osquery

# elif [[  $OS_TYPE == 'fedora' ]]; then
# 	dnf install -y https://pkg.osquery.io/rpm/osquery-5.5.1-1.linux.x86_64.rpm
	
# else
# 	echo "OS detection problem"  
# fi