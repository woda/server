# -*- coding: utf-8 -*-
require 'json'

class UsersController < ApplicationController
  
  before_filter :require_login, :only => [:delete, :update, :index, :logout, :new_folder, :folder_favorite, :folder_public]
  before_filter :check_create_params, :only => [:create]
  before_filter Proc.new { |c| c.check_params :password }, :only => [:create]
  before_filter Proc.new { |c| c.check_update_params :password }, :only => [:update]
  before_filter Proc.new { |c| c.check_params :login, :password }, :only => [:login]

  before_filter Proc.new { |c| c.check_params :path }, :only => [:create_folder]
  before_filter Proc.new { |c| c.check_params :path, :favorite }, :only => [:folder_favorite]
  before_filter Proc.new { |c| c.check_params :path, :public }, :only => [:folder_public]

  ##
  # Returns the model, useful for ApplicationController.
  def model
    User
  end
  
  ##
  # Create a new user.
  # params: email, first_name, last_name, login, password
  def create
    raise RequestError.new(:login_taken, "Login already taken") if User.first login: params['login']
    raise RequestError.new(:email_taken, "Email already taken") if User.first email: params['email']
    user = set_properties User.new
    user.set_password params['password']
    user.save
    session[:user] = user
    @result = user
  end
    
  def downloaded_files
    user = session[:user]
    
    dpf = []
    files = user.x_files.all :downloads.gte => 1
    files = (files.all(:is_public => true ) | files.all(:shared => true)) if params[:particular]
    files.each do | file |
      f = {id: file.id, name: file.name, last_update: file.last_modification_time, favorite: file.favorite, publicness: file.is_public, shared: file.shared, downloaded: file.downloads}
      dpf.push f
    end

    @result = dpf
  end

  def new_folder
    user = session[:user]
    path = params[:path].split '/'

    f = user.get_folder path, {create: true}
    if !f.nil?
      @result = f.description
      @result["success"] = true
    else
      @result = {success: false, message: "Something wrong happened, did you sent a valid path ?"}
    end
    @result
  end

  def folder_favorite
    user = session[:user]
    path = params[:path].split '/'

    f = user.get_folder path, {create: false}
    if !f.nil?
      f.update favorite: params[:favorite]
      @result = f.description
      @result["success"] = true
    else
      @result = {success: false, message: "Something wrong happened, did you sent a valid path ?"}
    end
    @result
  end

  def folder_public
    user = session[:user]
    path = params[:path].split '/'

    f = user.get_folder path, {create: false}
    if !f.nil?
      f.update public: params[:public]
      @result = f.description
      @result["success"] = true
    else
      @result = {success: false, message: "Something wrong happened, did you sent a valid path ?"} 
    end
  end

  ##
  # Deletes the current user
  def delete
    session[:user].destroy
    session[:user] = nil
    @result = {success: true}
  end
  
  ##
  # Modifies the current user. Takes any of the parameters of create, but not necessarily all.
  def update
    session[:user].set_password params['password'] if params['password']
    set_properties session[:user]
    session[:user].save
    @result = session[:user]
  end
  
  ##
  # Returns self.
  def index
    @result = session[:user]
  end
  
  ##
  # Log in to the server.
  # params: login, password
  def login
    user = User.first login: params['login']
    raise RequestError.new(:user_not_found, "User not found") unless user
    raise RequestError.new(:bad_password, "Bad password") unless user.has_password? params['password']
    session[:user] = user
    @result = user
  end
  
  ##
  # Log out of the server
  def logout
    ret = {success: true}
    session[:user] = nil
    @result = ret
  end
end
