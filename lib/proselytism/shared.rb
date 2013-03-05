module Proselytism
  module Shared

    def log(severity, message = nil)
      config.logger.send(severity, message) if config.logger
    end

    def log_with_time(severity, message = nil, &block)
      start_time = Time.now
      delay = nil
      if block_given?
        result = yield
        delay = "(#{((Time.now - start_time)*1000).to_i} ms) "
      end
      message= "** Proselytism #{start_time.strftime("%Y-%m-%d %H:%M:%S")} #{delay}: " + message.to_s
      log_without_time(severity, message)
      block_given? ? result : true
    end
    alias_method_chain :log, :time

  end
end
