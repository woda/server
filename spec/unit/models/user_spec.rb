require 'spec_helper'

require_corresponding __FILE__

describe User do
  before do
    DataMapper::Model.raise_on_save_failure = true
  end

  def build_user
    @user = User.new :login => "hello"
    @user.set_password "world"
    @user.save
  end

  it "should handle passwords" do
    @user = User.new :login => "hello"
    @user.set_password "world"
    @user.has_password?("world").should be
    @user.has_password?("wrld").should_not be
  end

  it "should be insertable" do
    @user = User.new :login => "hello"
    @user.set_password "world"
    @user.id.should be_nil
    @user.save
    @user.id.should_not be_nil
  end

  it "should have a unique login" do
    build_user
    lambda { build_user }.should raise_error
  end

  it "should force presence of login and pass_hash" do
    u = User.new :pass_hash => "lol"
    lambda { u.save }.should raise_error
    u2 = User.new :login => "lol"
    lambda { u2.save }.should raise_error
  end

  it "should support queries" do
    build_user
    digest = HashDigest.new
    User.first(:login => 'hello').has_password?("world").should be
    User.first(:login => 'a').should be_nil
  end

  it "should force having a password hash" do
    u = User.new :login => "hello", :pass_hash => "world"
    lambda { u.save }.should raise_error
    u = User.new :login => "hello"
    u.set_password "world"
    u.save
  end

  it "should support updates" do
    build_user
    u = User.first(:login => 'hello')
    u.set_password "ok"
    u.save
  end
end