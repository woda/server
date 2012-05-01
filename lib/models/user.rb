require 'data_mapper'

class User
  include DataMapper::Resource

  property :id, Serial
  property :login, String
  property :pass_hash, String

  validates_uniqueness_of :login

  validates_presence_of :login, :pass_hash
end
