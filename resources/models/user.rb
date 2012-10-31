require 'colorize'
require 'singleton'

class User
  include Singleton

  attr_accessor :logged_as

  def initialize
    @logged_as = "Anonymous".blue
  end

  def set_logged_as(str)
    @logged_as = str
  end
    
end
