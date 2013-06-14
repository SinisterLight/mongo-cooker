include_recipe 'mongo-server::10gen-repo'
package "mongo-10gen-server"
package "mongo-10gen" 

mongodb_instance "mongod"

cookbook_file "/etc/security/limits.conf"  do
  source  "limits.conf"
  owner   "root"
  group   "root"
  mode    "0644"
  notifies :restart, 'service[mongod]', :delayed
end
