require 'spec_helper'

##
##
## /!\ To call a method from the controller without using REST method (PUT, DELETE, POST...)
## rspec create a "subject" object you can use for that purpose.
## ex: Logout => subject.logout call the logout method from UsersController
## Kevin.G ( Sorry for my bad english :P )
##
##


describe UsersController do

  before do
    db_clear
    session[:user] = User.new({login: 'lol', last_name: 'Ecoffet', first_name: 'Adrien', email: 'aec@gmail.com'})
    session[:user].set_password 'hello'
    session[:user].save
    @controller = UsersController.new
  end

  def login_user
    user = session[:user]
    resp = post :login, login: user.login, password: "hello"
    resp.message.should match /OK/
    user
  end

  it "should allow file listing" do
    user = login_user
    resp = post :files
  end

  it "should allow listing recent file" do
    user = login_user
    resp = post :recents
  end

  it "should allow listing favorites file" do
    user = login_user
    resp = post :favorites
  end

  it "should favorite a file -> File not found" do 
    user = login_user
    resp = post :favorites, id: 42
  end

  it "should create a user" do
    session[:user] = nil    
    session[:user].should be_nil
    put :create, login: 'lool', last_name: 'Ecoffet', first_name: 'Adrien', email: 'aec@gmal.com', password: 'omg'
    session[:user].should_not be_nil
    User.first(login: 'lool').should_not be_nil
  end

  it "should fail with the right errors in the right cases when creating" do
    # # Missing parameters
    # lambda { @controller.create }.should raise_error

  #   # Double login
  #   u = User.new login: "test", email: 'a@host.com', first_name: 'ok', last_name: 'ok'
  #   u.set_password "lol"
  #   u.save.should be
  #   @controller.params['login'] = 'test'
  #   @controller.params['password'] = 'a'
  #   @controller.params['email'] = 'b@host.com'
  #   @controller.params['first_name'] = 'hute'
  #   @controller.params['last_name'] = 'uhe'
  #   lambda { @controller.create }.should raise_error

  #   # Double email
  #   @controller.params['login'] = 'abc'
  #   @controller.params['password'] = 'a'
  #   @controller.params['email'] = 'a@host.com'
  #   @controller.params['first_name'] = 'hute'
  #   @controller.params['last_name'] = 'uhe'
  #   lambda { @controller.create }.should raise_error

  #   # If save returns false
  #   @controller.params['email'] = 'ht@host.com'
  #   User.any_instance.stub(:save).and_return(false)
  #   lambda { @controller.create }.should raise_error
  end

  

  it "should update users" do
  #   create_user

  #   user = User.first login: 'test'
  #   session[:user] = user
  #   prev_hash = user.pass_hash

  #   @controller.params['first_name'] = 'pokemon'
  #   @controller.params['last_name'] = 'pikachu'
  #   @controller.params['password'] = 'hutehute'

  #   @connection.should_receive(:send_message)
  #   @controller.update

  #   user.first_name.should eq('pokemon')
  #   user.last_name.should eq('pikachu')
  #   user.pass_hash.should_not eq(prev_hash)
  end

  it "should handle logout" do
  #   create_user

  #   session[:user] = User.first login: 'test'

  #   @connection.should_receive(:send_message)
  #   @controller.logout

  #   session[:user].should_not be

  #   @connection.should_receive(:send_error)
  #   lambda { @controller.logout }.should raise_error(Protocol::RequestShortCut)
  end

  it "should handle self deletion" do
  #   create_user

  #   session[:user] = User.first login: 'test'

  #   @connection.should_receive(:send_message)
  #   @controller.delete

  #   session[:user].should_not be
  #   User.first(login: 'test').should_not be

  #   @connection.should_receive(:send_error).twice
  #   lambda { @controller.delete }.should raise_error(Protocol::RequestShortCut)

  #   create_user
  #   session[:user] = User.first login: 'test'
  #   session[:user].should_receive(:destroy).and_return(nil)
  #   lambda { @controller.delete }.should raise_error(Protocol::RequestShortCut)
  end

  it "should be able to show user" do
    user = login_user
    resp = post :index
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
    resp.message.should_not match /OK/
  end

  ## LOGOUT THE USER
  it "should logout user" do

    # LOGIN
    user = login_user

    # NOW LOGOUT
    resp = subject.logout

  end

end
