require 'json'
require 'chef'
require 'chef/client'
require 'chef/runner'
require 'chef/resource_collection'
require 'stringio'
require 'opscode/agent/config'

module Opscode
  class ChefActor
    include Nanite::Actor
    
    expose :collection, :resource, :recipe, :converge

    def log_to_string(&block)
      output = StringIO.new
      Chef::Log.init(output)
      block.call
      output.string
    end

    def collection(payload)
      log_to_string do
        node = Chef::Client.new.build_node
        resource_collection = JSON.parse(payload)
        runner = Chef::Runner.new(node, resource_collection)
        runner.converge
      end
    end

    def resource(payload)
      log_to_string do
        collection = Chef::ResourceCollection.new()
        collection << JSON.parse(payload)
        node = Chef::Client.new.build_node
        runner = Chef::Runner.new(node, collection)
        runner.converge
      end
    end

    def recipe(payload)
      log_to_string do
        collection = Chef::ResourceCollection.new()
        collection << JSON.parse(payload)
        client = Chef::Client.new
        client.build_node
        client.register
        client.authenticate
        client.sync_library_files
        client.sync_attribute_files
        client.sync_definitions
        client.sync_recipes
        client.converge
      end
    end

    def converge(payload)
      log_to_string do
        client = Chef::Client.new
        client.run
      end
    end
  end
end