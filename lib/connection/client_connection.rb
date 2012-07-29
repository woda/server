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
    signout_successful: "Successfully deleted user",
    update_successful: "Successfully updated user",
    login_successful: "Successfully logged in",
    logout_successful: "Successfully logged out",
    login_failed: "Login failed: login or password invalid",
    login_taken: "Login already taken",
    email_taken: "Email already taken",
    could_not_create_user: "Could not create user: failed",
    could_not_delete_user: "Could not delete user: failed",
    could_not_update_user: "Could not update user: failed",
    user_not_found: "User not found",
    bad_password: "Bad password",
    not_a_hash: "The data is not a hash"
  }

  def messages
    MESSAGES
  end

  def initialize
    super
    @parser_name = ""
    @state_machine = []
    @data = {}
    push_controller_set [UsersController]
  end

  def push_controller_set controllers
    @state_machine << {}
    controllers.each do |controller_class|
      controller = controller_class.new self
      @state_machine.last[controller.route] = controller
    end
  end

  def call_request action, controller
    before = controller.before[action.to_sym] || []
    before.each do |a|
      if a.class == Array
        controller.send(*a)
      else
        controller.send(a)
      end
    end
    controller.send(action)
  end
  
  def on_request request
    error_invalid_route unless request['action']
    route, action = request['action'].split '/'
    action, route = route, action unless action

    error_invalid_route unless route || @state_machine.last.length == 1
    controller = route ? @state_machine.last[route] : @state_machine.last[0]

    error_invalid_route unless controller && controller.actions.member?(action)
    controller.param = request
    call_request action, controller
  end
end

class ClientSslConnection < ClientConnection
  def post_init
    super
    start_tls
  end
end
