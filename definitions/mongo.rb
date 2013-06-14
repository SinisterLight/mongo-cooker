define :mongodb_instance, :mongodb_type => nil, :config_servers => [], :replica_set_name => nil do

  name = params[:name]
  type = params[:mongodb_type].nil? ? name : params[:mongodb_type]

  dbpath = node[:mongodb][:dbpath]
  port   = node[:mongodb][:port]

  config_file = "/etc/mongod.conf"

  logpath   = node[:mongodb][:logpath]
  logfile   = "#{logpath}/#{type}.log"
  logappend = node[:mongodb][:logappend]

  fork_mongo = node[:mongodb][:fork]
  configsvr  = false
  shardsvr   = false

  config_servers = params[:config_servers]

  replica_set_name = nil

  daemon = 'mongod'

  raise "Unknown MongoDB type: #{type}" if !["mongod","config-server","mongos","shard"].include?(type)

  gem_package 'mongo' if type == "mongos" or type == "shard" or name == "replica-set"

  if type == "config-server"
    port = node[:mongodb][:config_server_port]
    configsvr = true
  end

  if type == "mongos"
    port = node[:mongodb][:mongos_port]
    daemon = 'mongos'
    config_file = "/etc/mongos.conf"
    config_server_nodes = config_servers.collect{|n| "#{n['ipaddress']}:#{n['mongodb']['config_server_port']}" }.join(",")
  end

  if name == "replica-set"
    replica_set_name = params[:replica_set_name]
    raise "replica_set_name required" if replica_set_name.nil?
  end

  if type == "shard"
    shardsvr = true
  end

  template config_file do
    source   "#{daemon}.conf.erb"
    owner    "root"
    group    "root"
    mode     "0644"
    variables(
      :dbpath    => dbpath,
      :port      => port,
      :logpath   => logfile,
      :logappend => logappend,
      :fork      => fork_mongo,
      :configdb  => config_server_nodes,
      :configsvr => configsvr,
      :shardsvr  => shardsvr,
      :replSet   => replica_set_name
    )
    notifies :restart, "service[#{daemon}]", :delayed
  end

  unless type == 'mongos'
    directory dbpath do
      owner node[:mongodb][:user]
      group node[:mongodb][:group]
      mode "0755"
      action :create
      recursive true
    end
  end

  directory logpath do
    owner node[:mongodb][:user]
    group node[:mongodb][:group]
    mode "0755"
    action :create
    recursive true
  end

  if type == 'mongos'
    template "/etc/init.d/mongos" do
      action   :create
      source   "mongos.sh.erb"
      owner    'root'
      group    'root'
      mode     "0755"
      notifies :restart, "service[mongos]"
    end
  end

  service daemon do
    supports :start => true, :stop => true, :restart => true, :status => true, :reload => true
    action [:enable, :start] 
  end

  if name == 'replica-set'
    query = "role:replica-set AND replica_set_name:#{replica_set_name}"
    replica_set_nodes = search :node, query
    ruby_block "configure replica set" do
      block do
        MongoDB.configure_replica_set node, replica_set_name, replica_set_nodes
      end
      notifies :restart, "service[mongod]", :delayed
    end
  end

  if type == 'mongos'
    shard_nodes = search :node, "mongodb_cluster_name:#{node['mongodb']['cluster_name']} AND recipes:mongo-server\\:\\:shard"
 
    ruby_block "configure shard nodes" do
      block do
        MongoDB.configure_shards node, replica_set_name, shard_nodes
      end
      notifies :restart, "service[mongos]", :delayed
    end
  end
end
