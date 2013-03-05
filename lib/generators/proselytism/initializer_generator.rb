require 'rails/generators'

module Proselytism
  class InitializerGenerator < Rails::Generators::Base

    self.source_paths << File.join(File.dirname(__FILE__), 'templates')


    desc "Generate an initializer file to override the configuration file"
    def create_initializer_file
      template 'initializer.rb', 'config/initializers/proselytism.rb'
    end
  end
end
