module Protocol
  module ConnectionProtocol
    def choose_parser data
      @parser_name << data
      endline = @parser_name.index "\n"
      return unless endline

      data = @parser_name[endline+1..-1]
      @parser_name = @parser_name[0..endline-1].downcase
      # Note: we don't use symbols here because they aren't garbage collected
      begin
        @parser = Protocol::Serializer.new @parser_name
        @parser.unpack.on_parse_complete = method(:on_request)
        send_message :connection_ok
      rescue ArgumentError
        send_data "Error: Protocol '#{@parser_name}' not recognized\n"
        close_connection_after_writing
      end
      receive_data data if @parser
    end
    
    def receive_data data
      if @parser
        begin
          @parser.unpack << data
        rescue Exception => e
          puts e.backtrace
          send_exception e, type: "invalid_data"
        end
      else
        choose_parser data
      end
    end
    
    def send_object obj
      @parser.pack.encode(obj) do |chunk|
        send_data chunk
      end
      send_data "\n" if @parser_name == "json"
    end

    def send_exception e, options={}
      send_object status: "ko", type: (options[:type].to_s || "exception"), message: e.message
    end
    
    def send_error slug
      send_object status: "ko", type: slug.to_s, message: messages[slug]
    end
    
    def send_message slug
      send_object status: "ok", type: slug.to_s, message: messages[slug]
    end
  end
end
