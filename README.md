# Install Puppet with Vagrant
## Image Bento 21.04
dans /install
vagrant up

## Description
Puppet est un system client / server de gestion de configuration.

un daemon puppetserver est actif sur le master
un daemon puppet (agent) est actif sur l'agent01

## workflow par defaut
Par defaut l'agent toutes les 30' pousse ses facts au master, qui build un catalog, pousse ce catalog (qui peut declencher des installations/modifications sur l'hote de l'agent)
Enfin l'agent reporte au master le resultat.

## Ansible
Install

````
sudo apt -y update
sudo apt -y install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt -y install ansible
ansible-galaxy role  init geerlingguy.ntp
ansible-galaxy install galexrt.ansible-ntpdate
````

Note : for ping agent and limit hosts
````
ansible -i hosts -m ping agents
ansible-playbook -i hosts --limit agents 
````

### Connection Agent => Master - CA 
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

## Development / PDK
````
wget https://apt.puppet.com/puppet-tools-release-focal.deb
sudo dpkg -i puppet-tools-release-focal.deb
sudo apt-get -y update
sudo apt-get -y install pdk
````
