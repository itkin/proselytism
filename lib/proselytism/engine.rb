require 'rails'

module Proselytism
  class Engine < Rails::Engine

    ActiveSupport.on_load :before_initialize do |app|
      config_file_path = File.join(Rails.root, 'config', 'proselytism.yml')
      if File.exist?(config_file_path)
        params = YAML.load_file(config_file_path)
        Proselytism.config do |config|
          params[Rails.env].each do |k, v|
            config.send "#{k}=", v
          end
        end
      end
    end

    ActiveSupport.on_load :after_initialize do |app|
      Proselytism.config.log_level  ||= Rails.logger.level
      Proselytism.config.log_path   ||= File.join(Rails.root, 'log', "proselytism.log")
      Proselytism.config.logger     ||= Proselytism::BufferedLogger.new Proselytism.config.log_path, Proselytism.config.log_level
    end

  end

end