require 'spec_helper'

require_corresponding __FILE__

# TODO: test necessity of last name, first name etc.
# TODO: test email regex

describe UsersController, :unit do
  before do
    @connection = ClientConnection.new host: '0.0.0.0', part: 12345
    @controller = UsersController.new @connection
  end

  it "should create a user" do
    @controller.param['login'] = 'test'
    @controller.param['password'] = 'hello'
    @controller.param['email'] = 'abc@host.net'
    @controller.param['first_name'] = 'test'
    @controller.param['last_name'] = 'test'
    
    @connection.should_receive(:send_message).with(:signup_successful)
    @controller.should_receive(:send_confirmation_email)
    @connection.data[:current_user].should be_nil
    @connection.call_request :create, @controller
    @connection.data[:current_user].should_not be_nil
    User.first(login: 'test').should_not be_nil
  end

  it "should fail with the right errors in the right cases when creating" do
    # Missing parameters
    @connection.should_receive(:send_error).with(:missing_params)
    lambda { @connection.call_request :create, @controller }.should raise_error

    # Double login
    u = User.new login: "test", email: 'a@host.com', first_name: 'ok', last_name: 'ok'
    u.set_password "lol"
    u.save.should be
    @connection.should_receive(:send_error).with(:login_taken)
    @controller.param['login'] = 'test'
    @controller.param['password'] = 'a'
    @controller.param['email'] = 'b@host.com'
    @controller.param['first_name'] = 'hute'
    @controller.param['last_name'] = 'uhe'
    lambda { @connection.call_request :create, @controller }.should raise_error

    # Double email
    @connection.should_receive(:send_error).with(:email_taken)
    @controller.param['login'] = 'abc'
    @controller.param['password'] = 'a'
    @controller.param['email'] = 'a@host.com'
    @controller.param['first_name'] = 'hute'
    @controller.param['last_name'] = 'uhe'
    lambda { @connection.call_request :create, @controller }.should raise_error

    # If save returns false
    @controller.param['email'] = 'ht@host.com'
    User.any_instance.stub(:save).and_return(false)
    @connection.should_receive(:send_error).with(:could_not_create_user)
    lambda { @connection.call_request :create, @controller }.should raise_error
  end

  def create_user
    @u = User.new login: "test", email: 'a@b.com', first_name: 'hello', last_name: 'world'
    @u.set_password "lol"
    @u.save
  end

  def test_read method_name
    create_user
    @connection.should_receive(:send_error).with(:missing_params)
    lambda { @connection.call_request method_name, @controller }.should raise_error

    @connection.should_receive(:send_error).with(:user_not_found)
    @controller.param['login'] = 'ok'
    @controller.param['password'] = 'a'
    @controller.param['email'] = 'b@a.com'
    @controller.param['first_name'] = 'adrien'
    @controller.param['last_name'] = 'ecoffet'
    lambda { @connection.call_request method_name, @controller }.should raise_error
  end

  it "should update users" do
    create_user

    user = User.first login: 'test'
    @connection.data[:current_user] = user
    prev_hash = user.pass_hash

    @controller.param['first_name'] = 'pokemon'
    @controller.param['last_name'] = 'pikachu'
    @controller.param['password'] = 'hutehute'

    @connection.should_receive(:send_message)
    @connection.call_request :update, @controller

    user.first_name.should eq('pokemon')
    user.last_name.should eq('pikachu')
    user.pass_hash.should_not eq(prev_hash)
  end

  it "should handle logout" do
    create_user

    @connection.data[:current_user] = User.first login: 'test'

    @connection.should_receive(:send_message)
    @connection.call_request :logout, @controller

    @connection.data[:current_user].should_not be

    @connection.should_receive(:send_error)
    lambda { @connection.call_request :logout, @controller }.should raise_error(Protocol::RequestShortCut)
  end

  it "should handle self deletion" do
    create_user

    @connection.data[:current_user] = User.first login: 'test'

    @connection.should_receive(:send_message)
    @connection.call_request :delete, @controller

    @connection.data[:current_user].should_not be
    User.first(login: 'test').should_not be

    @connection.should_receive(:send_error).twice
    lambda { @connection.call_request :delete, @controller }.should raise_error(Protocol::RequestShortCut)

    create_user
    @connection.data[:current_user] = User.first login: 'test'
    @connection.data[:current_user].should_receive(:destroy).and_return(nil)
    lambda { @connection.call_request :delete, @controller }.should raise_error(Protocol::RequestShortCut)
  end

  it "should be able to show user" do
    create_user

    @connection.data[:current_user] = User.first login: 'test'
    
    # Now the actual proper case
    expected = User.first(login: "test").attributes
    expected.delete :pass_hash
    expected.delete :pass_salt
    @connection.should_receive(:send_object).with({ status: "ok", type: "user_infos", data: expected})
    @connection.call_request :show, @controller
  end

  it "should allow login" do
    # Testing errors first
    test_read :login

    @controller.param['login'] = 'test'
    @controller.param['password'] = 'lil'
    @connection.should_receive(:send_error).with(:bad_password)
    lambda { @connection.call_request :login, @controller }.should raise_error

    # Now the "normal" case
    @controller.param['password'] = 'lol'
    @connection.should_receive(:send_message).with(:login_successful)
    @connection.data[:current_user].should be_nil
    @connection.call_request :login, @controller
    @connection.data[:current_user].should_not be_nil
  end
end
