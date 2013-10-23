=begin
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

#   need_upload"=>true, 
#   "file"=>{
#   "id"=>1, "name"=>"hello", "last_modification_time"=>"2013-10-21T22:36:08+02:00", 
#   "favorite"=>false, "content_hash"=>"33f3d77fb31aeea699333c3abf63f2c858cbe2898120dd313769471968e1ec08", 
#   "downloads"=>0, "is_public"=>false, "shared"=>false, "read_only"=>false, "user_id"=>1, 
#   "parent_id"=>1, "x_file_id"=>nil, "size"=>8, "part_size"=>5242880
# }

  describe "routing" do 
	  it "should add a file" do
	  	resp = put :put, filename: filename,  content_hash: content_hash, size: fileDataSize
	  	j = JSON.parse resp.body
	  	puts j
	  	j["success"].should be_true
	  	j["need_upload"].should be_true
	  	# test everything
	  end
	end


	 #  it "should add 1 to download counter" do
  #   user = login_user
  #   file1 = user.get_file ["not.mkv"], {create: true}

  #   resp = get :partsync, part: 0, filename: "not.mkv"
  #   #get :download_file, id: file1.id, format: :json
  #   j = JSON.parse resp.body
  #   puts j
  #   j["success"].should be_true

  #   j["downloads"].should == 0
  # end

  # it "should not find file to dl" do
  #   user = login_user
  #   file1 = user.get_file ["not.mkv"], {create: true}

  #   resp = get :download_file, id: 3287, format: :json
  #   j = JSON.parse resp.body
  #   j["success"].should be_false
  # end


end
=end
