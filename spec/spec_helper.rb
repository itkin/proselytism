require 'pry'

require "lib/proselytism"

Proselytism.config do |config|
  config.open_office_path = "/Applications/OpenOffice.org.app/Contents/MacOS/soffice"
  config.oo_server_bridge = "JOD"

  config.oo_server_max_cpu = 95  #percent
  config.oo_server_max_cpu_delay = 2 #seconds

  config.oo_server_availability_delay = 6 # seconds
  config.oo_server_start_delay = 2 #seconds
  config.oo_conversion_max_tries = 2
  config.oo_conversion_max_time = 4 #seconds

  config.tmp_path = File.expand_path("../tmp",  __FILE__)
  config.logger = Proselytism::Logger.new(File.expand_path("../tmp/log",  __FILE__), 0)
end


module RspecAccessorsHelper
  def fixture_path(name)
    File.join(File.dirname(__FILE__),'fixtures',name)
  end
  def tmp_path(name)
    File.join(tmp_dir,name)
  end
  def tmp_dir
    File.join(File.dirname(__FILE__),'tmp')
  end
  def fixture_file(name)
    File.open fixture_path(name)
  end
  def clear_tmp_dir
    Dir[File.join(tmp_dir, '*')].each{|f| FileUtils.rm_r(f) unless File.basename(f) == 'log' }
  end
  def tmp_dir_file_count
    Dir[File.join(tmp_dir, '*')].count
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.include(RspecAccessorsHelper)
end