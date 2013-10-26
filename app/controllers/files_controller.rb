# -*- coding: utf-8 -*-
require 'json'

class FilesController < ApplicationController

	before_filter :require_login#, :only => [:create_folder, :files, :recent, :set_favorite, :favorites]
  
  before_filter Proc.new { |c| c.check_params :path }, :only => [:create_folder]
  before_filter Proc.new { |c| c.check_params :id, :favorite }, :only => [:set_favorite]
  before_filter Proc.new { |c| c.check_params :id, :public }, :only => [:set_public]
	before_filter Proc.new { |c| c.check_params :id, :shared }, :only => [:share]

  ##
  # create a new folder at the given path
  def create_folder
    path = params[:path]
    folder = session[:user].get_folder((path.nil? ? '' : path).split('/'), { create: true } )
    @result = folder.description.merge({success: true})
  end

  def files
    aim = params[:folder]
    folder = nil
    # We search the root folder in case this one is not the first in the list
    folder = session[:user].get_folder((aim.nil? ? '' : aim).split('/'))

    unless folder.nil? then
      @result = crawl_folder folder
      @result[:success] = true
    else
      @result[:success] = false
    end
    @result
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
      files_list.push file.description
    end
    folder_infos[:files] = files_list
    folder_infos
  end
  
  ##
  # Get the first 20 last updated files
  def recents
    files = session[:user].x_files.all(:last_modification_time.gte => (DateTime.now - 20.days), limit: 20)

    files_list = []
    files.each do | file |
      files_list.push file.description
    end
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
    files.each do | file |
      files_list.push file.description
    end
    @result = { files: files_list, success: true }
  end

  ##
  # Method which returns user's public files
  def public_files
    public_files = []
    files = session[:user].x_files.all :is_public => true
    files.each do | file |
      public_files.push file.description
    end
    @result = { files: public_files, success: true }
  end
  
  ##
  # Set/Unset a public status file
  def set_public
    file = session[:user].x_files.get params[:id]
    raise RequestError.new(:file_not_found, "File not found") unless file
    file.is_public = params[:public]
    file.save
    @result = { file: file, success: true }
  end

  ##
  # Return the list of all shared-files
  def shared_files
    files_list = []
    files = session[:user].x_files.all shared: true
    files.each do | file |
      files_list.push file.description
    end
    @result = { files: files_list, success: true }
  end

  ##
  # Set/Unset a shared status file
  def share
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
  def downloaded_public_files
    files_list = []
    files = session[:user].x_files.all is_public: true, :downloads.gte => 1
    files.each do | file |
      files_list.push file.description
    end
    @result = { files: files_list, success: true }
  end

  ##
  # Return all the public file downloaded at least one time
  #
  # Useless method
  #
  def downloaded_files
    files_list = []
    files = session[:user].x_files.all :downloads.gte => 1
    files = (files.all(is_public: true ) | files.all(shared: true)) if params[:particular]
    files.each do | file |
      files_list.push file
    end
    @result = { files: files_list, success: true }
  end


end