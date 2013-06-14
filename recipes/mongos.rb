include_recipe 'mongo-server'

unless node[:recipes].include? 'mongo-server::config-server' or node[:roles].include? 'mongo-server'
  service "mongod" do
    action [:disable, :stop]
  end
end

configservers = search( :node, "mongodb_cluster_name:#{node['mongodb']['cluster_name']} AND recipes:mongo-server\\:\\:config-server" )
raise "Wrong number of config-server nodes" if configservers.length != 1 and configservers.length != 3

mongodb_instance "mongos" do
  config_servers configservers
end
