require_relative "spec_helper"

describe Proselytism::Converters::OpenOffice::Server.instance do
  context "start!" do
    before :each do
      subject.stop!
    end
    it "should start the server" do
      subject.start!
    end
  end
  context "running?" do
    it "should return false if no instance is running" do
      subject.stop!
      subject.running?.should be_false
    end
    it "should return false if an instance is running" do
      subject.start!
      subject.running?.should be_true
    end
  end
  context 'available?' do
    before :each do
      subject.start!
    end
    it "should return yes when no conversion is active" do
      subject.available?.should be_true
    end
  end
  context "ensure_available" do
    it "should start the server" do
      subject.stop!
      subject.ensure_available.should be_true
    end
    it "should raise a timeout error after config.oo_server_availability_delay time" do
      subject.stub(:available?) do
        sleep subject.config.oo_server_availability_delay + 1
      end
      proc{
        subject.ensure_available
      }.should raise_error(Proselytism::Converters::OpenOffice::Server::Error)
    end
  end
end

describe Proselytism::Converters::OpenOffice.instance do
  context "perform" do
    before do
      subject.server.stop!
      clear_tmp_dir
    end

    it "should work" do
      proc{
        subject.perform fixture_path("002.doc"), :dir => tmp_dir, :to => :txt
      }.should change(self, :tmp_dir_file_count).by 1
    end

    it "should not freeze" do
      3.times do |j|
        proc{
            2.times do |i|
              subject.perform fixture_path("00#{i+1}.doc"), :dest => tmp_path("#{i}-#{j}.txt"), :to => :text
            end
        }.should change(self, :tmp_dir_file_count).by 2
      end
    end

    it "should convert to html and extract images"  do
      proc{
        subject.perform(fixture_path("002.doc"), :dir => tmp_dir, :to => :html)
      }.should change(self, :tmp_dir_file_count).by 2
    end

    it "should return error" do
      subject.server.start!
      Timeout.should_receive(:timeout).twice.and_raise(Timeout::Error)
      proc{
        subject.perform(fixture_path("005-fake.doc"), :dir => tmp_dir, :to => :pdf)
      }.should raise_error
    end
  end
end