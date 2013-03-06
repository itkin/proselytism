require_relative "spec_helper"

describe Proselytism::Converters::PdfToText.instance do
  context "perform" do
    before :all do
      @result = subject.perform(fixture_path("001.pdf"), :dir => tmp_dir)
    end
    after :all do
      FileUtils.rm(@result)
    end
    it "it should create a file" do
      File.exist?(@result).should be_true
    end
    it "it should be txt file" do
      File.read(@result).should include("David FRANCOIS")
    end

  end
end
