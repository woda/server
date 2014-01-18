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
    raise RequestError.new(:bad_params, "User already in friend list") if session[:user].friends.include? user
    
    session[:user].friends << user
    session[:user].save
    user.friendships << session[:user]
    user.save
    @result = { success: true, friend: user.description }
  end

  ##
  # List all the friends
  def list
    friends = []
    session[:user].friends.each do |friend|
    	friends.push friend.description
    end
    @result = { success: true, friends: friends }
  end

  ##
  # List all the friendships
  def list_friendships
    friends = []
    session[:user].friendships.each do |friend|
      friends.push friend.description
    end
    @result = { success: true, friends: friends }
  end

  ##
  # Delete a friend for the current user
  def delete
    user = User.get(params[:id])
    raise RequestError.new(:user_not_found, "User not found") unless user
    raise RequestError.new(:bad_params, "User is not in friend list") unless session[:user].friends.include? user
    Friendship.all(source_id: session[:user].id, target_id: user.id).destroy!
    @result = { success: true }
  end

end
