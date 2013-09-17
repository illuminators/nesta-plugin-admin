# encoding : UTF-8
require 'sinatra/contrib'
require 'coffee-script'
require 'slim'
require 'sass'
require 'compass'

require_relative 'models'

module Nesta
   
  module Plugin
    module Admin

      class App < Sinatra::Base
        include Nesta::Plugin::Admin::Models
        register Sinatra::Cache
        register Sinatra::Namespace
        set :views, File.expand_path("../../views", File.dirname(__FILE__))
        set :public_folder, File.expand_path("../../public", File.dirname(__FILE__))

        helpers do
          def partial path
            slim :"#{path}", layout: false
          end

          def item(text, href, li_options={}, link_options={})
            li = "<li class='#{'current' if (href != "/" && request.path.start_with?(href)) || request.path == href}'#{li_options.collect { |k, v| " #{k}='#{v}'" }.join("")}>"
            li << "<a href='#{href}'#{link_options.collect { |k, v| " #{k}='#{v}'" }.join("")}>"
            li << "#{text}</a></li>"
          end

          def navigation(options={}, &code)
            result = "<ul#{options.collect {|k, v| " #{k}='#{v}'"}.join('')}>"
            result << code.call
            result << "</ul>"
          end
        end # helpers

        before do
          @title = Nesta::Config.title
          @config = Config.get_config
        end

        namespace '/admin' do

          # --- Assets
          get '/js/:script.js' do
            content_type 'application/javascript', :charset => 'utf-8'
            cache coffee(("scripts/" + params[:script]).to_sym)
          end

          get '/css/:sheet.css' do
            content_type 'text/css', :charset => 'utf-8'
            cache sass(("styles/" + params[:sheet]).to_sym, Compass.sass_engine_options)
          end

          # --- main routes
          get '*' do
            #begin
              slug = params[:splat][0]
              dir_path = slug.end_with?('/') ? \
                slug : slug.sub(/[\/]?[^\/]*$/, '')

              @directory = Directory.new(dir_path)
              @page = Nesta::Page.find_by_path(params[:splat][0])

              slim :page
            #rescue NameError
            #  raise Sinatra::NotFound
            #end
          end

        end # namespace '/admin'

      end # class App

      # configuration handling
			class Config

				def self.default_config
					{
            'layouts' => {
              layout: 'default layout',
              },
            'templates' => {
              page: 'default template',
              },
            'allowed_metadata' => [
              'keywords', 'date', 'summary', 'articles heading',
              'read more',
              ],
          }
				end

				def self.get_config
					config_path = File.dirname(Nesta::Config.yaml_path) + '/admin.yml'
					if File.exists?(config_path)
						@config ||= YAML.load(File.read(config_path))
						@config = default_config.update(@config)
					else
						@config = default_config
					end
				end

        attr_reader :config

			end # class Config

		end # module Admin
  end # module Plugin
	
  class App
    use Plugin::Admin::App
  end

end # module Nesta
