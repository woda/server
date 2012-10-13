require 'data_mapper'
require 'helpers/hash_digest'
require 'models/properties/sha256_hash'
require 'models/base/woda_resource'
require 'active_support/secure_random'

class User
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "User"

  property :id, Serial, key: true
  updatable_property :login, String, unique: true, unique_index: true
  updatable_property :email, String, unique: true, unique_index: true,
    format: :email_address
  updatable_property :first_name, String
  updatable_property :last_name, String
  property :pass_hash, SHA256Hash
  property :pass_salt, SHA256Salt

  has n, :w_files
  has n, :devices

  def has_password? pass
    WodaHash.digest(self.pass_salt + pass).to_hex.downcase == pass_hash.downcase
  end

  def set_password pass
    self.pass_salt = SHA256Salt.generate_random
    self.pass_hash = WodaHash.digest(self.pass_salt + pass).to_hex
  end
end
