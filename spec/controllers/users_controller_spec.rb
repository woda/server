require 'spec_helper'

describe UsersController do

  before do
  	db_clear
  	session[:user] = User.new({login: 'lol', last_name: 'Ecoffet', first_name: 'Adrien', email: 'aec@gmail.com'})
  	session[:user].set_password 'hello'
  	session[:user].save
    @controller = UsersController.new
  end

  it "shoud allow file listing" do
    # TODO: Create test to do file listing
  end

  it "show allow a file listing from specific directory" do
  
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

  # def create_user
  #   @u = User.new login: "test", email: 'a@b.com', first_name: 'hello', last_name: 'world'
  #   @u.set_password "lol"
  #   @u.save
  # end

  # def test_read method_name
  #   create_user
  #   lambda { @connection.call_request method_name, @controller }.should raise_error

  #   @controller.params['login'] = 'ok'
  #   @controller.params['password'] = 'a'
  #   @controller.params['email'] = 'b@a.com'
  #   @controller.params['first_name'] = 'adrien'
  #   @controller.params['last_name'] = 'ecoffet'
  #   lambda { @connection.call_request method_name, @controller }.should raise_error
  # end

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
  #   create_user

  #   session[:user] = User.first login: 'test'
    
  #   # Now the actual proper case
  #   expected = User.first(login: "test").attributes
  #   expected.delete :pass_hash
  #   expected.delete :pass_salt
  #   @connection.should_receive(:send_object).with({ status: "ok", type: "user_infos", data: expected})
  #   @controller.show
  end

  it "should allow login" do
  #   # Testing errors first
  #   test_read :login

  #   @controller.params['login'] = 'test'
  #   @controller.params['password'] = 'lil'
  #   @connection.should_receive(:send_error).with(:bad_password)
  #   lambda { @controller.login }.should raise_error

  #   # Now the "normal" case
  #   @controller.params['password'] = 'lol'
  #   @connection.should_receive(:send_message).with(:login_successful)
  #   session[:user].should be_nil
  #   @controller.login
  #   session[:user].should_not be_nil
  end
end
