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
  # delete the folder at the given path
  def delete
    # path = params[:path]
    path = (params[:path].nil? ? '' : params[:path]).split('/')

    folder = session[:user].get_folder( path, { create: true } )
    raise RequestError.new(:file_not_found, "Folder not created") if folder.nil?
    folder.destroy
    @result = { success: true }
  end

  ##
  # create a new folder at the given path
  def create
    # path = params[:path]
    path = (params[:path].nil? ? '' : params[:path]).split('/')

    folder = session[:user].get_folder( path, { create: true } )
    raise RequestError.new(:file_not_found, "Folder not created") if folder.nil?
    @result = { folder: folder.description, success: true }
  end

  def favorite
    # path = params[:path].split '/'
    path = (params[:path].nil? ? '' : params[:path]).split('/')

    folder = session[:user].get_folder( path, {create: false} )
    raise RequestError.new(:file_not_found, "Folder not found") if folder.nil?
    folder.favorite = params[:favorite]
    folder.save
    @result = { folder: folder.description, success: true }
  end

  def public
    # path = params[:path].split '/'
    path = (params[:path].nil? ? '' : params[:path]).split('/')

    folder = session[:user].get_folder( path, {create: false} )
    raise RequestError.new(:file_not_found, "Folder not found") if folder.nil?  
    folder.public = params[:public]
    folder.save
    @result = { folder: folder.description, success: true }
  end

end