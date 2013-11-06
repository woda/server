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

end
