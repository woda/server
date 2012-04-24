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
        @parser.unpack.on_parse_complete = method(:on_login)
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
          # Need to do more specific exception handling afterwards
        rescue Exception => e
          # Refactor this so it doesn't appear three times in the code
          send_object status: "ko", type: "invalid_data", message: "Invalid data: #{e.message}"
        end
      else
        choose_parser data
      end
    end
    
    def send_object obj
      @parser.pack.encode(obj) do |chunk|
        send_data chunk
      end
    end
    
    def send_error slug
      send_object status: "ko", type: slug, message: MESSAGES[slug]
    end
    
    def send_message slug
      send_object status: "ok", type: slug, message: MESSAGES[slug]
    end
  end
end
