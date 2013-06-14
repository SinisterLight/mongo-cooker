class Chef::ResourceDefinitionList::MongoDB
  class << self
    def configure_replica_set node, replica_set_name, replica_set_nodes
      if replica_set_nodes.count < 3
        Chef::Log.error "need altleast 3 members for #{replica_set_name}" 
        return
      end

      require 'rubygems'
      require 'mongo'

      members = []
      replica_set_nodes.each_index {|n| members << {"_id" => n, "host" => "#{replica_set_nodes[n]['ipaddress']}:#{replica_set_nodes[n]['mongodb']['port']}"} }
      replica_set_config = { '_id' => replica_set_name, 'members' => members }

      connection = Mongo::MongoClient.new('localhost', node[:mongodb][:port])

      command = BSON::OrderedHash.new
      command['replSetInitiate'] = replica_set_config
      begin
        connection['admin'].command(command)
      rescue Mongo::OperationFailure
        config = connection['local']['system']['replset'].find_one({"_id" => replica_set_name})
        replica_set_config['version'] = config.nil? ? 1 : config['version']
        unless replica_set_config == config
          command = BSON::OrderedHash.new
          command['replSetGetStatus'] = replica_set_config
          result = connection['admin'].command(command)
          primary_ip = result.nil? ? nil : result['members'].select{|m| m['stateStr']=='PRIMARY'}.first['name'].split(':').first
          if primary_ip == node['ipaddress']
            command = BSON::OrderedHash.new
            replica_set_config['version'] = config['version'] + 1
            command['replSetReconfig'] = replica_set_config
            connection['admin'].command(command)
          end
        end
      end
    end

    def configure_shards node, replica_set_name, shard_nodes
      require 'rubygems'
      require 'mongo'

      shard_members = []
      shard_nodes.each_index {|n| shard_members << "#{shard_nodes[n]['ipaddress']}:#{shard_nodes[n]['mongodb']['port']}" }

      connection = Mongo::MongoClient.new('localhost', node[:mongodb][:port])

      shard_members.each do |shard|
        command = BSON::OrderedHash.new
        command['addShard'] = shard
        connection['admin'].command(command)
      end
    end
  end
end
