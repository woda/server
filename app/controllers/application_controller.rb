# -*- coding: utf-8 -*-
require 'dm-rails/middleware/identity_map'
require 'ostruct'

class Success
  attr_accessor :success

  def initialize b
    @success = b
  end
end

class ApplicationController < ActionController::Base
  use Rails::DataMapper::Middleware::IdentityMap
  if Rails.env.to_sym == :production
#    protect_from_forgery
  end

  respond_to :json, :xml

  rescue_from RequestError, :with => :rescue_request_error
  rescue_from DataMapper::SaveFailureError, :with => :rescue_db_error

  before_filter :cors
  before_filter :get_user
  around_filter :transaction

  def cors
    if (request.headers["Origin"] || request.method == :options)
      headers["Access-Control-Allow-Origin"]  = request.headers["Origin"]
      headers["Access-Control-Allow-Methods"] = %w{GET POST PUT DELETE OPTIONS}.join(",")
      headers['Access-Control-Allow-Credentials'] = 'true'
      headers['Access-Control-Max-Age'] = '1728000'
      headers['Access-Control-Request-Method'] = '*'
      headers["Access-Control-Allow-Headers"] = 'Origin, X-Prototype-Version, X-Requested-With, Content-Type, Accept, Authorization, X-AUTH-TOKEN, X-API-VERSION, X-Custom-Header'
    end
    render :text => '', :content_type => 'text/plain' if request.request_method == "OPTIONS"
  end

  def transaction
    User.transaction do |t|
      @error_occured = false
      yield
      t.rollback if @error_occured
    end
  end

  def get_user
    session[:user] = User.first id: session[:user] if session[:user]
  end

  def render *args, &block
    status = 200
    session[:user] = session[:user].id if session[:user]
    if @result.class == Hash
      if !@result[:success].nil? and !@result[:success]
        status = 500
      end
      @result = OpenStruct.new @result
    end
    if @result.class == Array
      @result = @result.map do |elem|
        (elem.class == Hash) ? OpenStruct.new(elem) : elem
      end
    end
    if @result.class == String
      super text: @result, content_type: 'application/octet-stream'
      return
    end
    super
  end

  def rescue_request_error expt
    @error_occured = true
    render :json => {error: expt.sym, message: expt.str}, :status => :bad_request
  end

  def rescue_db_error expt
    @error_occured = true
    render :json => {error: :db_error, message: expt.to_s + " (" + expt.resource.errors.map { |e| e.to_s }.join(' ') + ")"}
  end

  ##
  # A before action for create CRUD functions: checks that all the necessary
  # members of the model are indeed in the parameters
  def check_create_params
    check_params(*(model.properties.find_all { |p| model.updatable?(p.name) && p.required? }.map(&:name)))
  end

  ##
  # A before action for update CRUD functions: checks that any updatable
  # member of the model is indeed in the parameters
  def check_update_params *args
    check_any_params(*(model.properties.find_all { |p| model.updatable?(p.name) }.map(&:name) + args))
  end

  ##
  # Checks is p (which can be a string or a symbol) is in the request.
  def has_param? p
    params.has_key? p.to_s
  end

  ##
  # Checks whether a set of params is in the request
  def check_params *param
    raise RequestError.new(:missing_params, "Missing parameters, need all of #{param}") unless param.all? { |p| has_param? p }
  end

  ##
  # Checks whether any param of a set of params is in the request
  def check_any_params *param
    raise RequestError.new(:missing_params, "Missing parameters, need any of #{param}") unless param.any? { |p| has_param? p }
  end

  ##
  # Automatically sets the properties of an instance (inst) of the model
  # according to the params.
  def set_properties inst
    model.properties.find_all { |p| model.updatable?(p.name) }.each do |p|
      inst.send("#{p.name}=".to_sym, params[p.name.to_s]) if params.has_key?(p.name.to_s)
    end
    inst
  end

  def require_login
    raise RequestError.new(:not_logged_in, "Not logged in") unless session[:user]
  end

  def require_admin_user
    raise RequestError.new(:bad_access, "You are not allowed to access this part") unless session[:user].admin
  end

end
