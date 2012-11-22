module Protocol
  ##
  # This exception is thrown when we immediately need to return from the request.
  # It will never cause the program to exit, and will not cause an error to be
  # returned either: it is assumed that whatever needs to be sent to the client
  # has already been sent by the time this is raised.
  class RequestShortCut < Exception
  end

  ##
  # Mixin to ClientConnection. Handles the protocol part of it, as opposed to
  # the application logic.
  module ConnectionProtocol
    attr_reader :parser

    ##
    # If the first line of the connection is "json", parses and returns json.
    # If it is "msgpack", parses and returns msgpack.
    def choose_parser data
      @parser_name << data
      endline = @parser_name.index "\n"
      return unless endline

      data = @parser_name[endline+1..-1]
      @parser_name = @parser_name[0..endline-1].downcase
      # Note: we don't use symbols here because they aren't garbage collected
      begin
        @parser = Protocol::Serializer.new @parser_name
        @parser.unpack.on_parse_complete = method(:on_parsed)
        send_message :connection_ok
      rescue ArgumentError
        send_data "Error: Protocol '#{@parser_name}' not recognized\n"
        close_connection_after_writing
      end
      receive_data data if @parser
    end
    
    ##
    # Called by the parser when a message is completely received.
    #
    # request is a Hash containing the request
    def on_parsed request
      begin
        error_not_a_hash unless request.class == Hash
        on_request request
      rescue RequestShortCut
      rescue Exception => e
        # puts e.message
        # puts e.backtrace
        send_exception e, type: "exception"
      end
    end

    ##
    # Standard method called by eventmachine.
    #
    # data is a string containing the data received from the connection.
    def receive_data data
      if @parser
        begin
          @parser.unpack << data
        rescue Exception => e
          # We MUST destroy the connection if the data is incorrect, unfortunately

          # puts e.message
          # puts e.backtrace
          send_exception e, type: "invalid_data"
          close_connection_after_writing
        end
      else
        choose_parser data
      end      
    end
    
    ##
    # Sends object obj as serialized by the parser/serializer (either json or msgpack).
    #
    # obj is generally a Hash (it could also be an array) and cannot be nil.
    def send_object obj
      LOG.debug "Sending on #{@uuid}: #{obj}"
      @parser.pack.encode(obj) do |chunk|
        send_data chunk
      end
      send_data "\n" if @parser_name == "json"
    end

    ##
    # Special send_object wrapper to make it easier to send exceptions.
    #
    # e is the exception itself.
    # options is a Hash with :type as its only possible value. If it isn't set, the type of
    #  the message will be "exeption"
    def send_exception e, options={}
      send_object({ status: "ko", type: (options[:type].to_s || "exception"), message: e.message})
    end
    
    ##
    # Special send_object wrapper that makes it easier to send an error
    #
    # slug is the type (as found in ClientConnection)
    # additional_hash will be added to the Hash
    def send_error slug, additional_hash = {}
      send_object(additional_hash.merge({status: "ko", type: slug.to_s, message: messages[slug]}))
    end

    ##
    # Special send_object wrapper that makes it easier to send a success message
    #
    # slug is the type (as found in ClientConnection)
    # additional_hash will be added to the Hash    
    def send_message slug, additional_hash = {}
      send_object(additional_hash.merge({status: "ok", type: slug.to_s, message: messages[slug]}))
    end

    ##
    # This method_missing method calls send_error(:xyz) for every function call
    # of the type error_xyz. This makes it very easy and natural to send errors.
    # It also shortcuts the request automatically, so that aborting the request
    # with a given error can be done in one line.
    def method_missing name, *args, &block
      if name.to_s =~ /^error_(.*)/ && messages[$1.to_sym]
        send_error $1.to_sym
        raise RequestShortCut.new
      else
        super
      end
    end
  end
end
