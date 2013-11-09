require 'spec_helper'

# doit être testé
#
# # # # all # # # #
# require_login sauf pour create et login
#
describe UsersController do
  render_views
  DataMapper::Model.raise_on_save_failure = true

  before :all do
    put_description
  end

  before :each do
    db_clear
    
    # Transforme session[:user] avec l'id en instance de User
    get_user
  end

  describe "user creation" do

    it "should be successfull, send back his description, logged him and create his root folder" do

      # On clear la db de tout les users pour etre sur que l'utilisateur créé et le notre seulement
      session[:user] = nil
      User.count.should == 0

      put :create, login: "chainlist", password: "toto42", email: "chain@woda-server.com"

      json = get_json
      
      User.count.should == 1

      json['success'].should be_true
      json['user']['id'].should_not be_nil
      json['user']['login'].should match /chainlist/

      session[:user].should == json['user']['id']
      get_user

      fs = Folder.first user: session[:user], name: '/'
      fs.name.should match '/'
      session[:user].x_files.destroy!
      session[:user].destroy!
    end

    it "should not create user when login already taken" do
      u = create_user({login: "failLogin", email: "failLogin@woda-server.com", password: "failer42"})
      user_count = User.count

      put :create, login: "failLogin", password: "loginfailed", email: "loginfailed@woda-server.com"

      # on vérifie qu'il n'a pas créé l'utilisateur
      User.count.should == user_count
      json = get_json
      json["error"].should match /login_taken/

      u.x_files.destroy!
      u.destroy!
    end

    it "should not create user when email already taken" do
      u = create_user({login: "emailFail", email: "failEmail@woda-server.com", password: "emailFail"})

      user_count = User.count
      ##
      # => On créé un utilisateur avec le même email
      ##
      put :create, login: "emailfailed", password: "emailFail", email: "failEmail@woda-server.com"

      # on vérifie qu'il n'a pas créé l'utilisateur
      User.count.should == user_count

      json = get_json
      json["error"].should match /email_taken/
    end

    it "should not create user when one of params is missing" do
      user_count = User.count

      ##
      # => Sans email
      ##
      put :create, login: 'test', password: 'fail'

      User.count.should == user_count
      json = get_json
      json["error"].should match /missing_params/

      ##
      # => Sans password
      ##
      put :create, login: 'test', email: 'withoutpassword@woda-server.com'

      User.count.should == user_count
      json = get_json
      json["error"].should match /missing_params/
    end
  end
  describe "user deletion" do

    it "should delete user and logged out him" do
      user_count = User.count

      put :create, login: 'deleteuser', password: 'deleted', email: 'deleted@woda-server.com'
      User.count.should == user_count + 1
      userId = session[:user]
      session[:user].should_not be_nil

      delete :delete
      User.count.should == user_count
      json = get_json
      session[:user].should be_nil

      u = User.first id: userId
      u.should be_nil
    end

    it "should delete user and ONLY HIM" do
      user_count = User.count

      put :create, login: 'deleteuser', password: 'deleted', email: 'deleted@woda-server.com'
      put :create, login: 'deleteuser2', password: 'deleted', email: 'deleted2@woda-server.com'

      User.count.should == user_count + 2
      userId = session[:user]
      session[:user].should_not be_nil

      delete :delete
      User.count.should == user_count + 1
      json = get_json
      json["success"].should be_true

      session[:user].should be_nil

      u = User.first id: userId
      u.should be_nil
      u = User.first login: 'deleteuser'
      u.should_not be_nil
      u.destroy!
    end

    it "should be able to recreate same user after deletion" do
      user_count = User.count
      put :create, login: 'recreate', password: 'deleted', email: 'recreate@woda-server.com'
      User.count.should == user_count + 1

      delete :delete
      User.count.should == user_count

      put :create, login: 'recreate', password: 'deleted', email: 'recreate@woda-server.com'
      User.count.should == user_count + 1
      delete :delete
    end

    it "should not be able de relog after deleting" do
      user_count = User.count
      put :create, login: 'relog', password: 'deleted', email: 'relog@woda-server.com'
      User.count.should == user_count + 1

      delete :delete
      User.count.should == user_count

      session[:user].should be_nil

      post :login, login: 'relog', password: 'deleted'
      json = get_json

      json["success"].should be_false
    end

    it "should not delete when not logged" do
      session[:user] = nil
      delete :delete
      json = get_json
      json["success"].should be_false
      json["error"].should match /not_logged_in/
    end

  end

  describe "showing user description" do

    it "should describe user" do
      user_count = User.count
      put :create, login: 'showUser', password: 'deleted', email: 'showUser@woda-server.com'
      User.count.should == user_count + 1        

      session[:user].should_not be_nil

      post :index
      json = get_json

      json["success"].should be_true
      json["user"]["login"].should match /showUser/
      json["user"]["email"].should match /showUser@woda-server.com/
    end

    it "shod not describe user when not logged" do
      post :index
      json = get_json
      json["success"].should be_false
      json["error"].should match /not_logged_in/
    end

  end

  describe "updating user" do

    it "not need all parameters" do

      user_count = User.count
      put :create, login: "updateUser", password: "toto42", email: "updateUser@woda-server.com"
      User.count.should == user_count + 1

      ##
      # => Only login
      ##
      post :update, login: "updatedUser"

      json = json = get_json
      json["success"].should be_true
      json["user"]["login"].should match /updatedUser/

      ##
      # => Only password
      ##
      post :update, password: "toto64"

      post :logout

      post :login, login: "updatedUser", password: "toto64"
      json = json = get_json
      json["success"].should be_true

      ##
      # => Only email
      ##
      post :update, email: "updatedUser@woda-server.com"
      json = json = get_json
      json["success"].should be_true
      json["user"]["email"].should match /updatedUser@woda-server/

      ##
      # => All
      ##
      post :update, login: "CocaCola", password: "Zero", email: "company@woda-server.com"
      # => On vérifie qu'il n'a pas créé de nouveau utilisateur
      User.count.should == user_count + 1
      post :logout
      post :login, login: "CocaCola", password: "Zero"
      json = json = get_json
      json["success"]
      json["user"]["login"].should match /CocaCola/
      json["user"]["email"].should match /company@woda-server.com/
    end

    it "should not update if not logged" do
      session[:user] = nil
      post :update, login: "NotLogged"
      json = get_json
      json["success"].should be_false
      json["error"].should match /not_logged_in/
    end

  end

  describe "login'user" do

    it "should log the user in" do
      u = create_user({login: "LogginUser", email: "logginUser@woda-server.com", password: "login"})

      post :login, login: "LogginUser", password: "login"
      json = get_json
      json["success"].should be_true
      json["user"]["login"].should match /LogginUser/
      json["user"]["email"].should match /logginUser@woda-server.com/
    end

    it "should not log the user if user not found" do
      post :login, login: "UserNotFound", password: "NotFound"
      json = get_json

      json["success"].should be_false
      json["error"].should match /user_not_found/
    end

    it "should not log the user if password is incorrect" do
      u = create_user({login: "PasswordIncorrect", email: "NotLogged@gmail.com", password: "notLogged"})

      post :login, login: "PasswordIncorrect", password: "IsLogged"
      json = get_json
      json["success"].should be_false
      json["error"].match /bad_password/
    end

  end

  describe "login'out user" do

    it "should logout the user" do
      user_count = User.count
      put :create, login: 'LoginOut', password: 'deleted', email: 'loginOut@woda-server.com'
      User.count.should == user_count + 1        

      session[:user].should_not be_nil

      post :logout
      json = get_json
      json["success"].should be_true
      session[:user].should be_nil

      post :index
      json = get_json 
      json["success"].should be_false
      json["error"].should match /not_logged_in/
    end

  end

end