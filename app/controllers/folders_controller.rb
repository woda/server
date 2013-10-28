# -*- coding: utf-8 -*-
require 'json'

class FoldersController < ApplicationController

	before_filter :require_login
  
  before_filter Proc.new { |c| c.check_params :path }, :only => [:create, :delete]
  before_filter Proc.new { |c| c.check_params :path, :favorite }, :only => [:favorite]
  before_filter Proc.new { |c| c.check_params :path, :public }, :only => [:public]

  ##
  # Returns the model, useful for ApplicationController.
  def model
    Folder 
  end

  ##
  # get user's files
  def list
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
    folder.files.each { |file| files_list.push file.description }
    folder_infos[:files] = files_list
    
    folder_infos
  end

  ##
  # delete the folder at the given path
  def delete
    path = (params[:path].nil? ? '' : params[:path]).split('/')

    folder = session[:user].get_folder( path, { create: true } )
    raise RequestError.new(:file_not_found, "Folder not created") if folder.nil?
    folder.destroy
    @result = { success: true }
  end

  ##
  # create a new folder at the given path
  def create
    path = (params[:path].nil? ? '' : params[:path]).split('/')

    folder = session[:user].get_folder( path, { create: true } )
    raise RequestError.new(:file_not_found, "Folder not created") if folder.nil?
    @result = { folder: folder.description, success: true }
  end

  def favorite
    path = (params[:path].nil? ? '' : params[:path]).split('/')

    folder = session[:user].get_folder( path, {create: false} )
    raise RequestError.new(:file_not_found, "Folder not found") if folder.nil?
    folder.favorite = params[:favorite]
    folder.save
    @result = { folder: folder.description, success: true }
  end

  def public
    path = (params[:path].nil? ? '' : params[:path]).split('/')

    folder = session[:user].get_folder( path, {create: false} )
    raise RequestError.new(:file_not_found, "Folder not found") if folder.nil?  
    folder.public = params[:public]
    folder.save
    @result = { folder: folder.description, success: true }
  end

end