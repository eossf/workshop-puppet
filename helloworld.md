# HelloWorld Puppet

## Install a puppet module directly on Agent
### module motd install
````
# as vagrant user
puppet module install puppetlabs-motd --version 6.1.0
ls /home/vagrant/.puppetlabs/etc/code/modules

# as root
puppet module install puppetlabs-motd --version 6.1.0
ls /etc/puppetlabs/code/environments/production/modules

````

### test module motd
as root
````
puppet apply --noop -e "include motd"

````

### generate a module motdsetup and apply motd
The default path for module is here: /etc/puppetlabs/code/environments/production/modules/
After creating with pdk the module, go in /manifest folder create an init.pp
````
pdk new module test-motdsetup --skip-interview

class motdsetup {
  class { 'motd':
    content => "Hello motdsetup World ! \n",
  }
}
````

In /examples folder create an init.pp, with this content
````
include ::motdsetup
````

#### direct execution (on agent01)
````
puppet apply -e "include ::motdsetup"
# the init.pp in examples folder
puppet apply init.pp
````

## Dict installed on agent
Still in /etc/puppetlabs/code/environments/production/modules
pdk new module test-dict --skip-interview

in manifest/init.pp
````
class dict {
  package { ['dict', 'dictd', 'dict-vera']:
    ensure => installed
  }
  file { '/etc/dictd/dict.conf':
    source => 'puppet:///modules/dict/dict.conf'
  }
  service { 'dictd':
    ensure => running
  }
}
````

in examples/init.pp
````
include ::dict
````

add the files dict.conf with 
````
server localhost
````

## Dict managed by master
On the master.
redo the tasks before done for agent01.

### node definition
Add in the node definition, for motdsetup and dict:
````
cd /etc/puppetlabs/code/environments/production/manifests
nano site.pp

node 'agent01.local.vm' {
  include motdsetup
  include dict
}
node default {
}
````

Switch to the agent
````
puppet apply -t 
````