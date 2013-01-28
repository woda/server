require 'spec_helper'

require_corresponding __FILE__

DataMapper::Model.raise_on_save_failure = true

describe DataMapper::SaveFailureError, :unit do
  it "should output all the correct errors on save fail" do
    # The error content is hardcoded... not too good but necessary
    lambda { User.new.save }.should raise_error(DataMapper::SaveFailureError,
      "User#save returned false, User was not saved: Login must not be blank & Email must not be blank & First name must not be blank & Last name must not be blank & Pass hash must not be blank & Pass salt must not be blank")
  end
end
