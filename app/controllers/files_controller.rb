# -*- coding: utf-8 -*-
require 'json'
require 'securerandom'

class FilesController < ApplicationController

	before_filter :require_login
  
  before_filter Proc.new { |c| c.check_params :id, :favorite }, :only => [:set_favorite]
  before_filter Proc.new { |c| c.check_params :id, :public }, :only => [:set_public]

  ##
  # Returns the model, useful for ApplicationController.
  def model
    XFile 
  end

  ##
  # Returns the full list of files and folders
  def list
    xfile = ( params[:id].nil? ? session[:user].x_files.first : session[:user].x_files.get(params[:id]) )
    raise RequestError.new(:folder_not_found, "Folder not found") if xfile.nil?
    if xfile.folder then
      @result =  { folder: crawl_folder(xfile), success: true }
    else  
      @result =  { file: xfile.description, success: true }
    end
  end

  ##
  # Crawl a folder
  def crawl_folder(folder, recur = true)
    list = []
    folders = []
    
    # Folder infos
    folder_infos = folder.description
    folder_infos[:name] = (folder.name.nil? ? "/" : folder.name)

    # We recall craw_folder() method recursively for crawling each child folder if recur = true
    if recur then
      folder.children.each { |child| folders.push(crawl_folder(child)) }
      folder_infos[:folders] = folders
    end
    
    # We get all files from the current folder
    files_list = []
    folder.files.each { |file| files_list.push file.description }
    folder_infos[:files] = files_list
    
    folder_infos
  end

  ##
  # Creates and return a new folder
  def create_folder
    path = (params[:path].nil? ? '' : params[:path]).split('/')
    folder = session[:user].get_folder( path, { create: true } )
    raise RequestError.new(:file_not_found, "Folder not created") if folder.nil?
    @result = { folder: folder.description, success: true }
  end

  ##
  # Deletes a folder
  def delete_folder
    folder = session[:user].x_files.get params[:id]
    raise RequestError.new(:file_not_found, "Folder not found") if folder.nil?
    folder.destroy!
    @result = { success: true }
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
    file = session[:user].x_files.get params[:id]
    raise RequestError.new(:file_not_found, "File not found") unless file
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
    file = session[:user].x_files.get params[:id]
    raise RequestError.new(:file_not_found, "File not found") unless file
    file.uuid = SecureRandom::uuid unless file.uuid
    file.save
    @result = { file: file.description, link: "#{BASE_URL}/app_dev.php/fs-file/#{file.uuid}", success: true }
  end

  ##
  # Returns all files downloaded at least one time
  def downloaded
    files_list = []
    files = session[:user].x_files.all :downloads.gte => 1
    # files = (files.all(public: true ) | files.all(:uuid.not => nil)) if params[:particular]
    files.each { |file| files_list.push file.description }
    @result = { files: files_list, success: true }
  end

end