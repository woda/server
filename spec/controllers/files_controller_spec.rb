=begin
require 'spec_helper'

describe FilesController do
	render_views
	DataMapper::Model.raise_on_save_failure = true

	# content_hash = "33f3d77fb31aeea699333c3abf63f2c858cbe2898120dd313769471968e1ec08"
	# filename = "hello"
	# fileDataSize = 8

  before do
    db_clear

		session[:user] = User.new({login: 'lol', last_name: 'delord', first_name: 'kevin', email: 'sac@main.fr'})
		session[:user].set_password 'hello'
    session[:user].save
    session[:user] = session[:user].id
  end


  describe "routing" do 
	  it "should create a directory" do
	  	resp = put :create_folder, path: '/lol/mdr'
	  	j = JSON.parse resp.body
	  	puts j
	  	j["success"].should be_true

      resp = get :files, format: :json
      j = JSON.parse resp.body
      puts j

	  	# test everything
	  end
	end

end
=end
