#
# Author:: Benjamin Black (<bb@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# NOTICE: This code is based in part on nanite-admin from the EY nanite project.

require 'rack'
require 'nanite'
require 'opscode/actors/ohai_actor'
require 'opscode/actors/chef_actor'

module Opscode
  module Agent
    class HttpService

  	  def initialize(agent)
  	    @agent = agent
  		  @ohai = OhaiActor.new
  		  @chef = ChefActor.new
  	  end

      def call(env)      
        req = Rack::Request.new(env)
        status = 200
        content = nil
        content_type = "application/json"
      
        if env["REQUEST_METHOD"].eql?("GET") && (path = env["PATH_INFO"].split("/")).length > 1
          case path[1]
          when "state"
            rparams = Rack::Utils::parse_query(Rack::Utils::unescape(req.query_string))
            refresh = (rparams["refresh"] && rparams["refresh"].downcase.eql?("true"))
            path.shift; path.shift
            content = @ohai.ohai_walk(path, refresh)
          when "control"
            rparams = Rack::Utils::parse_query(Rack::Utils::unescape(req.query_string))
            rparams ||= Hash.new
            path.shift; path.shift
          
            output = nil
                    
            case path[0]
            when "collection"
              output = @chef.collection(rparams)
            when "resource"
              output = @chef.resource(rparams)
            when "recipe"
              output = @chef.recipe(rparams)
            when "converge"
              output = @chef.converge(rparams)
            end
          
            content_type = "text/plain"          
            content = output
          end
          unless content
            status = 404
            content = "Unknown path"
          end
        end

        [status, { 'Content-Type' => content_type }, content.to_s]
      end 
    end
  end
end