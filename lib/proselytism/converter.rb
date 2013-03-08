require 'singleton'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/aliasing'

module Proselytism
  module Converters
    class Base
      include ::Singleton
      class_attribute :from, :to, :subclasses

      class Error < Exception; end


      delegate :config, :log, :to => Proselytism


      def destination_file_path(origin, options={})
        if options[:dest]
          options[:dest]
        else
          File.join options[:dir], File.basename(origin).gsub(/\..*$/, options[:folder] ? '' : ".#{options[:to]}")
        end
      end

      #call perform logging duration and potential errors
      def convert(file_path, options={})
        log :debug, "#{self.class.name} converted #{file_path} to :#{options[:to]}" do
          begin
            perform(file_path, options)
          rescue Error => e
            log :error, "#{e.class.name} #{e.message}\n#{e.backtrace}\n"
            raise e
          end
        end
      end

      #execute a command and raise error with the command output if it fails
      def execute(command)
        output = `#{command}`
        if $?.exitstatus != 0
          raise self.class::Error, ["#{self.class.name} unable to exec command: #{command}",'--', output,'--'].join("\n")
        end
        $?.exitstatus == 0
      end

      singleton_class.class_eval do

        def inherited_with_registering(subclass)
          self.subclasses ||= []
          self.subclasses << subclass
          inherited_without_registering(subclass)
          subclass
        end

        alias_method_chain :inherited, :registering

        [:from, :to].each do |attr|
          define_method "#{attr}_with_default" do |*formats|
            if formats.length
              self.send "#{attr}=", formats.map(&:to_sym)
            else
              self.send "#{attr}_without_default" || []
            end
          end
          alias_method_chain attr, :default
        end
      end

    end

  end
end

