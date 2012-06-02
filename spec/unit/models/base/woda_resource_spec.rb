require 'spec_helper'

require_corresponding __FILE__

describe WodaResource, :unit do
  it "should allow creating updatable properties" do
    class Lol
      include WodaResource
      include DataMapper::Resource

      property :id, Serial
    end
    Lol.updatable?(:uehtuhoetuh).should_not be
    Lol.updatable?(:id).should_not be
    class Lol
      updatable_property :username, String
    end
    Lol.updatable?(:username).should be
    Lol.updatable?(:uehtuhoetuh).should_not be
    Lol.updatable?(:id).should_not be
  end
end
