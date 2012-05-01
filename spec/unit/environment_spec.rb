require 'spec_helper'

require_corresponding __FILE__

describe Server do
  it "should give a correct root" do
    Server.root.should be == File.expand_path("../../..", __FILE__)
  end
end
