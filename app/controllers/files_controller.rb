# -*- coding: utf-8 -*-
require 'json'

class FilesController < ApplicationController

	before_filter :require_login
  
  before_filter Proc.new { |c| c.check_params :id, :favorite }, :only => [:set_favorite]
  before_filter Proc.new { |c| c.check_params :id, :public }, :only => [:set_public]
	before_filter Proc.new { |c| c.check_params :id, :shared }, :only => [:set_shared]

  ##
  # Returns the model, useful for ApplicationController.
  def model
    XFile 
  end

  ##
  # get user's files
  def files
    aim = params[:folder]
    folder = nil
    # Look for the root folder in case it is not the first in the list
    folder = session[:user].get_folder((aim.nil? ? '' : aim).split('/'))
    raise RequestError.new(:file_not_found, "Folder not found") if folder.nil?
    @result =  { folder: crawl_folder(folder), success: true }
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
    folder.x_files.each { |file| files_list.push file.description }
    folder_infos[:files] = files_list
    
    folder_infos
  end
  
  ##
  # Get the first 20 last updated files
  def recents
    files = session[:user].x_files.all(:last_update.gte => (DateTime.now - 20.days), limit: 20)
    files_list = []
    files.each { |file| files_list.push file.description }
    @result = { files: files_list, success: true }
  end

  ##
  # Set the file's favorite status based on parameter "favorite"
  def set_favorite
    file = session[:user].x_files.get(params[:id])
    raise RequestError.new(:file_not_found, "File not found") unless file
    file.favorite = params[:favorite]
    file.save
    @result = { file: file.description, success: true }
  end

  ##
  # Get all the favorites files
  def favorites
    files_list = []
    files = session[:user].x_files.all favorite: true
    files.each { |file| files_list.push file.description }
    @result = { files: files_list, success: true }
  end

  ##
  # Method which returns user's public files
  def public
    public_files = []
    files = session[:user].x_files.all :public => true
    files.each { |file| public_files.push file.description }
    @result = { files: public_files, success: true }
  end
  
  ##
  # Set/Unset a public status file
  def set_public
    file = session[:user].x_files.get params[:id]
    raise RequestError.new(:file_not_found, "File not found") unless file
    file.public = params[:public]
    file.save
    @result = { file: file, success: true }
  end

  ##
  # Return the list of all shared-files
  def shared
    files_list = []
    files = session[:user].x_files.all shared: true
    files.each { |file| files_list.push file.description }
    @result = { files: files_list, success: true }
  end

  ##
  # Set/Unset a shared status file
  def set_shared
    file = session[:user].x_files.get params[:id]
    raise RequestError.new(:file_not_found, "File not found") unless file
    file.shared = params[:shared]
    file.save
    @result = { file: file, success: true }    
  end

  ##
  # Return all the public file downloaded at least one time
  #
  # Useless method
  #
  def downloaded_public
    files_list = []
    files = session[:user].x_files.all public: true, :downloads.gte => 1
    files.each { |file| files_list.push file.description }
    @result = { files: files_list, success: true }
  end

  ##
  # Return all the public file downloaded at least one time
  #
  # Useless method
  #
  def downloaded
    files_list = []
    files = session[:user].x_files.all :downloads.gte => 1
    files = (files.all(public: true ) | files.all(shared: true)) if params[:particular]
    files.each { |file| files_list.push file }
    @result = { files: files_list, success: true }
  end


end