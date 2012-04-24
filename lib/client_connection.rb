require 'eventmachine'
require 'parser/serializer'
require 'connection_protocol'

class ClientConnection < EventMachine::Connection
  include Protocol::ConnectionProtocol

  MESSAGES = {
    invalid_login: "Login is invalid",
    good_login: "Login succeeded",
    connection_ok: "Connected successfully"
  }

  def initialize
    super
    @parser_name = ""
  end

  def on_login login
    if login['login'] == "hello" && login['password'] == 'world'
      send_message :good_login
      @parser.unpack.on_parse_complete = method(:on_request)
    else
      send_error :invalid_login
    end
  end

  def on_request request
    p request
    send_object request
  end
end
