# Install Puppet with Vagrant
## Image Bento 21.04
dans /install
vagrant up

## Description
Puppet est un system client / server de gestion de configuration.

un daemon puppetserver est actif sur le master
un daemon puppet (agent) est actif sur l'agent01

### workflow par defaut
Par defaut l'agent toutes les 30' pousse ses facts au master, qui build un catalog, pousse ce catalog (qui peut declencher des installations/modifications sur l'hote de l'agent)
Enfin l'agent reporte au master le resultat.


### Ansible

install on master :

````
sudo apt -y update
sudo apt -y install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt -y install ansible
````


### Configure master
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

#### stop fw
````
#sudo systemctl stop firewalld
sudo ufw allow 8140
````

#### NTP
sudo apt-get -y install ntp ntpdate
sudo ntpdate 0.ubuntu.pool.ntp.org
sudo systemctl restart ntp
sudo systemctl enable ntp

#### conf
add this to  /etc/puppetlabs/puppet/puppet.conf
[main]
certname = master.local.vm
server = master.local.vm


### Configure one agent
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

#### stop fw
````
#sudo systemctl stop firewalld
sudo ufw allow 8140
````

#### NTP
sudo apt-get -y install ntp ntpdate
sudo ntpdate 0.ubuntu.pool.ntp.org
sudo systemctl restart ntp
sudo systemctl enable ntp

#### conf
add this to  /etc/puppetlabs/puppet/puppet.conf
[main]
certname = agent01.local.vm
server = master.local.vm

## Connection Agent => Master - CA 
On the master
````
# certificate
# https://puppet.com/docs/puppet/7/ssl_regenerate_certificates.html

sudo puppetserver ca list
sudo puppetserver ca sign --all
````

On the agent
````
puppet agent --test
````

verify
````
# sudo puppetserver ca list --all
Signed Certificates:
master.local.vm        (SHA256)  E7:F8:D5:C4:27:EF:44:51:54:4F:CD:E6:48:BA:68:47:C0:9C:75:3E:7E:3D:A0:43:39:8E:94:C5:5B:70:CB:D5 alt names: ["DNS:puppet", "DNS:master.local.vm"]        authorization extensions: [pp_cli_auth: true]
agent01.local.vm       (SHA256)  B2:04:42:B5:F5:F5:46:0F:27:8E:63:72:D5:B5:87:71:35:4B:9F:0F:9D:FE:B6:5B:DC:DE:4E:A8:8F:D6:92:17 alt names: ["DNS:agent01.local.vm"]
````

## PDK
````
wget https://apt.puppet.com/puppet-tools-release-focal.deb
sudo dpkg -i puppet-tools-release-focal.deb
sudo apt-get -y update
sudo apt-get -y install pdk
````


## Hello World
On the agent, as root

````
puppet module install puppetlabs-motd --version 6.1.0
cd /etc/puppetlabs/code/environments/production
touch site.pp

````
