include_recipe 'mongo-server'

service "mongod" do
  action [:disable, :stop]
end

mongodb_instance "config-server"
