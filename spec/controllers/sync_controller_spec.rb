require 'spec_helper'

describe SyncController do
	render_views
	DataMapper::Model.raise_on_save_failure = true

	content_hash = "33f3d77fb31aeea699333c3abf63f2c858cbe2898120dd313769471968e1ec08"
	filename = "hello"
	fileDataSize = 8

  before do
    db_clear

		session[:user] = User.new({login: 'lol', last_name: 'delord', first_name: 'kevin', email: 'sac@main.fr'})
		session[:user].set_password 'hello'
    session[:user].save
    session[:user] = session[:user].id
  end

  describe "routing" do 
	  it "should add a file" do
	  	resp = put :put, filename: filename,  content_hash: content_hash, size: fileDataSize
	  	j = JSON.parse resp.body
	  	# puts j
	  	j["success"].should be_true
	  	j["need_upload"].should be_true
	  	# test everything
	  end
	end
=begin


	  it "should add 1 to download counter" do
    user = session[:user]
    file1 = user.get_file ["not.mkv"], {create: true}

    resp = get :partsync, part: 0, filename: "not.mkv"
    #get :download_file, id: file1.id, format: :json
    j = JSON.parse resp.body
    puts j
    j["success"].should be_true

    j["downloads"].should == 0
  end

  it "should not find file to dl" do
    user = session[:user]
    file1 = user.get_file ["not.mkv"], {create: true}

    resp = get :download_file, id: 3287, format: :json
    j = JSON.parse resp.body
    j["success"].should be_false
  end
=end


end

