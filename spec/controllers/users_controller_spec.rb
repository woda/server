require 'spec_helper'

describe UsersController do
  render_views
  DataMapper::Model.raise_on_save_failure = true

  before do
    db_clear
    session[:user] = User.new({login: 'lol', last_name: 'Ecoffet', first_name: 'Adrien', email: 'aec@gmail.com'})
    session[:user].set_password 'hello'
    session[:user].save
  end

  def login_user
    user = session[:user]
    resp = post :login, login: user.login, password: "hello", format: :json
    j = JSON.parse resp.body
    j["login"].should match /lol/
    user
  end

  ## USER MANAGEMENT

  it "should create a user" do
    session[:user] = nil    
    session[:user].should be_nil
    put :create, login: 'lool', last_name: 'Ecoffet', first_name: 'Adrien', email: 'aec@gmal.com', password: 'omg'
    session[:user].should_not be_nil
    User.first(login: 'lool').should_not be_nil
  end

  it "should be able to get user" do
    user = login_user
    resp = get :index, format: :json
    j = JSON.parse(resp.body)
    j["login"].should match /lol/
  end

  it "should allow user login" do
    login_user
  end

  it "should destroy ther user" do 
    user = login_user
    resp = post :delete
    User.first(login: "lol").should be_nil
  end

  it "should update user" do
    user = login_user
    post :update, login: "plop"
    User.first(login: "plop").should_not be_nil
  end

  it "should not allow user login" do    
    user = session[:user]
    resp = post :login, login: user.login, password: "FAIL_PASSWORD"
    j = JSON.parse resp.body
    j["error"].should match /bad_password/
  end

  it "should logout user" do

    # LOGIN
    user = login_user
    
    # NOW LOGOUT
    resp = get :logout, format: :json
    j = JSON.parse resp.body
    j["success"].should be_true
  end

  ## FILE MANAGEMENT

  it "should find file" do
    user = login_user
    file = user.get_file ["Testing.mkv"], {create: true}

    found = user.get_file ["Testing.mkv"]
    found.should_not be_nil
  end

  it "should not find file" do
    user = login_user

    lambda { 
        user.get_file( ["Testing.mkv"], {create: false})
      }.should raise_error
  end

  it "should should list files" do
    user = login_user

    file = user.get_file ["Testing.mkv"], {create: true}

    resp = get :files, format: :json
    j = JSON.parse resp.body
    j["success"].should be_true
    j["files"][0]["name"].should match /Testing.mkv/
  end

  it "should list files but with empty hash" do
    user = login_user

    resp = get :files, format: :json
    j = JSON.parse resp.body
    j["success"].should be_true
    j["files"].length.should == 0
  end

  it "should allow listing recent file (last 20 days modified files)" do
    user = login_user

    file = user.get_file ["Testing.mkv"], {create: true}
    file.last_modification_time = DateTime.now - 42.days
    file.save

    file = user.get_file ["Recent.mkv"], {create: true}

    resp = get :recents, format: :json
    j = JSON.parse resp.body
    j.length.should == 1    
    j[0]["name"].should match /Recent.mkv/
  end

  it "should allow listing recent file but with empty list" do
    user = login_user

    file = user.get_file ["Testing.mkv"], {create: true}
    file.last_modification_time = DateTime.now - 42.days
    file.save

    resp = get :recents, format: :json
    j = JSON.parse resp.body
    j.length.should == 0
  end

  it "should favorite a file" do 
    user = login_user

    file = user.get_file ["Testing.mkv"], {create: true}

    resp = get :set_favorite, id: file.id, favorite: true, format: :json
    j = JSON.parse resp.body
    j["success"].should be_true
    j["favorite"].should be_true
  end


  it "should unset favorite a file" do 
    user = login_user

    file = user.get_file ["Testing.mkv"], {create: true}

    resp = get :set_favorite, id: file.id, favorite: true, format: :json
    j = JSON.parse resp.body
    j["success"].should be_true
    j["favorite"].should be_true

    resp = get :set_favorite, id: file.id, favorite: false, format: :json
    j = JSON.parse resp.body
    j["success"].should be_true
    j["favorite"].should be_false
  end

  it "should not find file" do
    user = login_user

    file = user.get_file ["Testing.mkv"], {create: true}

    resp = get :set_favorite, id: 42, favorite: true, format: :json
    
    j = JSON.parse resp.body
    j["success"].should be_false
  end

  it "should list favorites files" do
    user = login_user
    file1 = user.get_file ["Favorite.mkv"], {create: true}
    file2 = user.get_file ["Favorite_2.mkv"], {create: true}
    file3 = user.get_file ["NotFavorite.mkv"], {create: true}
    file4 = user.get_file ["NotFavorite_2.mkv"], {create: true}
    
    resp = get :set_favorite, id: file1.id, favorite: true, format: :json
    resp = get :set_favorite, id: file2.id, favorite: true, format: :json
   
    resp = get :favorites, format: :json

    j = JSON.parse resp.body
    j.length.should == 2
  end

  it "should not list favorites file after unsetting favorite" do
    user = login_user
    file = user.get_file ["Favorite.mkv"], {create: true}
    
    resp = get :set_favorite, id: file.id, favorite: true, format: :json
    j = JSON.parse resp.body
    j["favorite"].should be_true

    resp = get :set_favorite, id: file.id, favorite: false, format: :json
    j = JSON.parse resp.body
    j["favorite"].should be_false

    resp = get :favorites, format: :json

    j = JSON.parse resp.body
    j.length.should == 0
  end

  it "should set file to public" do
    user = login_user
    file = user.get_file ["Public.mkv"], {create: true}

    resp = get :set_public, id: file.id, :public => true, format: :json
    j = JSON.parse resp.body

    j["success"].should be_true
    j["publicness"].should be_true
  end

  it "should set file publicness to false" do
    user = login_user
    file = user.get_file ["Public.mkv"], {create: true}

    resp = get :set_public, id: file.id, :public => true, format: :json
    j = JSON.parse resp.body
    j["publicness"].should be_true

    resp = get :set_public, id: file.id, :public => false, format: :json
    j = JSON.parse resp.body
    j["publicness"].should be_false
  end

  it "should get public_files" do
    user = login_user
    file1 = user.get_file ["Public1.mkv"], {create: true}
    file2 = user.get_file ["Public2.mkv"], {create: true}
    file3 = user.get_file ["NotPublic1.mkv"], {create: true}
    file4 = user.get_file ["NotPublic2.mkv"], {create: true}

    resp = get :set_public, id: file1.id, :public => true, format: :json
    j = JSON.parse resp.body
    j["publicness"].should be_true

    resp = get :set_public, id: file2.id, :public => true, format: :json
    j = JSON.parse resp.body
    j["publicness"].should be_true

    resp = get :public_files, format: :json
    j = JSON.parse resp.body
    j.length.should == 2
  end

  it "should get public_files with empty list" do
    user = login_user
    file = user.get_file ["NotPublic.mkv"], {create: true}

    resp = get :public_files, format: :json
    j = JSON.parse resp.body
    j.length.should == 0
  end
  
  it "should get public_files with empty list after unsetting publicness" do
    user = login_user
    file = user.get_file ["Public.mkv"], {create: true}

    resp = get :set_public, id: file.id, :public => true, format: :json
    j = JSON.parse resp.body
    j["publicness"].should be_true

    resp = get :set_public, id: file.id, :public => false, format: :json
    j = JSON.parse resp.body
    j["publicness"].should be_false

    resp = get :public_files, format: :json
    j = JSON.parse resp.body
    j.length.should == 0
  end

  it "should share a file" do
    user = login_user
    file = user.get_file ["Shared.mkv"], {create: true}

    resp = post :share, id: file.id, :shared => true, format: :json
    j = JSON.parse resp.body
    j["success"].should be_true
    j["shared"].should be_true
  end

  it "should unset shared file" do
    user = login_user
    file = user.get_file ["Shared.mkv"], {create: true}

    resp = post :share, id: file.id, :shared => true, format: :json
    j = JSON.parse resp.body
    j["shared"].should be_true

    resp = post :share, id: file.id, :shared => false, format: :json
    j = JSON.parse resp.body
    j["shared"].should be_false
  end

  it "should not find file to share" do
    user = login_user
    file = user.get_file ["Public.mkv"], {create: true}

    resp = get :share, id: 4932, :shared => true, format: :json
    j = JSON.parse resp.body
    j["success"].should be_false
  end

  it "should get all downloaded files" do
    user = login_user
    file1 = user.get_file ["not.mkv"], {create: true}
    file2 = user.get_file ["not2.mkv"], {create: true}
    file3 = user.get_file ["downloaded1.mkv"], {create: true}
    file4 = user.get_file ["downloaded2.mkv"], {create: true}

    file4.update :downloads => 1
    file3.update :downloads => 1
    
    resp = get :downloaded_files, format: :json
    j = JSON.parse resp.body
    j.length.should == 2
  end

  it "should get all  public/shared downloaded files" do
    user = login_user
    file1 = user.get_file ["not.mkv"], {create: true}
    file2 = user.get_file ["downloadShare.mkv"], {create: true}
    file3 = user.get_file ["downloaded1Public.mkv"], {create: true}
    file4 = user.get_file ["downloaded2.mkv"], {create: true}
    file5 = user.get_file ["downloadedBOTH.mkv"], {create: true}


    resp = get :share, id: file2.id, shared: true, format: :json
    j = JSON.parse resp.body
    j["shared"].should be_true
    file2.update :downloads => 1


    resp = get :set_public, id: file3.id, :public => true, format: :json
    j = JSON.parse resp.body
    j["publicness"].should be_true
    file3.update :downloads => 1

    resp = get :set_public, id: file5.id, :public => true, format: :json
    j = JSON.parse resp.body
    j["publicness"].should be_true
    resp = get :share, id: file5.id, :shared => true, format: :json
    j = JSON.parse resp.body
    j["shared"].should be_true

    file5.update :downloads => 1
    file4.update :downloads => 1

    resp = get :downloaded_files, format: :json
    j = JSON.parse resp.body
    j.length.should == 4

    resp = get :downloaded_files, particular: true, format: :json
    j = JSON.parse resp.body
    j.length.should == 3
  end
  
=begin

  it "should create a new folder" do
    user = login_user

    resp = put :new_folder, :path => "Bonjour"
    j = JSON.parse resp.body
    j["id"].should_not be_nil
    j["name"].should match /Bonjour/
  end
=end

end
