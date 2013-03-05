require 'rails/generators'

module Proselytism
  class ConfigGenerator < Rails::Generators::Base

    self.source_paths << File.join(File.dirname(__FILE__), 'templates')

    desc "Generate Proselytism config file load before rails initialize"
    def create_config_file
      template 'config.yml', 'config/proselytism.yml'
    end

  end
end
