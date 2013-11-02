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
    files = session[:user].x_files.all public: true
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
    @result = { file: file.description, success: true }
  end

  ##
  # Return the list of all shared-files
  def shared
    files_list = []
    files = session[:user].x_files.all(:uuid.not => nil)
    files.each { |file| files_list.push file.description }
    @result = { files: files_list, success: true }
  end

  ##
  # Return the Direct Download Link of the given file
  def link
    file = session[:user].x_files.get params[:id]
    raise RequestError.new(:file_not_found, "File not found") unless file
    file.uuid = SecureRandom::uuid unless file.uuid
    file.save
    @result = { file: file.description, link: "#{BASE_URL}/app_dev.php/fs-file/#{file.uuid}", success: true }
  end

  ##
  # Return all files downloaded at least one time
  def downloaded
    files_list = []
    files = session[:user].x_files.all :downloads.gte => 1
    # files = (files.all(public: true ) | files.all(:uuid.not => nil)) if params[:particular]
    files.each { |file| files_list.push file.description }
    @result = { files: files_list, success: true }
  end

end