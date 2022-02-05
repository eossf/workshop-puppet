# Install Puppet with Vagrant
## Image Bento 21.04
Go into the folder /install
On your desktop computer
````
vagrant up
````

## Description
Puppet is a client/server configuration manager.

This installation provides :
    One daemon puppetserver est actif sur le master
    One daemon puppet (agent) est actif sur l'agent01

## Puppet at a glance
By default every 30' the node/agent push its facts to the master, which builds and push the dedicated catalog (modules for the node/agent), 
Then the node/agent triggers tasks related to its own catalog.
Finally, the node/agent returns a report to the master.

## Ansible installation - workshop-puppet
Install ansible + ansible galaxy + roles
It is possible to install ansible on another machine or directly on the master.

Below installation from the master:
Connection to the master with ssh -p 2222 vagrant@localhost
Password: vagrant
````
sudo su -
apt -y install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt -y update
apt -y install ansible
ansible-galaxy install geerlingguy.ntp
ansible-galaxy install galexrt.ansible-ntpdate
````

### Install project
````
git clone https://github.com/eossf/workshop-puppet
cd workshop-puppet
````

### keys for workshop-puppet
These generated keys must be copied to the ansible machine
Return back on your desktop computer
````
cd workshop-puppet/install/.vagrant/machines/

# copy for ansible installed on master
scp -i master.local.vm/virtualbox/private_key -P 2222 agent01.local.vm/virtualbox/private_key vagrant@localhost:~/private_key_agent01
scp -i master.local.vm/virtualbox/private_key -P 2222 agent02.local.vm/virtualbox/private_key vagrant@localhost:~/private_key_agent02
scp -i master.local.vm/virtualbox/private_key -P 2222 master.local.vm/virtualbox/private_key vagrant@localhost:~/private_key_master
ssh -i master.local.vm/virtualbox/private_key -p 2222 vagrant@localhost "sudo chmod 0600 ~/private_key*; sudo mv ~/private_key*  /root/workshop-puppet/install"
````

### Tests
Connect to the ansible machine, for pinging agent and limit hosts
````
sudo su -
cd ~/workshop-puppet/install
export ANSIBLE_HOST_KEY_CHECKING=false
ansible -i hosts -m ping all
````

### Puppet : Install nodes
Install one node/master

````
cd ~/workshop-puppet/install
ansible-playbook -i hosts --limit masters 10-install-puppet-server.yaml
ansible-playbook -i hosts --limit masters 20-config-server-puppet.yaml
ansible-playbook -i hosts --limit masters 30-config-puppet.yaml
ansible-playbook -i hosts --limit masters 40-service-puppet.yaml
ansible-playbook -i hosts --limit masters 50-post-install.yaml
````

Install one node/agent
````
cd ~/workshop-puppet/install
ansible-playbook -i hosts --limit agents 10-install-puppet-server.yaml
ansible-playbook -i hosts --limit agents 20-config-server-puppet.yaml
ansible-playbook -i hosts --limit agents 30-config-puppet.yaml
ansible-playbook -i hosts --limit agents 40-service-puppet.yaml
ansible-playbook -i hosts --limit agents 50-post-install.yaml
````

### Connection Agent => Master - CA 
On the client, request a connection 
````
puppet agent --test
````

On the master validate (sign) the CA requests
````
# certificate
# https://puppet.com/docs/puppet/7/ssl_regenerate_certificates.html

puppetserver ca list
puppetserver ca sign --all
````

Verify the certificates
````
# sudo puppetserver ca list --all
Signed Certificates:
master.local.vm        (SHA256)  E7:F8:D5:C4:27:EF:44:51:54:4F:CD:E6:48:BA:68:47:C0:9C:75:3E:7E:3D:A0:43:39:8E:94:C5:5B:70:CB:D5 alt names: ["DNS:puppet", "DNS:master.local.vm"]        authorization extensions: [pp_cli_auth: true]
agent01.local.vm       (SHA256)  B2:04:42:B5:F5:F5:46:0F:27:8E:63:72:D5:B5:87:71:35:4B:9F:0F:9D:FE:B6:5B:DC:DE:4E:A8:8F:D6:92:17 alt names: ["DNS:agent01.local.vm"]
````

## Development / PDK
````
wget https://apt.puppet.com/puppet-tools-release-focal.deb
sudo dpkg -i puppet-tools-release-focal.deb
sudo apt-get -y update
sudo apt-get -y install pdk
````
