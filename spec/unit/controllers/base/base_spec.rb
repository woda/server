require 'spec_helper'

require_corresponding __FILE__

describe Controller::Base do
  class TestController < Controller::Base
    actions :hello
    # Warning: before is kind of confusing
    before :world, :hello
  end

  before do
    @connection = mock(:data => {})
    @controller = TestController.new @connection
    @raw_controller = Controller::Base.new @connection
  end

  it "should have actions and before" do
    @raw_controller.actions.should be_nil
    @raw_controller.before.should be_nil
    @controller.actions.should be == Set.new(['hello'])
    @controller.before.should be == {:hello => [:world]}
  end

  it "should check authentication" do
    @controller.connection.should_receive(:error_need_login)
    @controller.check_authenticate.should_not be
    @controller.connection.data[:current_user] = true
    @controller.check_authenticate.should be
  end
end
