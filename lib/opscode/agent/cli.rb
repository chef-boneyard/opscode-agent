#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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
 
require 'rubygems'
require 'nanite'
require 'optparse'

module Opscode
  module Agent
    class CLI
        
      attr_accessor :config

      def initialize(argv=ARGV)
        load_args(argv)
      end
    
      def default_opts(opts, argv) 
        opts.banner = "Usage: #{$0} (options)"
        opts.on("-c CONFIG", "--config CONFIG", "The agent config file to use") do |c|
          @config[:config_file] = c
        end
        opts.on("-l LEVEL", "--loglevel LEVEL", "Set the log level (debug, info, warn, error, fatal)") do |l|
          @config[:log_level] = l
        end
        opts.on("-L LOGLOCATION", "--logfile LOGLOCATION", "Set the log file location, defaults to STDOUT - recommended for daemonizing") do |lf|
          @config[:log_location] = lf
        end
        opts.on("--nanite-identity ID", "The nanite identity") do |n|
          @config[:identity] = n
        end
        opts.on("--nanite-host HOST", "The nanite exchange host") do |n|
          @config[:host] = n
        end
        opts.on("--nanite-user USER", "The nanite user name") do |n|
          @config[:user] = n
        end
        opts.on("--nanite-pass PASS", "The nanite password") do |p|
          @config[:pass] = p
        end
        opts.on("--nanite-vhost VHOST", "The nanite vhost") do |v|
          @config[:vhost] = v
        end
        opts.on("-d", "--daemonize", "Run the agent daemonized") do
          @config[:daemonize] = true
        end
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit 0
        end
        opts.parse!(argv)
      end
    
      def load_args(argv)
        @config = {
          :root => File.expand_path(File.join(File.dirname(__FILE__), '..')),
          :host => Opscode::Agent::Config[:nanite_host],
          :user => Opscode::Agent::Config[:nanite_user],
          :pass => Opscode::Agent::Config[:nanite_pass],
          :vhost => Opscode::Agent::Config[:nanite_vhost],
          :daemonize => Opscode::Agent::Config[:daemonize],
          :identity => Opscode::Agent::Config[:identity],
          :name => Opscode::Agent::Config[:name]
        }
        $0 = "#{@config[:name]} #{argv.join(' ')}\0"
        opts = OptionParser.new do |opts|          
          default_opts(opts, argv)
        end
      end
    
      def run
        EM.run do
          agent = Nanite::Agent.start(@config)
          agent.register(Opscode::OhaiActor.new, 'state')
          agent.register(Opscode::ChefActor.new, 'control')
          agent.send :advertise_services
        end
      end
    end
  end
end
