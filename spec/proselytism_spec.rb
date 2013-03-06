# encoding: UTF-8

require_relative "spec_helper"

describe Proselytism do
  before do
    clear_tmp_dir
  end
  context "get_converter" do
    it "doc -> txt should return OpenOffice" do
      subject.get_converter(:doc, :txt).should == Proselytism::Converters::OpenOffice.instance
    end
    it "pdf -> txt should return PdfTools" do
      subject.get_converter(:pdf, :txt).should == Proselytism::Converters::PdfToText.instance
    end
    it "ppm -> jpg should return PpmToJpeg" do
      subject.get_converter(:ppm, :jpg).should == Proselytism::Converters::PpmToJpeg.instance
    end
  end

  context "convert"  do
    before :each do
      Proselytism::Converters::OpenOffice.instance.should_receive(:convert).with do |path, options|
        File.exist?(path).should be_true
        File.basename(path).should match(/\.doc$/)
        options[:from].should == :doc
        options[:to].should == :txt
      end.and_return(fixture_path('001.txt'))
    end

    it "should accept a File path" do
      subject.convert(fixture_path("001.doc"), :to => :txt)  do

      end
    end

    #it "should accept a File instance" do
    #  subject.convert(File.open(fixture_path("001.doc")), :to => :txt)
    #end
    #
    #it "should accept a Tempfile instance"  do
    #  temp = Tempfile.new('io')
    #  temp.write File.read(fixture_path("001.doc"))
    #  subject.convert(temp, :to => :txt, :from => :doc)
    #end

    it "should accept a Tempfile path" do
      temp = Tempfile.new('io')
      temp.write File.read(fixture_path("001.doc"))
      subject.convert(temp.path, :to => :txt, :from => :doc) do

      end
    end

  end

  it "should convert to html"  do
    subject.convert(fixture_path("002.doc"), :to => :html) do |file_path|
      Dir.glob(File.join(File.dirname(file_path), '*')).count.should == 2
    end
  end
  context "extract_images"  do
    def extract_images_form(fixture_name, &block)
      subject.extract_images(fixture_path(fixture_name),&block)
    end
    it "should yield jpeg files from pdf source and clear tmp dir" do
      proc{
        extract_images_form "001.pdf" do |files|
          files.each do |file|
            File.exist?(file).should be_true
            `file --mime #{file}`.should match /jpeg/
          end
        end
      }.should_not change(self, :tmp_dir_file_count)
    end
    it "should yield jpeg files from doc source and clear tmp dir" do
      proc{
        extract_images_form "002.doc" do |files|
          files.each do |file|
            File.exist?(file).should be_true
            `file --mime #{file}`.should match /jpeg/
          end
        end
      }.should_not change(self, :tmp_dir_file_count)
    end
  end
  context "extract_text" do
    def extract_text_form(fixture_name, &block)
      subject.extract_text(fixture_path(fixture_name),&block)
    end
    it "should work with pdf" do
      proc{
        extract_text_form("001.pdf") do |text|
          text.should match("David FRANCOIS")
          text.should match("ingénierie")
        end
      }.should_not change(self, :tmp_dir_file_count)
    end
    it "should work with doc"  do
      proc{
        extract_text_form("002.doc") do |text|
          text.should match("Fanny HERBERT")
          text.should match("l’Institut Supérieur d’Etudes")
        end
      }.should_not change(self, :tmp_dir_file_count)
    end
  end
end
