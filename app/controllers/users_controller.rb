# -*- coding: utf-8 -*-
require 'json'

class UsersController < ApplicationController
  
  before_filter :require_login, :only => [:delete, :update, :index, :logout]
  before_filter :check_create_params, :only => [:create]
  before_filter Proc.new { |c| c.check_params :password }, :only => [:create]
  before_filter Proc.new { |c| c.check_update_params :password }, :only => [:update]
  before_filter Proc.new { |c| c.check_params :login, :password }, :only => [:login]

  ##
  # Returns the model, useful for ApplicationController.
  def model
    User
  end
  
  ##
  # Create a new user.
  # params: email, login, password
  def create
    raise RequestError.new(:login_taken, "Login already taken") if User.first login: params[:login]
    raise RequestError.new(:email_taken, "Email already taken") if User.first email: params[:email]
    raise RequestError.new(:wrong_email, "Invalid email") unless params[:email].match(/\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/)
    raise RequestError.new(:wrong_password, "Invalid password: must contains at least 6 letters") unless params[:password].match(/^(?=.*[a-zA-Z0-9&é"'(§è!çà^$€%ù£`):;.,=+-_]).{6,}$/)

    user = set_properties User.new
    user.set_password params[:password]
    # create_root save the user
    WFolder.create_root user
    session[:user] = user
    @result = { user: user.description, success: true }
  end
    
  ##
  # Deletes the current user
  def delete
    session[:user].delete
    session[:user] = nil
    @result = { success: true }
  end
  
  ##
  # Modifies the current user. Takes any of the parameters of create, but not necessarily all.
  def update
    session[:user].set_password params[:password] if params[:password]
    set_properties session[:user]
    session[:user].save
    @result = { user: session[:user].description, success: true }
  end
  
  ##
  # Returns self or another user if required
  def index
    user = session[:user]
    user = User.first(id: params[:id]) if params[:id]
    raise RequestError.new(:bad_params, "User does not exist") unless user
    @result = { user: user.description, success: true }
  end
  
  ##
  # Log in to the server.
  # params: login, password
  def login
    user = User.first login: params[:login]
    raise RequestError.new(:user_not_found, "User not found") unless user
    raise RequestError.new(:bad_password, "Bad password") unless user.has_password? params[:password]
    session[:user] = user
    @result = { user: user.description, success: true }
  end
  
  ##
  # Log out of the server
  def logout
    session[:user] = nil
    @result = { success: true }
  end
end
