# Proselytism

Document converter, text and image extractor using OpenOffice headless server (JOD or PYOD converter), pdf_tools and net_pbm

Handled formats for document conversion : odt, doc, rtf, sxw, docx, txt, html, htm, wps, pdf

## Note

This gem has been originally written as a RoR 3.2 engine running on Ruby 1.8.7. 

It is framework agnostic and has been tested on Ubuntu and MacOSX.

## Installation

Install the required external librairies :

    # aptitude install netpbm
    # aptitude install xpdf
    # aptitude install libreoffice
    
Add this line to your application's Gemfile:

    gem 'proselytism'

Note : for ruby 1.9 use the branch 1.9

    gem 'proselytism', :git => "git://github.com/itkin/proselytism.git", :branch => "1.9"

And then execute:

    $ bundle

Generate the config file 

    $ rails g proselytism:config
 
As an engine, Proselytism automatically load /config/proselytism.yml (if the file exists) and sets its config params depending on the current rails env. 

Generate an initializer (optional)
    
    $ rails g proselytism:initializer

You can override the configuration file params by adding an initializer (especially usefull when you want a custom log file to follow the conversion times in order to tune the server settings)

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

Proselytism creates its converted files in temporary folders.
  - If you pass a block to the method above the folders are automatically deleted after the block is yield, so use or copy the file content within the block
  - If you don't pass a block, the mentioned folder and its content remains permanently, so don't forget to safely remove it yourself

```ruby
pdf_file_path = Proselytism.convert source_file_path, :to => :pdf
#my code
FileUtils.remove_entry_secure File.dirname(pdf_file_path)
```
    
## Add your own converters

Add your own converter by extending Proselytism::Converters::Base
  - Your converter will be automatically selected and used related to the params given to the :from and :to methods
  - Add a perform method which
    - calls the execute method with your custom command
    - returns the converted file(s) path(s)

Proselytism::Converters::Base takes care of 
  - raising error (if the command execution fail) 
  - logging the command output

```ruby
class MyConverter < Proselytism::Converters::Base
  class Error < parent::Base::Error; end
  
  form :ext1, :ext2
  to :ext3, :ext4

  def perform(origin, options={})
    destination = destination_file_path(origin, options)
    command = "mycommand #{origin} #{destination} 2>&1"
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
