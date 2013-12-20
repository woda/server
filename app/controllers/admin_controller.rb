# -*- coding: utf-8 -*-
require 'json'

class AdminController < ApplicationController
  
  # before_filter :require_login
  before_filter :require_admin_user, :except => [:wrong_route]

  before_filter Proc.new { |c| c.check_params :id }, :only => [:delete_user, :delete_file]

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
  # Delete a user
  def delete_user
    user = User.get(params[:id])
    raise RequestError.new(:bad_params, "User does not exist") unless user
    user.delete
    @result = { success: true }
  end

  ##
  # Returns the list of all files
  def files
    files = []
    XFile.all.each { |f| files.push f.description }
    @result = { success: true, file: files }
  end

  ##
  # Returns the list of all files
  def delete_file
    file = XFile.get(params[:id])
    raise RequestError.new(:bad_params, "File does not exist") unless file
    file.delete
    @result = { success: true }
  end

  def wrong_route
    raise RequestError.new(:wrong_route, "Invalid route: bad URL. See documentation for more information")
  end
end
