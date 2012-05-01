require 'spec_helper'

require_corresponding __FILE__

describe Server do
  it "should give a correct root" do
    Server.root.should be == File.expand_path("../../..", __FILE__)
  end

  it "should determine dev environment if not set in ENV" do
    ENV['WODA_ENV'] = nil
    determine_environment.should be == :dev
  end

  it "should exit if the environment is bad" do
    should_receive(:puts)
    should_receive(:exit).with(1)
    assert_good_environment :lol
  end
end
