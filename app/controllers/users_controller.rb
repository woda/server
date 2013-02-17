class UsersController < ApplicationController

  before_filter :require_login, :only => [:delete, :update, :index, :logout]
  before_filter :check_create_params, :only => [:create]
  before_filter Proc.new {|c| c.check_params(:password) }, :only => [:create]
  before_filter Proc.new {|c| c.check_update_params :password }, :only => [:update]
  before_filter Proc.new { |c| c.check_params :login, :password }, :only => [:login]

  def model
    User
  end

	def create
	    raise RequestError.new(:login_taken, "Login already taken") if User.first login: params['login']
	    raise RequestError.new(:email_taken, "Email already taken") if User.first email: params['email']
	    user = set_properties User.new
	    user.set_password params['password']
	   user.save
	    session[:user] = user
	    send_confirmation_email
	    @result = user
	end

  def send_confirmation_email
    mail = MailFactory.new
    mail.to = session[:user].email
    mail.from = EMAIL_SETTINGS['user_name']
    mail.subject = 'Welcome to Woda!'
    mail.text = "Welcome to Woda #{session[:user].login}!"
    # TODO: actually send the email!!!!!!!
    # email = EM::P::SmtpClient.send(domain: EMAIL_SETTINGS['domain'],
    #                                host: EMAIL_SETTINGS['address'],
    #                                starttls: true,
    #                                port: EMAIL_SETTINGS['port'],
    #                                auth: {:type => :plain,
    #                                  :username => EMAIL_SETTINGS['user_name'],
    #                                  :password => EMAIL_SETTINGS['password']},
    #                                from: mail.from, to: mail.to,
    #                                content: "#{mail.to_s}\r\n.\r\n",)
    # email.callback { } # TODO: success log
    # email.errback { } # TODO: failure log
  end

  def delete
  	session[:user].destroy
  	session[:user] = nil
    @result = {success: true}
  end

  def update
  	session[:user].set_password params['password'] if params['password']
    set_properties session[:user]
  	session[:user].save
    @result = session[:user]
  end

  def index
  	@result = session[:user]
  end

  def login
  	user = User.first login: params['login']
  	raise RequestError.new(:user_not_found, "User not found") unless user
  	raise RequestError.new(:bad_password, "Bad password") unless user.has_password? params['password']
  	session[:user] = user
    @result = user
  end

  def logout
  	session[:user] = nil
    @result = {success: true}
  end
end
