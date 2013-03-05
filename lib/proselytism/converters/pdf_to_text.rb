class Proselytism::Converters::PdfToText < Proselytism::Converters::Base
  class Error < parent::Base::Error; end

  from  :pdf
  to    :txt

  def perform(origin, options={})
    destination = destination_file_path(origin, options.update(:to => :txt))
    command = "pdftotext #{origin} #{destination} 2>&1"
    execute command
    destination
  end

end
