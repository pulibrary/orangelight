class JsonFilterFormatter < Logger::Formatter
    def call(severity, timestamp, progname, msg)
        log_data = msg.is_a?(Hash) ? msg : { message: msg.to_s }

        if log_data.is_a?(Hash) && log_data.key?(:action_controller)
            log_data = log_data.dup
            log_data.delete(:action_controller)
        end

        "#{JSON.dump(log_data)}\n"
    end
end