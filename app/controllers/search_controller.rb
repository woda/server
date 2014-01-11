# -*- coding: utf-8 -*-

class SearchController < ApplicationController
  include ActionView::Helpers::TextHelper
  
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
	name = sanitize params[:name]
	name = name.gsub "\"", "\\\""
	name = name.gsub "'", "\\'"
	puts "###################################################################### #{name}"
  	raise RequestError.new(:bad_params, "Search name invalid") if name.nil? || name.empty?

    users = []
    User.all(:login.like => "%#{name}%").each do |user|
      users.push user.description if user != session[:user] && !session[:user].admin?
      users.push user.private_description if user != session[:user] && session[:user].admin?
    end

    private_files = []
    session[:user].x_files.all(:name.like => "%#{name}%").each { |file| private_files.push( file.description(session[:user]) ) }
    
    public_files = []
    XFile.all(public: true, :name.like => "%#{name}%").each { |file| public_files.push( file.description(session[:user]) ) }

    @result = { success: true, users: users, private_files: private_files, public_files: public_files }
  end
 
end
