# -*- coding: utf-8 -*-
require 'json'

class FilesController < ApplicationController

  # match 'folders/:path' => 'folders#new', via: :post
  # match 'folders/favorite/:path' => 'folders#favorite', via: :post
  # match 'folders/public/:path' => 'folders#public', via: :post


	before_filter :require_login#, :only => [:create, :new, :favorite, :public]
  
  before_filter Proc.new { |c| c.check_params :path }, :only => [:new] #[:create]
  before_filter Proc.new { |c| c.check_params :path, :favorite }, :only => [:favorite]
  before_filter Proc.new { |c| c.check_params :path, :public }, :only => [:public]

  ##
  # create a new folder at the given path
  def create
    path = params[:path]
    folder = session[:user].get_folder((path.nil? ? '' : path).split('/'), { create: true } )
    @result = folder.description.merge({success: true})
  end

  def new
    user = session[:user]
    path = params[:path].split '/'

    f = user.get_folder path, {create: true}
    if !f.nil?
      @result = f.description
      @result["success"] = true
    else
      @result = {success: false, message: "Something wrong happened, did you sent a valid path ?"}
    end
    @result
  end

  def favorite
    user = session[:user]
    path = params[:path].split '/'

    f = user.get_folder path, {create: false}
    if !f.nil?
      f.update favorite: params[:favorite]
      @result = f.description
      @result["success"] = true
    else
      @result = {success: false, message: "Something wrong happened, did you sent a valid path ?"}
    end
    @result
  end

  def public
    user = session[:user]
    path = params[:path].split '/'

    f = user.get_folder path, {create: false}
    if !f.nil?
      f.update public: params[:public]
      @result = f.description
      @result["success"] = true
    else
      @result = {success: false, message: "Something wrong happened, did you sent a valid path ?"} 
    end
  end


end