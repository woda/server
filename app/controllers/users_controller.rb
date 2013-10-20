# -*- coding: utf-8 -*-
require 'json'

class UsersController < ApplicationController
  
  before_filter :require_login, :only => [:delete, :update, :index, :logout, :files, :set_favorite, :recents, :favorites, :public_files, :downloaded_public_files, :set_public, :share, :download_sf, :shared_files, :create_directory]
  before_filter :check_create_params, :only => [:create]
  before_filter Proc.new { |c| c.check_params :password }, :only => [:create]
  before_filter Proc.new { |c| c.check_update_params :password }, :only => [:update]
  before_filter Proc.new { |c| c.check_params :login, :password }, :only => [:login]
  # before_filter Proc.new { |c| c.check_params :folder }, :only => [:files] # Do not make :folder mandatory please, it can not work on the root folder
  before_filter Proc.new { |c| c.check_params :id, :favorite }, :only => [:set_favorite]

  before_filter Proc.new { |c| c.check_params :id, :public }, :only => [:set_public]
  before_filter Proc.new { |c| c.check_params :id, :shared }, :only => [:share]
  before_filter Proc.new { |c| c.check_params :id }, :only => [:download_sf]
  before_filter Proc.new { |c| c.check_params :directory }, :only => [:create_directory]


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
    send_confirmation_email
    @result = user
  end
  
  ##
  # Sends the confirmation email. Currently deactivated.
  def send_confirmation_email
    mail = MailFactory.new
    mail.to = session[:user].email
    mail.from = EMAIL_SETTINGS['user_name']
    mail.subject = 'Welcome to Woda!'
    mail.text = "Welcome to Woda #{session[:user].login}!"
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
  
  ##
  # Method which returns user's public files
  def public_files
    user = session[:user]
    public_files = []
    files = user.x_files.all :is_public => true
    
    files.each do | file |
      f = {id: file.id, name: file.name, updated: file.last_modification_time, favorite: file.favorite, is_public: file.is_public, downloaded: file.downloads}
      public_files.push f
    end
    
    @result = public_files
  end

  ##
  # Method which returns the full user's files list
  def files
    user = session[:user]
    aim = params[:folder]
    folder = nil

    # We search the root folder in case this one is not the first in the list
    folder = user.get_folder((aim.nil? ? '' : aim).split('/'))

    hierarchy = crawl_folder folder unless folder.nil?
    @result = hierarchy ? hierarchy : {}
    @result[:success] = true
  end

  ##
  # Crawl a folder
  def crawl_folder(folder, recur = true)
    list = []
    folders = []
    
    # Folder infos
    folder_infos = {}
    folder_infos[:name] = (folder.name.nil? ? "/" : folder.name)
    folder_infos[:last_update] = folder.last_modification_time
    
    if recur then
      # We recall craw_folder() method recursively for crawling each child folder if recur = true
      folder.children.each do | child |
        folders.push(crawl_folder(child))
      end
      folder_infos[:folders] = folders
    end
    
    files_list = []
    # We get all files from the current folder
    folder.x_files.each do | file |
      file_infos = {}
      
      file_infos[:id] = file.id
      file_infos[:name] = file.name
      file_infos[:type] = File.extname file.name
      file_infos[:last_update] = file.last_modification_time
      file_infos[:favorite] = file.favorite
      file_infos[:publicness] = file.is_public
      file_infos[:size] = file.size
      file_infos[:part_size] = file.part_size
      files_list.push file_infos
    end
    folder_infos[:files] = files_list
    
    folder_infos
  end
  
  ##
  # Get the first 20 last updated files
  def recents
    user = session[:user]
    twenty_days_back = DateTime.now - 20.days
    files = user.x_files.all(:last_modification_time.gte => twenty_days_back, :limit => 20)
    files_list = []
    
    files.each do | file |
      f = {:id => file.id, :name => file.name, :last_update => file.last_modification_time}
      files_list.push f
    end
    
    @result = files_list
  end
  
  ##
  # Set the file's favorite status based on parameter "favorite"
  def set_favorite
    user = session[:user]

    id = params[:id]
    f = user.x_files.get id
    if !f.nil?
      f.update :favorite => (params[:favorite] === true), :last_modification_time => Time.now 
      @result = {success: true, id: f.id, name: f.name, last_update: f.last_modification_time, favorite: f.favorite}
    else
      @result = {success: false}
    end
      @result
  end

  ##
  # Get all the favorites files
  def favorites
    user = session[:user]
    
    files_list = []
    files = user.x_files.all favorite: true
    files.each do | file |
      f = {id: file.id, name: file.name, last_update: file.last_modification_time, favorite: file.favorite}
      files_list.push f
    end
    @result = files_list
  end
  
  ##
  # Set/Unset a public status file
  def set_public
    user = session[:user]
    
    f = user.x_files.get params[:id]
    if !f.nil?
      f.update :is_public => (params[:public] === true), :last_modification_time => Time.now
      @result = {success: true, id: f.id, name: f.name, last_update: f.last_modification_time, publicness: f.is_public}
    else
      @result = {success: false}
    end
  end

  ##
  # Return all the public file downloaded at least one time
  def downloaded_public_files
    user = session[:user]
    dpf = []
    files = user.x_files.all :is_public => true, :downloads.gte => 1
    files.each do | file |
      f = {id: file.id, name: file.name, updated: file.last_modification_time, favorite: file.favorite, is_public: file.is_public, downloaded: file.downloads}
      dpf.push f
    end

    @result = dpf
  end

  ##
  # Set/Unset a shared status file
  def share
    user = session[:user]

    f = user.x_files.get params[:id]
    if !f.nil?
      f.update :shared => params[:shared], :last_modification_time => Time.now
      @result = {success: true, id: f.id, name: f.name, last_modification_time: f.last_modification_time, shared: f.shared}
    else
      @result = {success: false}
    end
  end

  ##
  # When file is downloaded, this method MUST be called ! It add one to the counter
  def download_file
    user = session[:user]

    f = user.x_files.get params[:id]
    if !f.nil?
      sc = f.downloads
      f.update downloads: (sc + 1), :last_modification_time => Time.now
      @result = {success: true, :id => f.id, :name => f.name, :last_modification_time => f.last_modification_time, favorite: f.favorite, publicness: f.is_public, :shared => f.shared, :downloaded => f.downloads}
    else
      @result = {success: false}
    end
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

  ##
  # Return the list of all shared-files
  def shared_files
    user = session[:user]

    files_list = []
    files = user.x_files.all shared: true
    files.each do | file |
      f = {:id => file.id, :name => file.name, :last_modification_time => file.last_modification_time, shared: file.shared, downloaded: file.shared_downloads}
      files_list.push f
    end
    @result = files_list
  end

  def create_directory
    user = session[:user]
    name = params[:directory]
    publicness = params[:public] && params[:public] === true

    folder = Folder.new
    folder.user = user
    folder.name = name
    folder.public = false
    folder.last_modification_time = Time.now
    folder = folder.save
    successness = folder.id ? true : false

    @result = {success: true, id: folder.id, name: folder.name, publicness: folder.public, last_modification_time: folder.last_modification_time} if successness === true
    @result = {success: false} if successness === false
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
