require 'system_timer'

class Proselytism::Converters::OpenOffice < Proselytism::Converters::Base

  class Error < parent::Base::Error; end

  from  :odt, :doc, :rtf, :sxw, :docx, :txt, :html, :htm, :wps
  to    :odt, :doc, :rtf, :pdf, :txt, :html, :htm, :wps

  module Bridges
    module JOD
      def self.command
        "java -jar #{File.expand_path('open_office/odconverters/jodconverter-2.2.2/lib/jodconverter-cli-2.2.2.jar', File.dirname(__FILE__))}"
      end
    end
    module PYOD
      def self.command
        "python #{File.expand_path('open_office/odconverters/pyodconverter.py', File.dirname(__FILE__))}"
      end
    end
  end

  # Converts documents
  def perform(origin, options={})
    destination = destination_file_path(origin, options)
    command = "#{Proselytism::Converters::OpenOffice}::Bridges::#{config.oo_server_bridge}".constantize.command + " '#{origin}' '#{destination}' 2>&1"
    server.perform { execute(command) }
    destination
  end


  # HACK pour contourner un comportement ?trange d'OpenOffice, normalement les enregistrements
  # se font en UTF-8, mais parfois pour une raison obscure les fichiers texte sont en ISO-8859-1
  # donc on rajoute un test pour re-convertir dans l'encodage qu'on attend
  def convert_txt_to_utf8(file_path)
    if `file #{file_path}` =~ /ISO/
      system("iconv --from-code ISO-8859-1 --to-code UTF-8 #{file_path} > tmp_iconv.txt && mv tmp_iconv.txt #{file_path}")
    end
  end

  def server
    Server.instance
  end


  class Server
    include Singleton
    include Proselytism::Shared
    class Error < Proselytism::Converters::OpenOffice::Error; end

    def config
      Proselytism.config
    end

    # Run a block with a timeout and retry if the first execution fails
    def perform(&block)
      attempts = 1
      begin
        ensure_available
        Timeout::timeout(config.oo_conversion_max_time,&block)
      rescue Timeout::Error, Proselytism::Converters::OpenOffice::Error
        attempts += 1
        restart!
        retry unless attempts > config.oo_conversion_max_tries
        raise Error, "OpenOffice server perform timeout"
      end
    end

    # Restart if running or start new instance
    def restart!
      stop! if running?
      start!
    end

    # Start new instance
    def start!
      log :debug, "OpenOffice server started" do
        system "#{config.open_office_path} -headless -accept=\"socket,host=127.0.0.1,port=8100\;urp\;\" -nofirststartwizard -nologo -nocrashreport -norestore -nolockcheck -nodefault &"
        begin
          SystemTimer.timeout_after(3) do
            while !running?
              log :debug, ". Waiting OpenOffice server to run"
              sleep(0.1)
            end
          end
        rescue
          raise Error, "Could not start OpenOffice"
        end
        # OpenOffice needs some time to wake up
        sleep(config.oo_server_start_delay)
      end
      nil
    end

    def start_with_running_control!
      if running?
        log :debug, "OpenOffice server is allready running"
      else
        start_without_running_control!
      end
    end
    alias_method_chain :start!, :running_control

    # Kill running instance
    def stop!
      #operating_system = `uname -s`
      #command = "killall -u `whoami` -#{operating_system == "Linux" ? 'q' : 'm'} soffice"
      begin
        Timeout::timeout(3) do
          loop do
            system("killall -9 soffice && killall -9 soffice.bin > /dev/null 2>&1")
            break unless running?
            sleep(0.2)
          end
        end
      rescue Timeout::Error
        raise Error, "Could not kill OpenOffice !!"
      ensure
        # Remove user profile
        system("rm -rf ~/openoffice.org*")
        log :debug, "OpenOffice server stopped"
      end
    end

    def stop_with_running_control!
      if !running?
        log :debug, "OpenOffice server is allready stoped"
      else
        stop_without_running_control!
      end
    end
    alias_method_chain :stop!, :running_control

    # Is OpenOffice server running?
    def running?
      !`pgrep soffice`.blank?
    end


    # Is the current instance stuck ?
    def stalled?
      begin
        SystemTimer.timeout_after config.oo_server_max_cpu_delay do
          loop do
            cpu_usage = `ps -Ao pcpu,pid,comm= | grep soffice`.split(/\n/).map{|usage| /^\s*\d+/.match(usage)[0].strip.to_i}
            break unless cpu_usage.all?{|usage| usage > config.oo_server_max_cpu }
            sleep(0.2)
          end
        end
        false
      rescue
        log :error, "OpenOffice server stalled : \n---\n" + `ps -Ao pcpu,pid,comm | grep soffice` + "\n---"
        true
      end
    end

    def available?
      `ps -o pid,stat,command |grep soffice`.match(/\d+\s(\w)/i)[1] == "S"
    end

    # Make sure there will be an available instance
    def ensure_available
      start! unless running?
      restart! if stalled?
      begin
        SystemTimer.timeout_after config.oo_server_availability_delay do
          while !available?
            log :debug, ". Waiting OpenOffice server availability"
            sleep(0.5)
          end
        end
      rescue Timeout::Error
        raise Error, "OpenOffice Server unavailable"
      end
      true
    end

  end



end

