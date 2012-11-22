require 'models/user'
require 'helpers/hash_digest'
require 'connection/client_connection'
require 'mailfactory'
require 'securerandom'

class UsersController < Controller::Base
  actions :create, :delete, :update, :show, :login, :logout, :list
  before :check_authenticate, :delete, :update, :show, :logout
  before :check_create_params, :create
  before [:check_params, :password], :create
  before [:check_update_params, :password], :update
  before [:check_params, :login, :password], :login

  def model
    User
  end

  ##
  # Action: creates a user according to the params
  def create
    LOG.info "Trying to create #{param['login']}"
    @connection.error_login_taken if User.first login: param['login']
    @connection.error_email_taken if User.first email: param['email']
    user = set_properties User.new
    user.set_password param['password']
    @connection.error_could_not_create_user unless user.save
    self.set_current_user user
    connection.send_message :signup_successful
    # TODO: defer this
    send_confirmation_email
  end

  ##
  # Sets the current user: from then on, that user is logged in.
  def set_current_user user
    @connection.data[:current_user] = user
    if user then
      @connection.add_controller SyncController.new @connection
    else
      # TODO: find that name dynamically
      @connection.remove_controller 'sync'
    end
  end

  ##
  # Sends registration confirmation email to whoever is the current user.
  # Should only be called by create()
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

  ##
  # Action: Deletes the current user.
  def delete
    LOG.info "Trying to delete #{@connection.data[:current_user].login}"
    user = @connection.data[:current_user]
    @connection.error_delete_failed unless user.destroy
    set_current_user nil
    @connection.send_message :signout_successful
  end

  ##
  # Action: update informations for the current user.
  def update
    LOG.info "Modifying information for user #{@connection.data[:current_user].login}"
    user = @connection.data[:current_user]
    set_properties user
    user.set_password param['password'] if param['password']
    @connection.error_could_not_update unless user.save
    @connection.send_message :update_sucessful
  end

  ##
  # Action: show a user specified in param. Currently every information, except those
  # related to the password.
  def show
    LOG.info "Showing user #{param['login']}"
    user = User.first param['login']
    attributes = user.attributes.clone()
    attributes.delete(:pass_hash)
    attributes.delete(:pass_salt)
    @connection.send_object(status: "ok", type: "user_infos",
                            data: attributes)
  end
  
  ##
  # Action: login as a given user.
  def login
    LOG.info "User trying to login: #{param['login']}"
    user = User.first login: param['login']
    @connection.error_user_not_found unless user
    @connection.error_bad_password unless user.has_password? param['password']
    self.set_current_user user
    @connection.send_message :login_successful
  end

  ##
  # Action: logout
  def logout
    LOG.info "Logging out user #{@connection.data[:current_user].login}"
    set_current_user nil
    @connection.send_message :logout_successful
  end

  def list
    # user = User.all :login => param['login'] if param['login'].exists?
    # user = User.all :email => param['email'] if param['email'].exists?
    
    userList = User.all
    user_infos = []
    userList.each do | user |
      hash_user={:login => user.login, :email => user.email}
      user_infos.infos.push(hash_user)
    end
    @connection.send_object(status: "ok",
                              type: "user_list",
                              data: user_infos)
  end
end
