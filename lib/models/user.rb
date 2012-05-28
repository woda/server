require 'data_mapper'
require 'helpers/hash_digest'
require 'models/properties/sha256_hash'
require 'models/base/woda_resource'

class User
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "User"

  property :id, Serial, key: true
  updatable_property :login, String, unique: true, unique_index: true
  updatable_property :email, String, unique: true, unique_index: true,
    format: :email_address, required: false
  property :pass_hash, SHA256Hash

  has n, :files
  has n, :devices

  def has_password? pass
    WodaHash.digest(pass).to_hex.downcase == pass_hash.downcase
  end

  def set_password pass
    self.pass_hash = WodaHash.digest(pass).to_hex
  end
end
