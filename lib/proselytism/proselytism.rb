require "active_support/core_ext/module/attribute_accessors"

module Proselytism
  mattr_accessor :config

  def self.config(&block)
    @@config ||= Config.new
    yield @@config if block
    @@config
  end

  class Config

    def initialize
      @options ||= {}
    end

    def method_missing(method=nil, value=nil, &block)
      if method.to_s.match(/=$/)
        @options[method.to_s.gsub(/=$/,'')] = value
      else
        @options[method.to_s]
      end
    end
  end




  # Finds the relevant converter
  def self.get_converter(origin, destination)
    Converters::Base.subclasses.detect do |converter|
      converter.from.include?(origin) and converter.to.include?(destination)
    end.instance
  end



  # Converts a document from one format to another
  def self.convert(file_path, options={}, &block)
    options.symbolize_keys!
    options[:to]    ||= :txt

    # Tempfile don't have extension => let's make with the from option
    if options[:from] and file_path.match(/[^\.]*$/)[0] != options[:from].to_s
      file = Tempfile.new [File.basename(file_path), ".#{options[:from]}"]
      file.write File.read(file_path)
      file.close
      file_path = file.path
    else
      # if file_path has extension and no from option => set the option
      options[:from] ||= file_path.match(/[^\.]*$/)[0].downcase.to_sym
    end

    dir = Dir.mktmpdir(nil, options[:dir] || config.tmp_path)
    result = get_converter(options[:from], options[:to]).convert file_path, options.update(:dir => dir)

    if block_given?
      output = yield result
      FileUtils.remove_entry_secure dir
      output
    else
      result
    end
  end

  def self.extract_images(file_path, options={}, &block)
    if File.extname(file_path).match(/pdf/)
      convert file_path, :to => :ppm do |files|
        output = files.map do |file|
          convert file, :to => :jpg, :dir => File.dirname(file)
        end
        #block.call(output)
        block_given? ? yield(output) : output
      end
    else
      convert file_path, :to => :html do |file|
        output = Dir.glob(File.join(File.dirname(file), "*.{jpg,jpeg,bmp,tif,tiff,gif,png}"))
        #block.call(output)
        block_given? ? yield(output) : output
      end
    end
  end

  def self.extract_text(file_path, options={}, &block)
    convert(file_path, options.update(:to => :txt)) do |file|
      text = File.read(file).toutf8
      block_given? ? yield(text) : text
    end
  end

end
