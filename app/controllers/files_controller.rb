# -*- coding: utf-8 -*-
require 'json'

class FilesController < ApplicationController

	before_filter :require_login, :only => [:create_folder, :files]
  before_filter Proc.new { |c| c.check_params :path }, :only => [:create_folder]

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
  

end