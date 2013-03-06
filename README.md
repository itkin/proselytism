# Proselytism

Document converter, text and image extractor using OpenOffice headless server, pdf_tools and net_pbm

## Note

This gem has been originally written for as a RoR 3.2 engine running on Ruby 1.8.7.
It should be framework agnostic and has been tested on Ubuntu and MacOSX.

Due to its dependency to system_timer it doesn't work with ruby 1.9.x

## Installation

Install the required external librairies :

    # aptitude install netpbm
    # aptitude install xpdf
    # aptitude install libreoffice

Add this line to your application's Gemfile:

    gem 'proselytism'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install proselytism

Generate the config file or / and an initializer

    $ rails g proselytism:config
    $ rails g proselytism:initializer

As an engine, Proselytism automatically load and autoconfig with /config/proselytism.yml if it exists
You can override these configurations params with an initializer. This is especially usefull when you want a custom log file
    
```ruby
#/config/initializers/proselytism.rb
Proselytism.config do |config|
  config.logger = ActiveSupport::BufferedLogger.new(File.join(Rails.root, 'log', 'proselytism.log'))
end
```

## Usage

```ruby
Proselytism.convert source_file_path, :to => :pdf do |converted_file_path|

end
Proselytism.extract_text source_file_path do |extracted_text|

end
Proselytism.extract_images source_file_path do |image_files_paths|

end
```

Proselytism create its converted files in temporary folders.
  - If you pass a block to the method the folders are automatically deleted after the block is yield, so use or copy the file content within the block
  - If you don't pass a block, don't forget to safely remove the temp folder

```ruby
pdf_file_path = Proselytism.convert source_file_path, :to => :pdf
FileUtils.remove_entry_secure File.dirname(pdf_file_path)
```
    
## Add your own converter

Add your own converter by extending Proselytism::Converters::Base
  - Your converter will be automatically selected and used related to the form and to extensions list
  - Add a perform method which
    - define a text command
    - call execute
    - return the converted file(s) path

```ruby
class MyConverter < Proselytism::Converters::Base
  form :ext1, :ext2
  to :ext3, :ext4

  def perform(origin, options={})
    destination = destination_file_path(origin, options)
    command = "pdftotext #{origin} #{destination} 2>&1"
    execute command
    destination
  end
end
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
