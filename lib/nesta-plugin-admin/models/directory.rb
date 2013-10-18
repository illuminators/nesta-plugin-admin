# encoding: utf-8

module Nesta
  module Plugin
    module Admin
      class Directory

        def initialize(path)
          @path = path.sub(/^\//, '')
          @path += '/' unless @path.match(/\/$/)
          path = File.join(Nesta::App.root, Nesta::Config.page_path, path)
          raise NameError, 'Directory not found' \
            unless File.exists?(path) and File.directory?(path)
          @files = Dir.glob File.join(path, '*')
          get_content
        end

        attr_accessor :directories, :pages, :path, :heading

        def list
          list = @pages.concat(@directories)
          list.sort_by! { |i| i.path.sub(/^\//, '') }
        end

        def back
          @path.empty? ? nil : @path.sub(/[\/]?[^\/]*\/$/, '')
        end

        private

        def get_content
          @pages = []
          @directories = []
          @files.each do |f|
            path = Pathname.new(f).relative_path_from(
              Pathname.new(
                File.join(Nesta::App.root, Nesta::Config.page_path)
              )).to_s

            slug = path.sub(/\..*/, '')
            p slug
            if File.directory?(f)
              @directories << Directory.new(slug)
            else
              page = Nesta::Page.find_by_path(slug)
              @heading = page.heading || @path if slug.end_with? 'index'
              @pages << page
            end
          end
        end

      end # class Directory


    end # module Admin
  end # module Plugin
end # module Nesta

