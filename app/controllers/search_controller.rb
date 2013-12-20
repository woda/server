# -*- coding: utf-8 -*-

class SearchController < ApplicationController
  
  before_filter :require_login

  before_filter Proc.new { |c| c.check_params :name}, :only => [:search]

  ##
  # Returns the model, useful for ApplicationController.
  def model
    nil
  end

  ##
  # Create a friend for the current user
  def search
  	name = params[:name]
  	raise RequestError.new(:bad_params, "Search name invalid") if name.nil? || name.empty?

    users = []
    User.all(login: name).each do |user|
      users.push user.description if user != session[:user] && !session[:user].admin?
      users.push user.private_description if user != session[:user] && session[:user].admin?
    end

    private_files = []
    session[:user].x_files.all(name: name).each { |file| private_files.push file.description }
    
    public_files = []
    XFile.all(public: true, name: name).each { |file| public_files.push file.description }

    @result = { success: true, users: users, private_files: private_files, public_files: public_files }
  end
 
end
