# -*- coding: utf-8 -*-
require 'json'

class AdminController < ApplicationController
  
  before_filter Proc.new { |c| raise RequestError.new(:is_production, "Can't use that in production") if Rails.env == 'production' }, only: :cleanup
  
  ##
  # Returns the model, useful for ApplicationController.
  def model
    nil
  end

  def cleanup
    puts XFile.all.destroy
    puts Content.all.destroy
    Storage.clear 'woda-files'
    @result = {success: true}
  end
end
