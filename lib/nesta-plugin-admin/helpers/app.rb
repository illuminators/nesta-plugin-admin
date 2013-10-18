# encoding: utf-8

module Nesta::Plugin::Admin
  module Helpers
    module App
      def partial path
        slim :"#{path}", layout: false
      end

      def item(text, href, li_options={}, link_options={})
        li = "<li class='#{'current' if __item_current?}'" 
        li << "#{__join_attrs(li_options)}>"
        # end of <li ...>

        li << "<a href='#{href}'#{__join_attrs(link_options)}>"
        li << "#{text}</a></li>"
      end

      def navigation(options={}, &code)
        result = "<ul#{__join_attrs(options)}>"
        result << code.call
        result << "</ul>"
      end

      def render_dir_tree(dir, hidden=false)
        result = slim(:'sidebar/_directory', layout: false, locals: {dir: dir, hidden: hidden})
        dir.directories.each { |dir| \
          result << render_dir_tree(dir, true) }

        result
      end

      def dirs_count(dir)
        count = 1
        dir.directories.each { |d| count += 1 }

        count
      end

      private

      def __item_current?(href)
        (href != "/" && request.path.start_with?(href)) || request.path == href
      end

      def __join_attrs(opts)
        opts.map {|k,v| " #{k}='#{v}'" }.join
      end
    end
  end
end

Nesta::Plugin::Admin::App.helpers Nesta::Overrides::Renderers
Nesta::Plugin::Admin::App.helpers Nesta::Navigation::Renderers
Nesta::Plugin::Admin::App.helpers Nesta::View::Helpers
Nesta::Plugin::Admin::App.helpers Nesta::Plugin::Admin::Helpers::App
