# Manual (bash) install

## Configure master
````
ssh -p 2222 vagrant@localhost

# notice : password=vagrant
wget http://apt.puppetlabs.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt-get -y update
sudo apt-get -y install puppetserver

# sudo nano /etc/hostname
sudo bash -c 'echo "master.local.vm" > /etc/hostname'
sudo hostnamectl set-hostname master.local.vm

# sudo nano /etc/hosts
sudo cp /etc/hosts /etc/hosts.old
sudo bash -c "sed -i 's/127.0.0.1 localhost/127.0.0.1 master.local.vm puppet localhost/g' /etc/hosts"
sudo bash -c "echo '192.168.100.10 master.local.vm' >> /etc/hosts"
sudo bash -c "echo '192.168.100.11 agent01.local.vm' >> /etc/hosts"

# service 
sudo systemctl restart puppetserver
sudo systemctl enable puppetserver

# PATH nano .bashrc + sudo su
export PATH=$PATH:/opt/puppetlabs/puppet/bin
source .bashrc

# puppet server on , agent off
sudo puppet resource service puppetserver ensure=running enable=true
sudo puppet resource service puppet ensure=stopped enable=false

````

### stop fw
````
#sudo systemctl stop firewalld
sudo ufw allow 8140
````

### NTP
sudo apt-get -y install ntp ntpdate
sudo ntpdate 0.ubuntu.pool.ntp.org
sudo systemctl restart ntp
sudo systemctl enable ntp

### conf
add this to  /etc/puppetlabs/puppet/puppet.conf
[main]
certname = master.local.vm
server = master.local.vm


## Configure one agent
ssh -p 2200 vagrant@localhost

````
# notice : password=vagrant
wget http://apt.puppetlabs.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt-get -y update
sudo apt-get -y install puppetserver

# sudo nano /etc/hostname
sudo bash -c 'echo "agent01.local.vm" > /etc/hostname'
sudo hostnamectl set-hostname agent01.local.vm

# replace /etc/hosts
sudo cp /etc/hosts /etc/hosts.old
sudo bash -c "sed -i 's/127.0.0.1 localhost/127.0.0.1 agent01.local.vm localhost/g' /etc/hosts"
sudo bash -c "echo '192.168.100.10 master.local.vm puppet' >> /etc/hosts"
sudo bash -c "echo '192.168.100.11 agent01.local.vm' >> /etc/hosts"

# service 
sudo systemctl restart puppetserver 
sudo systemctl enable puppetserver 

# PATH nano .bashrc + sudo su
export PATH=$PATH:/opt/puppetlabs/puppet/bin
source .bashrc

# puppet server off, agent on
sudo puppet resource service puppetserver ensure=stopped enable=false
sudo puppet resource service puppet ensure=running enable=true

````

### stop fw
````
#sudo systemctl stop firewalld
sudo ufw allow 8140
````

### NTP
sudo apt-get -y install ntp ntpdate
sudo ntpdate 0.ubuntu.pool.ntp.org
sudo systemctl restart ntp
sudo systemctl enable ntp

### conf
add this to  /etc/puppetlabs/puppet/puppet.conf
[main]
certname = agent01.local.vm
server = master.local.vm