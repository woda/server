# -*- coding: utf-8 -*-
require 'json'
require 'securerandom'

class FilesController < ApplicationController

	before_filter :require_login
  
  before_filter Proc.new { |c| c.check_params :id }, :only => [:breadcrumb]
  before_filter Proc.new { |c| c.check_params :id, :favorite }, :only => [:set_favorite]
  before_filter Proc.new { |c| c.check_params :id, :public }, :only => [:set_public]
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
    if (require_public && params[:id]) then
      raise RequestError.new(:folder_not_public, "Folder is not public") if xfile.folder == true && xfile.public == false
      raise RequestError.new(:folder_not_public, "File is not public") if xfile.folder == false && xfile.public == false
    end
    if xfile.folder then
      @result =  { folder: crawl_folder(xfile, require_public, depth), success: true }
    else  
      @result =  { file: xfile.description, success: true }
    end
  end

  ##
  # Crawl a folder
  def crawl_folder(folder, only_public = false, depth = -1)
    list = []
    folders = []
    depth = -1 if depth < -1

    # Folder infos
    folder_infos = folder.description

    # We recall craw_folder() method recursively for crawling each child folder
    folder.childrens.each do |child|
      if ((only_public == true && child.public == true) || only_public == false) then
        if (depth == -1 || depth > 0)
          # crawl only into the public sub-folders if required OR all of them
          folders.push(crawl_folder(child, only_public, depth - 1))
        else
          # do not recurs at all and just print out the child description
          folders.push(child.description)
        end
      end
    end
    folder_infos[:folders] = folders
    
    # We get all files from the current folder
    files_list = []
    folder.files.each do |file|
      # describe only the public sub-files if required OR all of them
      files_list.push file.description if (only_public == true && file.public == true) || only_public == false
    end
    folder_infos[:files] = files_list
    
    folder_infos
  end

  ##
  # Gets the first 20 last updated files
  def recents
    files = session[:user].x_files.all(:last_update.gte => (DateTime.now - 20.days), folder: false, limit: 20)
    files_list = []
    files.each { |file| files_list.push file.description }
    @result = { files: files_list, success: true }
  end

  ##
  # Sets the file's favorite status based on parameter "favorite"
  def set_favorite
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_param, "Can not set the root folder as favorite") if file.id == session[:user].root_folder.id
    file.favorite = params[:favorite]
    file.save
    @result = { file: file.description, success: true }
  end

  ##
  # Returns all the favorites files
  def favorites
    files_list = []
    files = session[:user].x_files.all favorite: true
    files.each { |file| files_list.push file.description }
    @result = { files: files_list, success: true }
  end

  ##
  # Returns user's public files
  def public
    public_files = []
    files = session[:user].x_files.all public: true
    files.each { |file| public_files.push file.description }
    @result = { files: public_files, success: true }
  end
  
  ##
  # Sets/Unsets a public status file
  def set_public
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_param, "Can not set the root folder as public") if file.id == session[:user].root_folder.id
    file.public = params[:public]
    file.save
    @result = { file: file.description, success: true }
  end

  ##
  # Returns the list of all shared-files
  def shared
    files_list = []
    files = session[:user].x_files.all(:uuid.not => nil)
    files.each { |file| files_list.push file.description }
    @result = { files: files_list, success: true }
  end

  ##
  # Returns the Direct Download Link of the given file
  def link
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_param, "Can not get the download link of the root folder") if file.id == session[:user].root_folder.id

    file.uuid = SecureRandom::uuid unless file.uuid
    file.save
    @result = { file: file.description, link: "#{BASE_URL}/dl/#{file.uuid}", success: true }
  end

  ##
  # Returns all files downloaded at least one time
  def downloaded
    files_list = []
    files = session[:user].x_files.all(:downloads.gte => 1, folder: false)
    # files = (files.all(public: true ) | files.all(:uuid.not => nil)) if params[:particular]
    files.each { |file| files_list.push file.description }
    @result = { files: files_list, success: true }
  end

  ##
  # Move a file or a folder from a source folder to a new destination folder
  def move
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_param, "Can not move the root folder") if file.id == session[:user].root_folder.id
    source = session[:user].x_files.get(params[:source])
    raise RequestError.new(:file_not_found, "Source not found") unless source 
    raise RequestError.new(:bad_param, "Source is not a folder") unless source.folder
    destination = session[:user].x_files.get(params[:destination])
    raise RequestError.new(:file_not_found, "Destination not found") unless destination
    raise RequestError.new(:bad_param, "Destination is not a folder") unless destination.folder
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
    file = WFile.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    raise RequestError.new(:bad_access, "No access") unless file.users.include? session[:user]   

    path = [].push file.description 
    folder = file

    while (folder.id != session[:user].root_folder.id)
      new_parent = nil
      folder.parents.each do |parent|
        new_parent = parent if (parent.users.include? session[:user])
      end
      raise RequestError.new(:db_error, "This file has no parent directory belonging to the current user") if new_parent.nil?
      folder = new_parent
      path.push folder.description if (folder.id != session[:user].root_folder.id)
    end
    path.push folder.description
    path.reverse!
    @result = { success: true, breadcrumb: path }
  end

end
