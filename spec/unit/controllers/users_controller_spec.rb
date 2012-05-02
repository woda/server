require 'spec_helper'

require_corresponding __FILE__

describe UsersController do
  before do
    @connection = ClientConnection.new host: '0.0.0.0', part: 12345
    @controller = UsersController.new @connection
  end

  it "should create a user" do
    @controller.param['login'] = 'test'
    @controller.param['password'] = 'hello'
    @connection.should_receive(:send_message).with(:signup_successful)
    @connection.data[:current_user].should be_nil
    @controller.create
    @connection.data[:current_user].should_not be_nil
    User.first(:login => 'test').should_not be_nil
  end

  it "should fail with the right errors in the right cases when creating" do
    @connection.should_receive(:send_error).with(:missing_params)
    lambda { @controller.create }.should raise_error

    u = User.new :login => "test"
    u.set_password "lol"
    u.save.should be
    @connection.should_receive(:send_error).with(:login_taken)
    @controller.param['login'] = 'test'
    @controller.param['password'] = 'a'
    lambda { @controller.create }.should raise_error

    @controller.param['login'] = 'lol'
    User.any_instance.stub(:save).and_return(false)
    @connection.should_receive(:send_error).with(:could_not_create_user)
    lambda { @controller.create }.should raise_error
  end

  def create_user
    @u = User.new :login => "test"
    @u.set_password "lol"
    @u.save
  end

  def test_read method_name
    create_user
    @connection.should_receive(:send_error).with(:missing_params)
    lambda { @controller.send method_name }.should raise_error

    @connection.should_receive(:send_error).with(:user_not_found)
    @controller.param['login'] = 'ok'
    @controller.param['password'] = 'a'
    lambda { @controller.send method_name }.should raise_error
  end

  it "should be able to show user" do
    #Testing errors first
    test_read :show

    # Now the actual proper case
    @controller.param['login'] = 'test'
    @connection.should_receive(:send_object).with({ status: "ok", type: "user_infos", data: User.first(login: "test").attributes})
    @controller.show
  end

  it "should allow login" do
    # Testing errors first
    test_read :login

    @controller.param['login'] = 'test'
    @controller.param['password'] = 'lil'
    @connection.should_receive(:send_error).with(:bad_password)
    lambda { @controller.login }.should raise_error

    # Now the "normal" case
    @controller.param['password'] = 'lol'
    @connection.should_receive(:send_message).with(:login_successful)
    @connection.data[:current_user].should be_nil
    @controller.login
    @connection.data[:current_user].should_not be_nil
  end
end
