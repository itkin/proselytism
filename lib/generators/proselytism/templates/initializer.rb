Proselytism.config do |config|
  #Open Office binary path  /usr/bin/soffice for unix or /Applications/OpenOffice.org.app/Contents/MacOS/soffice for mac OSX
  config.open_office_path = "/Applications/OpenOffice.org.app/Contents/MacOS/soffice"

  #Bridge PYOD or JOD (PYOD dones't work as is on mac)
  config.oo_server_bridge = "JOD"

  #When ensuring server availability (before converting a doc),
  #Restart the server if all processs are above max cpu during max_cpu_delay
  config.oo_server_max_cpu = 95  #percent
  config.oo_server_max_cpu_delay = 2 #seconds

  #Time the server waits for availability before converting a doc
  config.oo_server_availability_delay = 6 # seconds

  # Wait time after server start
  config.oo_server_start_delay = 2 #seconds


  config.oo_conversion_max_tries = 2

  #max time for performing a conversion (then restart an attempt)
  config.oo_conversion_max_time = 5 #seconds

  #Path where conversion are done by default system temp dir
  #config.tmp_path = File.expand_path("../tmp",  __FILE__)

  #Log level: By default env log level
  #config.log_level  = Rails.logger.level

  #Log path :
  #config.log_path   = File.join(Rails.root, 'log', "proselytism.log")

  #Logger instance
  #config.logger     = Proselytism::BufferedLogger.new Proselytism.config.log_path, Proselytism.config.log_level

end
