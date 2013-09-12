# encoding : UTF-8
require 'sinatra/contrib'
require 'coffee-script'
require 'slim'

module Nesta
   
  module Plugin
    module Admin

      class App < Sinatra::Base
        register Sinatra::Namespace

        set :views, File.expand_path("../../views", File.dirname(__FILE__))
        set :slim, layout: :"layouts/application"

        configure do
        end
        
        namespace '/admin' do
          get '' do
            slim :index
          end
        end

      end

      # configuration handling
			class Config

				def self.default_config
					{}
				end

				def self.get_config
					config_path = File.dirname(Nesta::Config.yaml_path) + '/admin.yml'
					if File.exists?(config_path)
						@@config ||= YAML.load(File.read(config_path))
						@@config = default_config.update(@@config)
					else
						@@config = default_config
					end
				end

				def self.[] key
					get_config
					@@config[key.to_s]
				end

				def self.include? value
					get_config
					@@config.include?(value)
				end

			end # Config

		end # module Mailer
  end # module Plugin
	
  class App
    use Plugin::Admin::App
  end

end # module Nesta
