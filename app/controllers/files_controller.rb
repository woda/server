# -*- coding: utf-8 -*-
require 'json'

class FilesController < ApplicationController

	before_filter :require_login, :only => [:create_folder]
  before_filter Proc.new { |c| c.check_params :path }, :only => [:create_folder]

	##
  # create a new folder at the given path
  def create_folder
    user = session[:user]
    path = params[:path]

    folder = user.get_folder((path.nil? ? '' : path).split('/'), { create: true } )
    
    @result = folder.description.merge({success: true})
  end

end