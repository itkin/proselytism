class Proselytism::Converters::PpmToJpeg < Proselytism::Converters::Base
  class Error < parent::Base::Error; end

  from :ppm
  to   :jpg, :jpeg

  def perform(origin, options={})
    destination = origin.gsub(/\..*$/,'.jpg')
    command= "pnmtojpeg #{origin} > #{destination} 2>&1"
    execute command
    destination
  end

end
