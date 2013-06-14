include_recipe 'mongo-server'

service "mongod" do
  action [:disable, :stop]
end

mongodb_instance "shard" do
  mongodb_type "shard"
  replica_set_name node[:mongodb][:replica_set_name]
end
