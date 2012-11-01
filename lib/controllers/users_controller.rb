require 'models/user'
require 'helpers/hash_digest'
require 'connection/client_connection'
require 'mailfactory'
require 'securerandom'

class UsersController < Controller::Base
  actions :create, :delete, :update, :show, :login, :logout
  before :check_authenticate, :delete, :update, :show, :logout
  before :check_create_params, :create
  before [:check_params, :password], :create
  before :check_update_params, :update
  before [:check_params, :login, :password], :login

  def model
    User
  end

  def create
# TODO: remove those two line to replace them with more generic error handling from user.save
    @connection.error_login_taken if User.first login: param['login']
    @connection.error_email_taken if User.first email: param['email']
    user = set_properties User.new
    user.set_password param['password']
    @connection.error_could_not_create_user unless user.save
    self.set_current_user user
    connection.send_message :signup_successful
    send_confirmation_email
  end

  def set_current_user user
    @connection.data[:current_user] = user
    if user then
      @connection.add_controller SyncController.new @connection
    else
      # TODO: find that name dynamically
      @connection.remove_controller 'sync'
    end
  end

  def send_confirmation_email
    mail = MailFactory.new
    mail.to = @connection.data[:current_user].email
    mail.from = EMAIL_SETTINGS['user_name']
    mail.subject = 'Welcome to Woda!'
    mail.text = "Welcome to Woda #{@connection.data[:current_user].login}!"
    email = EM::P::SmtpClient.send(domain: EMAIL_SETTINGS['domain'],
                                   host: EMAIL_SETTINGS['address'],
                                   starttls: true,
                                   port: EMAIL_SETTINGS['port'],
                                   auth: {:type => :plain,
                                     :username => EMAIL_SETTINGS['user_name'],
                                     :password => EMAIL_SETTINGS['password']},
                                   from: mail.from, to: mail.to,
                                   content: "#{mail.to_s}\r\n.\r\n",)
    email.callback { } # TODO: success log
    email.errback { } # TODO: failure log
  end

  def delete
    user = @connection.data[:current_user]
    @connection.error_delete_failed unless user.destroy
    set_current_user nil
    @connection.send_message :signout_successful
  end

  def update
    user = @connection.data[:current_user]
    set_properties user
    user.set_password param['password'] if param['password']
    @connection.error_could_not_update unless user.save
    @connection.send_message :update_sucessful
  end

  def show
    # @connection.send_object(status: "ok", type: "user_infos",
    #                        data: @connection.data[:current_user].attributes)
    # Ne display que l'user loguer

    user = user.find param['login']
    @connection.send_object(status: "ok", type: "user_infos",
                            data: "{\"login\":\"#{user.login}\",\"email\":\"#{user.email}\"}")
  end
  
  def login
    user = User.first login: param['login']
    @connection.error_user_not_found unless user
    @connection.error_bad_password unless user.has_password? param['password']
    self.set_current_user user
    @connection.send_message :login_successful
  end

  # Devrait peut-etre renvoyer une erreur si l'user est pas logge
  def logout
    set_current_user nil
    @connection.send_message :logout_successful
  end

  def get_user_list
    user = User.all:login => param['login'] if param['login'].exists?
    user = User.all :email => param['email'] if param['email'].exists?
    user = User.all(:login =>param['login']) + User.all(:email => param['email']) if param['login'].exists? && param['email'].exists?
    
    userList.each do | user |
      @connection.send_object(status: "ok",
                              type: "user_infos",
                              data: "{\"login\":\"#{user.login}\",\"email\":\"#{user.email}\"}")
    end
  end

end
