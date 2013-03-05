class Proselytism::Converters::PdfImages < Proselytism::Converters::Base
  class Error < parent::Base::Error; end

  from  :pdf
  to    :ppm

  def perform(origin, options={})
    command = "cd #{options[:dir]} && pdfimages #{origin} 'img' 2>&1"
    execute command
    Dir.glob(File.join(options[:dir], '*'))
  end

end
