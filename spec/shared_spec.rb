require "spec_helper"

describe Proselytism do
  context "log" do
    it "should log with class and time data" do
      subject.config.logger.should_receive(:debug).with do |message|
        message.should match /Proselytism/
        message.should match /io/
        message.should match Time.now.strftime("%Y-%m-%d")
      end
      subject.log(:debug, 'io').should be_true
    end
    it "should log delay when a block is passed" do
      subject.config.logger.should_receive(:debug).with do |message|
        message.should match /Proselytism/
        message.should match /io/
        message.should match /([\d:]+)/
      end
      subject.log :debug , 'io' do
        sleep(0.5)
        false
      end.should be_false
    end

  end
end