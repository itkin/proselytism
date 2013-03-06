require_relative "spec_helper"

describe Proselytism::Converters::PdfImages.instance do

  context "perform" do
    before do
      clear_tmp_dir
    end
    it "should work" do
      subject.perform fixture_path("001.pdf"), :to => :ppm, :dir => tmp_dir
    end
    it "should log and raise error" do
      proc{
        subject.perform fixture_path("001.doc"), :to => :ppm, :dir => tmp_dir
      }.should raise_error(subject.class::Error)

    end
  end
end