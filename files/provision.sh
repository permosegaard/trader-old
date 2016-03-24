#!/bin/bash
# disk optimisations here
echo "*/5 * * * * root /sbin/swapoff -a" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root /bin/mount -o remount,noatime,nodiratime,nobh,nouser_xattr,barrier=0,commit=600 /" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root echo noop > /sys/block/vda/queue/scheduler" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root echo 99 > /proc/sys/vm/dirty_ratio" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root echo 80 > /proc/sys/vm/dirty_background_ratio" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root echo 360000 > /proc/sys/vm/dirty_expire_centisecs" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root echo 360000 > /proc/sys/vm/dirty_writeback_centisecs" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root echo 99 > /proc/sys/vm/swappiness" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations

# DDNS setup here
sudo hostnamectl set-hostname trader
echo "trader" | sudo tee /etc/hostname
echo "127.0.1.1 trader" | sudo tee -a /etc/hosts

# Timezone setup here
echo "Europe/London" | sudo tee /etc/timezone
sudo dpkg-reconfigure tzdata

# ntp setup here
sudo ntpdate pool.ntp.org
sudo apt-get install -y ntp
sudo service ntp start

# general vm setup here
sudo apt-get update
sudo apt-get upgrade -y # this can take a while but as we're invoking gcc it's hardly a problem :P

# let's setup some debconf answers here
echo wireshark-common wireshark-common/install-setuid boolean false | sudo debconf-set-selections

# install various standard tools here
sudo apt-get install -y unzip dos2unix glances iftop tshark links ncdu atop tmux

# atop setup here
# TODO: probably needs logrotate <- possibly others
sudo sed -i 's/INTERVAL=600/INTERVAL=10/' /etc/default/atop
sudo service atop restart

# general customisation here
sudo cp /vagrant/files/config/tmux.conf /etc/tmux.conf
sudo cp /vagrant/files/profile.d/custom_aliases.sh /etc/profile.d/custom_aliases.sh
sudo cp /vagrant/files/scripts/tmux.sh /usr/local/bin/tmux.sh
sudo chmod +x /usr/local/bin/tmux.sh

# postgres setup here
sudo apt-get install -y postgresql-9.4 postgresql-server-dev-9.4 libpq5 libpq-dev
( echo "CREATE USER trader ENCRYPTED PASSWORD 'HCeJAUjeFxvcmzF3T0M0p93hzSJMp';";\
  echo "CREATE DATABASE trader OWNER trader;" ) | sudo -u postgres psql
sudo -u postgres psql trader < /vagrant/files/db/schema.sql
sudo sed -i 's%host    all             all             127.0.0.1/32            md5%host    all             all             127.0.0.1/32            trust%' /etc/postgresql/9.4/main/pg_hba.conf
sudo service postgresql restart # debug here

# elasticsearch setup here
#sudo sh -c 'wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -'
#sudo sh -c 'echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" > /etc/apt/sources.list.d/elasticsearch-2.x.list'
#sudo apt-get update
#sudo apt-get install -y openjdk-8-jre-headless elasticsearch
#sudo apt-get install --reinstall ca-certificates-java # fix for ridiculous circular dependency bug in command above
#sudo service elasticsearch start
#curl -s -X PUT 'http://127.0.0.1:9200/symbol_snapshots/'
#curl -s -X PUT 'http://127.0.0.1:9200/symbol_ticks/'

# deprecated
## kibana setup here
#sudo wget -qO /opt/kibana-4.2.0-linux-x64.tar.gz https://download.elastic.co/kibana/kibana/kibana-4.2.0-linux-x64.tar.gz
#sudo tar -C /opt/ -xzf /opt/kibana-4.2.0-linux-x64.tar.gz
#useradd kibana
#sudo cp /vagrant/files/config/kibana.yml /opt/kibana-4.2.0-linux-x64/config/kibana.yml
#sudo cp /vagrant/files/defaults/kibana /etc/default/kibana
#sudo cp /vagrant/files/init.d/kibana /etc/init.d/kibana
#sudo chown -R kibana:root /opt/kibana-4.2.0-linux-x64/
#sudo ln -s /opt/kibana-4.2.0-linux-x64 /opt/kibana
#sudo update-rc.d kibana defaults
#sudo mkdir /var/log/kibana
#sudo chown kibana:root /var/log/kibana
#sudo service kibana start
#sudo service kibana stop

# deprecated
## grafana setup here
#sudo sh -c 'wget -qO - https://packagecloud.io/gpg.key | sudo apt-key add -'
#sudo sh -c 'echo "deb https://packagecloud.io/grafana/stable/debian/ wheezy main" > /etc/apt/sources.list.d/grafana.list'
#sudo apt-get update
#sudo apt-get install -y grafana
#sudo sed -i '/^\[auth.basic]$/,/^\[/ s/^;enabled = true$/enabled = false/' /etc/grafana/grafana.ini
#sudo sed -i '/^\[auth.anonymous]$/,/^\[/ s/^;enabled = false$/enabled = true/' /etc/grafana/grafana.ini
#sudo sed -i '/^\[auth.anonymous]$/,/^\[/ s/^;org_name = Main Org.$/org_name = Main Org./' /etc/grafana/grafana.ini
#sudo sed -i '/^\[auth.anonymous]$/,/^\[/ s/^;org_role = Viewer$/org_role = Admin/' /etc/grafana/grafana.ini
#sudo service grafana-server start
#curl -s -X POST 'http://127.0.0.1:3000/api/datasources' -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"symbol_ticks","type":"elasticsearch","url":"http://127.0.0.1:9200/","access":"proxy","jsonData":{"timeField":"@timestamp"},"database":"symbol_ticks"}'
#curl -s -X POST 'http://127.0.0.1:3000/api/datasources' -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"symbol_snapshots","type":"elasticsearch","url":"http://127.0.0.1:9200/","access":"proxy","jsonData":{"timeField":"@timestamp"},"database":"symbol_snapshots"}'
#sudo service grafana-server stop

# python setup here
sudo apt-get install -y python3-psycopg2 python3-bs4 python3-pandas python3-pycurl
sudo apt-get install -y python3-dev python3-pip
sudo pip3 install apscheduler elasticsearch
sudo pip3 install babel money

# cleanup here
sudo apt-get autoremove -y
sudo apt-get clean
sudo find /var/lib/apt/lists -type f -exec rm -v {} \;

# FIXES: "The SSH command responded with a non-zero exit status"
true
