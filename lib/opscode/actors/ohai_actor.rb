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
      res = Mash.new
      paths.each do |path|
        parts = path.split("/"); parts.shift if parts[0].length == 0
        res[path] = ohai_walk(parts, false)
      end
      res
    end

    def ohai_walk(path, refresh)
      @@ohai.refresh_plugins(path.join('/')) if refresh
      unless path[0]
        @@ohai.json_pretty_print
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
