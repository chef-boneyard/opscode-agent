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

require 'json'
require 'ohai'
require 'opscode/agent/config'

module Opscode
  class OhaiActor
    include Nanite::Actor
    
    expose :index

    @@ohai = nil
    
    def initialize
      @@ohai = Ohai::System.new
      @@ohai.all_plugins
  
      schedule = Opscode::Agent::Config[:schedule]
      schedule.keys.each do |path|
        EM.add_periodic_timer(schedule[path]) {@@ohai.refresh_plugins(path)}
      end
    end

    def index(payload)
      paths = JSON.parse(payload)
      res = Hash.new
      paths.each do |path|
        parts = path.split("/")
        unless parts[0].nil?
          parts.shift if parts[0].length == 0
        end
        res[path] = ohai_walk(parts, false)
      end
      res
    end

    def ohai_walk(path, refresh)
      @@ohai.refresh_plugins("/#{path.join('/')}") if refresh
      unless path[0]
        @@ohai.to_json
      else
        ohai_walk_r(@@ohai, path)
      end
    end

    def ohai_walk_r(ohai, path)
      hop = (ohai.is_a?(Array) ? path.shift.to_i : path.shift)
      if ohai[hop]
        if path[0]
          ohai_walk_r(ohai[hop], path)
        else
          ohai[hop].to_json
        end
      else
        nil
      end
    end
  end
end
