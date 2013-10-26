# -*- coding: utf-8 -*-
require 'json'

class FilesController < ApplicationController

	before_filter :require_login#, :only => [:create_folder, :files, :recent, :set_favorite, :favorites]
  
  before_filter Proc.new { |c| c.check_params :path }, :only => [:create_folder]
  before_filter Proc.new { |c| c.check_params :id, :favorite }, :only => [:set_favorite]
	
  ##
  # create a new folder at the given path
  def create_folder
    user = session[:user]
    path = params[:path]

    folder = user.get_folder((path.nil? ? '' : path).split('/'), { create: true } )
    
    @result = folder.description.merge({success: true})
  end

  def files
    user = session[:user]
    aim = params[:folder]
    folder = nil

    # We search the root folder in case this one is not the first in the list
    folder = user.get_folder((aim.nil? ? '' : aim).split('/'))

    #TODO change that it's stupid
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
      files_list.push file.description
    end
    folder_infos[:files] = files_list
    
    folder_infos
  end
  
  ##
  # Get the first 20 last updated files
  def recent
    user = session[:user]
    twenty_days_back = DateTime.now - 20.days
    files = user.x_files.all(:last_modification_time.gte => twenty_days_back, :limit => 20)
    files_list = []
    
    files.each do | file |
      files_list.push file.description
    end
    @result = files_list
  end

  ##
  # Set the file's favorite status based on parameter "favorite"
  def set_favorite
    user = session[:user]

    file = user.x_files.get(params[:id])
    if !file.nil?
      file.favorite = params[:favorite]
      file.save
      @result = file.description
      @result[:success] = true
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
      files_list.push file.description
    end
    @result = files_list
  end

end