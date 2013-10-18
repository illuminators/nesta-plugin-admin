# encoding : UTF-8

require 'bundler/setup'

require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/cache'
require 'coffee-script'
require 'slim'
require 'sass'
require 'compass'
require 'json'

unless defined?(Nesta::Config)
  puts "Only plugin is loaded - without app!"
  require 'nesta/config'
  require 'nesta/models'
end


module Nesta
  module Plugin
    module Admin

      class App < Sinatra::Base
        register Sinatra::Cache
        register Sinatra::Namespace
        set :views, File.expand_path("../../views", File.dirname(__FILE__))
        set :public_folder, File.expand_path("../../public", File.dirname(__FILE__))
        set :cache_enabled, true

        before do
          @title = Nesta::Config.title
          @config = Config.get_config
        end
      end # class App
    end # module Admin
  end # module Plugin
end # module Nesta

require_relative './boot'


# Use this awesome plugin :)
module Nesta
  class App < Sinatra::Base
    use Plugin::Admin::App
  end
end
