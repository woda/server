class User < ActiveColumn::Base
  key :login
  attr_accessor :login, :pass_hash
end
