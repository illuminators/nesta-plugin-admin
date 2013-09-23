# encoding: utf-8

module Nesta
  module Plugin
    module Admin
      class App < Sinatra::Base
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
      end
    end
  end
end
