require 'eventmachine'
require 'connection/parser/serializer'
require 'connection/connection_protocol'
require 'controllers/users_controller'

class ClientConnection < EventMachine::Connection
  include Protocol::ConnectionProtocol

  attr_accessor :data

  MESSAGES = {
    invalid_login: "Login is invalid",
    good_login: "Login succeeded",
    connection_ok: "Connected successfully",
    invalid_request: "Unknown request",
    invalid_route: "Unknown route",
    need_login: "Not logged in",
    missing_params: "Missing parameters",
    signup_successful: "Successfully created user",
    login_successful: "Successfully logged in"
  }

  def messages
    MESSAGES
  end

  def initialize
    super
    @parser_name = ""
    @state_machine = []
    push_controller_set [UsersController]
    @data = {}
  end

  def push_controller_set controllers
    @state_machine << {}
    controllers.each do |c|
      controller = c.new self
      @state_machine.last[controller.route] = controller
    end
  end

  # def on_login login
  #   if login['login'] == "hello" && login['password'] == 'world'
  #     send_message :good_login
  #     @parser.unpack.on_parse_complete = method(:on_request)
  #   else
  #     send_error :invalid_login
  #   end
  # end

  def on_request request
    controller = @state_machine.last[request['route']]
    return send_error(:invalid_route) unless controller && controller.actions.member?(request['action'])
    controller.param = request
    before = controller.before[request['action'].to_sym] || []
    before.each do |action|
      return unless controller.send(action)
    end
    controller.send(request['action'].to_sym)
  end
end

class ClientSslConnection < ClientConnection
  def post_init
    start_tls
  end
end
