# -*- coding: utf-8 -*-
require 'json'

class AdminController < ApplicationController
  
  # before_filter :require_login
  before_filter :require_admin_user, :except => [:wrong_route]

  before_filter Proc.new { |c| c.check_params :id }, :only => [:delete_user, :delete_file]
  before_filter Proc.new { |c| c.check_params :id, :space }, :only => [:update_user_space]

  ##
  # Returns the model, useful for ApplicationController.
  def model
    nil
  end

  ##
  # Returns the list of all users
  def users
    users = []
    User.all.each { |u| users.push u.private_description }
    @result = { success: true, users: users }
  end

  ##
  # Update the available space for a specific user
  def update_user_space
    user = User.get(params[:id])
    raise RequestError.new(:bad_params, "User does not exist") unless user
    raise RequestError.new(:bad_params, "Invalid new available space") if params[:space].to_i <= 0
    user.space = params[:space].to_i
    user.save
    @result = { success: true }
  end

  ##
  # Delete a user
  def delete_user
    user = User.get(params[:id])
    raise RequestError.new(:bad_params, "User does not exist") unless user
    user.delete
    @result = { success: true }
  end

  ##
  # Returns the list of all-or-one file(s)
  def files
    if params[:id] then
      file = XFile.get(params[:id])
      raise RequestError.new(:bad_params, "File does not exist") unless file
      @result = { success: true, file: file.description }
    else
      files = []
      XFile.all.each { |f| files.push f.description }
      @result = { success: true, files: files }
    end
  end

  ##
  # Returns the list of all files
  def delete_file
    file = WFile.get(params[:id])
    raise RequestError.new(:bad_params, "File does not exist") unless file
    raise RequestError.new(:bad_param, "Can't delete a root folder") if file.id == file.user.root_folder.id
    (file.folder ? WFolder.get(params[:id]) : file).update_and_delete file.user
    @result = { success: true }
  end

  def wrong_route
    raise RequestError.new(:wrong_route, "Invalid route: bad URL. See documentation for more information")
  end
end
