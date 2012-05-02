require 'models/user'
require 'helpers/hash_digest'
require 'connection/client_connection'

class UsersController < Controller::Base
  actions :create, :delete, :update, :show, :login
  before :check_authenticate, :delete, :update

  def create
    @connection.error_missing_params unless param['login'] && param['password']
    @connection.error_login_taken if User.first :login => param['login']
    user = User.new :login => param['login']
    user.set_password param['password']
    @connection.error_could_not_create_user unless user.save
    connection.data[:current_user] = user
    connection.send_message :signup_successful
  end

  def delete
  end

  def update
  end

  def show
    @connection.error_missing_params unless param['login']
    user = User.first :login => param['login']
    @connection.error_user_not_found unless user
    @connection.send_object status: "ok", type: "user_infos", data: user.attributes
  end

  def login
    @connection.error_missing_params unless param['login'] && param['password']
    user = User.first :login => param['login']
    @connection.error_user_not_found unless user
    @connection.error_bad_password unless user.has_password? param['password']
    @connection.data[:current_user] = user
    @connection.send_message :login_successful
  end

  def logout
  end
end
