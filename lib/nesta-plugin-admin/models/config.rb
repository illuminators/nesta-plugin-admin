# encoding: utf-8

module Nesta
  module Plugin
    module Admin
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
      end
    end
  end
end

