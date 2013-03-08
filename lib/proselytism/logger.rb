module Proselytism

  class Logger < ActiveSupport::BufferedLogger
    class Formatter
      def call(severity, time, progname, msg)
        formatted_time = time.strftime("%Y-%m-%d %H:%M:%S.") << time.usec.to_s[0..2].rjust(3)
        "#{formatted_time} [#{severity}][pid:#{$$}] #{msg.strip}\n"
      end
    end

    def initialize(log, level = DEBUG)
      super(log, level)
      @log.formatter = Formatter.new
    end

  end

  def self.log(severity, message = nil, &block)
    if config.logger
      start_time = Time.now
      if block_given?
        result = yield
        config.logger.send(severity, "#{message} in #{((Time.now - start_time)*1000).to_i} ms")
      else
        config.logger.send(severity, message.strip)
      end
      block_given? ? result : true
    end
  end

end
