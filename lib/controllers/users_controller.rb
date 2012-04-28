require 'models/user'

class UsersController < Controller::Base
  actions :create, :delete, :update, :show, :login
  before :check_authenticate, :delete, :update

  def create
    return send_error(:missing_params) unless param['login'] && param['password']
    digest = Digest::SHA2.new(256)
    user = User.new :login => param['login'], :pass_hash => (digest << param['password']).to_s
    user.save
    connection.data[:current_user] = user
    connection.send_message :signup_successful
  end

  def delete
  end

  def update
  end

  def show
    return send_error(:missing_params) unless param['login']
    user = User.find :login => param['login']
    connection.send_object status: "ok", type: "user_infos", data: user[param['login']]
  end

  def login
  end

  def logout
  end
end
