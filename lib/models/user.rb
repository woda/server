require 'data_mapper'
require 'helpers/hash_digest'

class User
  include DataMapper::Resource

  storage_names[:default] = "User"

  property :id,        Serial, :key => true
  property :login,     String, :required => true,
    :unique => true, :index => true
  property :pass_hash, String, :required => true,
    :length => HashDigest.new.hexdigest.length,
    :format => /^[a-fA-F0-9]{64}$/

  def has_password? pass
    digest = HashDigest.new
    (digest << pass).to_s.downcase == pass_hash.downcase
  end

  def set_password pass
    digest = HashDigest.new
    self.pass_hash = (digest << pass).to_s
  end
end
