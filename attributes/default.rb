default[:mongodb][:cluster_name]     = nil
default[:mongodb][:replica_set_name] = nil
default[:mongodb][:shard_name]       = nil

default[:mongodb][:user]  = "mongod"
default[:mongodb][:group] = "mongod"

default[:mongodb][:config_file] = "/etc/mongod.conf"

default[:mongodb][:dbpath]  = "/var/lib/mongodb"
default[:mongodb][:logpath] = "/var/log/mongodb"
default[:mongodb][:bind_ip] = nil

default[:mongodb][:port]               = 27017
default[:mongodb][:mongos_port]        = 27017
default[:mongodb][:config_server_port] = 27019

default[:mongodb][:maxConns]  = nil
default[:mongodb][:objcheck]  = false
default[:mongodb][:logappend] = true
default[:mongodb][:fork]      = true

default[:mongodb][:configsvr] = false
default[:mongodb][:shardsvr]  = false

default[:mongodb][:noMoveParanoia] = false
