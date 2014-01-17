# -*- coding: utf-8 -*-
require 'json'

class FilesController < ApplicationController

	before_filter :require_login
  
  before_filter Proc.new { |c| c.check_params :id }, :only => [:breadcrumb, :link, :unshare]
  before_filter Proc.new { |c| c.check_params :id, :favorite }, :only => [:set_favorite]
  before_filter Proc.new { |c| c.check_params :id, :public }, :only => [:set_public]
  before_filter Proc.new { |c| c.check_params :id, :login }, :only => [:share]
  before_filter Proc.new { |c| c.check_params :id, :source, :destination}, :only => [:move]

  ##
  # Returns the model, useful for ApplicationController.
  def model
    XFile 
  end

  ##
  # Returns the full list of files and folders
  def list
    require_public = ( params[:user].nil? ? false : true )
    user = ( params[:user].nil? ? session[:user] : User.first(id: params[:user]) )
    raise RequestError.new(:bad_params, "User does not exist") unless user
    raise RequestError.new(:bad_params, "Depth not valid") if params[:depth].to_i < 0
    depth = (params[:depth] ? params[:depth].to_i : -1)
    xfile = ( params[:id].nil? ? user.root_folder : WFolder.get(params[:id]) )
    raise RequestError.new(:internal_error, "No root directory. Please contact your administrator") if xfile.nil? && params[:id].nil?
    raise RequestError.new(:folder_not_found, "File or folder not found") if xfile.nil?
    if (require_public && params[:id] && session[:user].admin == false) then
      raise RequestError.new(:folder_not_public, "Folder is not public") if xfile.folder == true && xfile.public == false
      raise RequestError.new(:folder_not_public, "File is not public") if xfile.folder == false && xfile.public == false
    end
    if xfile.folder then
      @result =  { folder: crawl_folder(xfile, require_public, depth), success: true }
    else  
      @result =  { file: xfile.description(session[:user]) , success: true }
    end
  end

  ##
  # Crawl a folder
  def crawl_folder(folder, only_public = false, depth = -1)
    list = []
    folders = []
    depth = -1 if depth < -1

    # Folder infos
    folder_infos = folder.description(session[:user])

    # We recall craw_folder() method recursively for crawling each child folder
    folder.childrens.each do |child|
      if (((only_public == true && child.public == true) || only_public == false) || session[:user].admin) then
        if (depth == -1 || depth > 0)
          # crawl only into the public sub-folders if required OR all of them
          folders.push(crawl_folder(child, only_public, depth - 1))
        else
          # do not recurs at all and just print out the child description
          folders.push(child.description(session[:user]))
        end
      end
    end
    folder_infos[:folders] = folders
    
    # We get all files from the current folder
    files_list = []
    folder.files.each do |file|
      # describe only the public sub-files if required OR all of them
      if (((only_public == true && file.public == true) || only_public == false) || session[:user].admin) then
        files_list.push(file.description(session[:user]))
      end
    end
    folder_infos[:files] = files_list
    
    folder_infos
  end

  ##
  # Gets the first 20 last updated files
  def recents
    files = session[:user].x_files.all(:last_update.gte => (DateTime.now - 20.days), folder: false, limit: 20)
    files_list = []
    files.each { |file| files_list.push(file.description(session[:user])) }
    @result = { files: files_list, success: true }
  end

  ##
  # Sets the file's favorite status based on parameter "favorite"
  def set_favorite
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_param, "Can not set the root folder as favorite") if file.id == session[:user].root_folder.id

    if params[:favorite] == "true" then 
      file.favorite_users << session[:user]
    elsif params[:favorite] == "false" then
      file.favorite_users.delete session[:user]
    end
    
    file.save

    @result = { file: file.description(session[:user]), success: true }
  end

  ##
  # Returns all the favorites files
  def favorites
    files = []
    session[:user].favorite_files.each do |file|
      files.push(file.description(session[:user]))
    end
    @result = { files: files, success: true }
  end

  ##
  # Returns user's public files
  def public
    public_files = []
    files = session[:user].x_files.all public: true
    files.each { |file| public_files.push(file.description(session[:user])) }
    @result = { files: public_files, success: true }
  end
  
  ##
  # Sets/Unsets a public status file
  def set_public
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_param, "Can not set the root folder as public") if file.id == session[:user].root_folder.id
    raise RequestError.new(:bad_param, "Can not set a synchronized file as public") if file.user != session[:user]
    file.public = true if params[:public] == "true"
    file.public = false if params[:public] == "false"
    file.save
    @result = { file: file.description(session[:user]), success: true }
  end

  ##
  # Share a file to another user
  def share
    login = params[:login]
    raise RequestError.new(:bad_param, "Wrong login") if login.nil? || login.length == 0
    user = User.all(login: login).first
    raise RequestError.new(:bad_param, "User not found") if user.nil?
    file = WFile.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No access") unless file.users.include? session[:user]
    raise RequestError.new(:bad_param, "File not uploaded") unless file.uploaded
    raise RequestError.new(:bad_param, "Can not share the root folder") if file.id == session[:user].root_folder.id
    raise RequestError.new(:bad_part, "Incorrect content") if file.content.nil?

    file = WFile.share_to_user(user, file)
    file.update_and_save
    @result = { success: true, file: file.description(session[:user]), user: user.description }
    session[:user].save
  end

  ##
  # Share a file to another user
  def unshare
    file = session[:user].x_files_shared_to_me.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file

    file = WFile.unshare_to_user(user, file)
    file.update_and_save
    @result = { success: true }
    session[:user].save
  end

  ##
  # Returns the list of all files shared BY the user
  # if an id is specified the file's description and all its users
  def shared_by_me
    if !params[:id] then
      files_list = []
      files = session[:user].x_files_shared_by_me.all
      files.each { |file| files_list.push(file.description(session[:user])) }
      @result = { files: files_list, success: true }
    else
      file = WFile.get(params[:id])
      raise RequestError.new(:file_not_found, "File not found") unless file
      raise RequestError.new(:bad_access, "No access") unless file.users.include? session[:user]
      
      users = []
      file.users.each { |user| users.push user.description }
      @result = { success: true, file: file.description(session[:user]), users: users }
    end
  end

  ##
  # Returns the list of all files shared TO the user
  # if an id is specified the file's description and all its users
  def shared_to_me
    files_list = []
    files = session[:user].x_files_shared_to_me.all
    files.each { |file| files_list.push( { owner: file.user.description, file: file.description(session[:user]) } ) }
    @result = { files: files_list, success: true }
  end

  ##
  # Returns the Direct Download Link of the given file
  def link
    file = session[:user].x_files.get(params[:id])
    file = XFile.first(id: params[:id], public: true) unless file

    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_param, "File not uploaded") unless file.uploaded
    raise RequestError.new(:bad_param, "Can not get the download link of the root folder") if file.id == session[:user].root_folder.id
    raise RequestError.new(:bad_param, "Can't get the link of a folder") if file.folder

    file.generate_link
    @result = { link: file.link, uuid: file.uuid, success: true }
  end

  ##
  # Returns the list of the links shared by the user
  def mylinks
    files_list = []
    files = session[:user].x_files.all(:uuid.not => nil)
    files.each { |file| files_list.push(file.description(session[:user])) }
    @result = { files: files_list, success: true }
  end

  ##
  # Returns all files downloaded at least one time
  def downloaded
    files_list = []
    files = session[:user].x_files.all(:downloads.gte => 1)
    # files = (files.all(public: true ) | files.all(:uuid.not => nil)) if params[:particular]
    files.each { |file| files_list.push(file.description(session[:user])) }
    @result = { files: files_list, success: true }
  end

  ##
  # Move a file or a folder from a source folder to a new destination folder
  def move
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_param, "Can not move the root folder") if file.id == session[:user].root_folder.id
    source = WFolder.get(params[:source])
    raise RequestError.new(:file_not_found, "Source not found") unless source
    raise RequestError.new(:bad_param, "Source is not a folder") unless source.folder
    raise RequestError.new(:bad_access, "No access to the source folder") unless source.users.include? session[:user]   
    raise RequestError.new(:bad_param, "Source does not contain the file") if source.files.include? file == false && !file.folder
    raise RequestError.new(:bad_param, "Source does not contain the folder") if source.childrens.include? file && file.folder
    destination = WFolder.get(params[:destination])
    raise RequestError.new(:file_not_found, "Destination not found") unless destination
    raise RequestError.new(:bad_param, "Destination is not a folder") unless destination.folder
    raise RequestError.new(:bad_access, "No access to the destination folder") unless destination.users.include? session[:user] 
    raise RequestError.new(:bad_param, "Destination and Source are identical") if source.id == destination.id
    raise RequestError.new(:bad_param, "Destination and File are identical") if file.id == destination.id
    raise RequestError.new(:bad_param, "File and Source are identical") if source.id == file.id

    WFile.move(file, source, destination) unless file.folder
    WFolder.move(file, source, destination) if file.folder

    @result = { success: true }
  end

  ##
  # Get the path/breadcrum of a file or a folder
  def breadcrumb
    file = WFolder.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No access") unless file.users.include? session[:user]   

    file = WFile.get(params[:id]) unless file.folder?

    path = []
    folder = file

    while (folder.id != session[:user].root_folder.id)
      new_parent = folder.parents.first(user: session[:user])
      raise RequestError.new(:db_error, "This file has no parent directory belonging to the current user") if new_parent.nil?
      path.push(new_parent.description(session[:user])) if (new_parent.id != session[:user].root_folder.id)
      folder = new_parent
    end
    path.push(folder.description(session[:user]))
    path.reverse!
    path.push(file.description(session[:user])) unless path.include? file.description(session[:user])
    @result = { success: true, breadcrumb: path }
  end

  ##
  # Method to get the timestamp of the last modification of the user's file list
  def last_update
    folder = ( params[:id].nil? ? session[:user].root_folder : XFile.get(params[:id]) )
    raise RequestError.new(:file_not_found, "Folder not found") if folder.nil?
    raise RequestError.new(:bad_access, "No access") unless folder.users.include? session[:user]   
    @result =  { last_update: folder.last_update, success: true }
  end

end
