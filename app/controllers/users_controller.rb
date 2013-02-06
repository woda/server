class UsersController < ApplicationController

  before_filter :require_login, :only => [:delete, :update, :show, :logout]
  before_filter :check_create_params, :only => [:create]
  before_filter { |c| c.check_params(:password) }, :only => [:create]
  before_filter { |c| c.check_update_params :password }, :only => [:update]
  before_filter { |c| c.check_params :login, :password }, :only => [:login]

  def model
    User
  end

	def create
	    raise RequestError.new(:login_taken, "Login already taken") if User.first login: param['login']
	    raise RequestError.new(:email_taken, "Email already taken") if User.first email: param['email']
	    user = set_properties User.new
	    user.set_password params['password']
	    raise RequestError.new(:db_error, "Database error") unless user.save
	    session[:user] = user
	    send_confirmation_email
	    @result = user
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
  	raise RequestError.new(:db_error, "Database error") unless session[:user].destroy
  	session[:user] = nil
    @result = {success: true}
  end

  def update
  	session[:user].set_password params['password'] if params['password']
  	raise RequestError.new(:db_error, "Database error") unless session[:user].save
    @result = session[:user]
  end

  def index
  	@result = session[:user]
    raise RequestError.new(:not_logged_in, "Not logged in") unless @result
  end

  def login
  	user = User.first login: params['login']
  	raise RequestError.new(:user_not_found, "User not found") unless user
  	raise RequestError.new(:bad_password, "Bad password") unless user.has_password? params['password']
  	session[:user] = user
    @result = user
  end

  def logout
    raise RequestError.new(:not_logged_in, "Not logged in") unless session[:user]
  	session[:user] = nil
    @result = {success: true}
  end
end
