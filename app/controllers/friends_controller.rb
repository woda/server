# -*- coding: utf-8 -*-

class FriendsController < ApplicationController

  before_filter :require_login

  before_filter Proc.new { |c| c.check_params :id}, :only => [:delete, :create]

  ##
  # Returns the model, useful for ApplicationController.
  def model
    Friend
  end

  ##
  # Create a friend for the current user
  def create
    user = User.get(params[:id])
    raise RequestError.new(:user_not_found, "User not found") unless user
    session[:user].friends.each do |f|
    	raise RequestError.new(:bad_params, "User already in friend list") if f.friend_id == user.id
    end
    friend = Friend.new(user: session[:user], friend_id: user.id)
    friend.save
    @result = { success: true, friend: user.description }
  end

  ##
  # List all the friends
  def list
    friends = []
    session[:user].friends.each do |friend|
    	friends.push User.get(friend.friend_id).description
    end
    @result = { success: true, friends: friends }
  end

  ##
  # Delete a friend for the current user
  def delete
    user = User.get(params[:id])
    raise RequestError.new(:user_not_found, "User not found") unless user
    delete = false
		session[:user].friends.each do |f|
			if f.friend_id == user.id then
				f.destroy! 
				delete = true
			end
  	end
  	raise RequestError.new(:bad_params, "User is not in friend list") unless delete
    @result = { success: true }
  end

end
