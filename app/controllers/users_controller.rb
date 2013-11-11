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
    user = set_properties User.new
    user.set_password params[:password]
    user.create_root_folder
    user.save    
    session[:user] = user
    @result = { user: user.description, success: true }
  end
    
  ##
  # Deletes the current user
  def delete
    session[:user].x_files.destroy
    session[:user].destroy
    session[:user] = nil
    @result = { success: true}
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
  # Returns self.
  def index
    @result = { user: session[:user].description, success: true }
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
