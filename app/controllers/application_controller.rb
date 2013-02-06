require 'dm-rails/middleware/identity_map'
class ApplicationController < ActionController::Base
  use Rails::DataMapper::Middleware::IdentityMap
  protect_from_forgery

  respond_to :json, :xml

  rescue_from RequestError, :with => :rescue_request_error

  def rescue_request_error expt
    render :json => {error: expt.sym, message: expt.str}, :status => :bad_request
  end

end
