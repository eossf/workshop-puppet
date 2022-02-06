# nodes definition
node 'agent01.local.vm' {
  include motdsetup
  include dict
}
node default {
}
