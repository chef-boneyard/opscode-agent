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

require 'opscode/mixin/config'

module Opscode
  module Agent
    class Config
      @configuration = {
        :name => 'opscode-agent',
        :http_port => 8000,
        :daemonize => false,
        :nanite_host => 'localhost',
        :nanite_user => 'nanite',
        :nanite_pass => 'testing',
        :nanite_vhost => '/nanite',
        :nanite_token => nil,
        :schedule => {
          "/counters" => 10,
          "/" => 86400,
          "/network" => 300
        }
      }
      
      include Opscode::Mixin::Config
    end
  end
end