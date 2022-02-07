# Install Puppet with Vagrant
Puppet is a client/server configuration manager.
This installation provides :
 - 1 puppetserver on the master (master)
 - 1 node with puppet agent (agent01)
 - 1 node with puppet agent (agent02) + after a zabbix agent
 - 1 zabbix server (zabbix)

## Use Case expected
Once everything is installed and running : 
 - agent02 directly install "zabbix agent 2", remove. Test
 - the puppet master will be configured to install automatically on agent02. Test
 - zabbix server test installation and configuration
 - "zabbix agent 2" modification (add encrypted communication)
 - "zabbix agent 2" installed and contact server. Test and confirmation agent call de zabbix frontend api

By default every 30' the node/agent push its facts to the master, which builds and push the dedicated catalog (modules for the node/agent), then the node/agent triggers tasks related to its own catalog. Finally, the node/agent returns a report to the master.

It is possible to test agent configuration directly by the command:
````
puppet agent -t
````

## Step 1 - Ansible installation
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

### Step 2 - Install workshop-puppet project
````
git clone https://github.com/eossf/workshop-puppet
cd workshop-puppet
````

### Step 3 - Install Puppet
keys for workshop-puppet
These generated keys __ MUST BE __ copied to the ansible machine
Return back on your desktop computer
````
cd workshop-puppet/install/.vagrant/machines/

# copy for ansible installed on master
scp -i master.local.vm/virtualbox/private_key -P 2222 agent01.local.vm/virtualbox/private_key vagrant@localhost:~/private_key_agent01
scp -i master.local.vm/virtualbox/private_key -P 2222 agent02.local.vm/virtualbox/private_key vagrant@localhost:~/private_key_agent02
scp -i master.local.vm/virtualbox/private_key -P 2222 master.local.vm/virtualbox/private_key vagrant@localhost:~/private_key_master
scp -i master.local.vm/virtualbox/private_key -P 2222 zabbix.local.vm/virtualbox/private_key vagrant@localhost:~/private_key_zabbix

ssh -i master.local.vm/virtualbox/private_key -p 2222 vagrant@localhost "sudo chmod 0600 ~/private_key*; sudo mv ~/private_key*  /root/workshop-puppet/install"
````

#### Tests
Connect to the ansible machine, for pinging agent and limit hosts
````
sudo su -
cd ~/workshop-puppet/install
export ANSIBLE_HOST_KEY_CHECKING=false
ansible -i hosts -m ping all
````

#### Puppet : Install nodes
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

#### Connection Agent => Master - CA 
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

Remove certificate agent01 (for example)
````
cd /etc/puppetlabs/puppet/ssl
tree
sudo rm private_keys/agent01.local.vm.pem public_keys/agent01.local.vm.pem crl.pem certs/ca.pem certs/agent01.local.vm certificate_requests/agent01.local.vm.pem

cd ~/.puppetlabs/etc/puppet/ssl
tree
rm private_keys/agent01.local.vm.pem crl.pem certs/ca.pem certs/agent01.local.vm.pem certificate_requests/agent01.local.vm.pem
````

on the server
````
puppetserver ca revoke --certname agent01.local.vm
puppetserver ca clean --certname agent01.local.vm
````

## Install Zabbix
### Step 1 - install zabbix server
````
ansible-playbook -i hosts --limit zabbix_server 70-install-zabbix-server.yaml
````

## Development / PDK
````
ansible-playbook -i hosts --limit master 60-install-pdk.yaml
````
