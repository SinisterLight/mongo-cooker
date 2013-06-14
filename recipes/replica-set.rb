include_recipe 'mongo-server'

service "mongod" do
  action [:disable, :stop]
end

mongodb_instance "replica-set" do
  mongodb_type "mongod"
  replica_set_name node[:mongodb][:replica_set_name]
end
