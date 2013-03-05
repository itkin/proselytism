require 'spec_helper.rb'

describe Proselytism::Converters::Base.instance do
  context "convert" do
    it "should intercept errors and log them before re raise them" do
      subject.should_receive(:perform).and_raise Proselytism::Converters::PdfImages::Error, 'stubbed error'
      subject.config.logger.should_receive(:error).with do |str|
        str.include? 'stubbed error'
      end
      proc{
        subject.convert 'io', :to => :txt
      }.should raise_error(Proselytism::Converters::PdfImages::Error)
    end
  end
end