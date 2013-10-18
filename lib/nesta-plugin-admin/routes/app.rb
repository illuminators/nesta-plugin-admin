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

          get '/layout/:layout/:template' do
            set_common_variables
            @page = Nesta::Page.find_by_path(params[:page])
            raise Sinatra::NotFound if @page.nil?
            @title = @page.title
            set_from_page(:description, :keywords)
            cache haml(:"#{params[:template]}", layout: :"#{params[:layout]}", views: Nesta::App.views)
          end

          # --- main routes
          get '*' do
            #begin
              slug = params[:splat][0]
              dir_path = slug.end_with?('/') ? \
                slug : slug.sub(/[\/]?[^\/]*$/, '')

              @page = Nesta::Page.find_by_path(params[:splat][0])

              if request.xhr?
                {
                  heading: @page.heading,
                  meta: {
                    title: @page.metadata('title'),
                    description: @page.metadata('description'),
                    tags: @page.metadata('tags'), },
                  style: {
                    layout: @page.layout,
                    template: @page.template, },
                  draft: @page.draft?,
                  hidden: @page.hidden?,
                  body_markup: @page.body_markup,
                }.to_json
              else
                @directory = Directory.new(dir_path)

                slim :page
              end
            #rescue NameError
            #  raise Sinatra::NotFound
            #end
          end

        end # namespace '/admin'
      end
    end
  end
end
