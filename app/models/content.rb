require 'data_mapper'
require 'app/helpers/hash_digest.rb'
require 'app/helpers/crypt_helper.rb'
require 'app/models/base/woda_resource'
require 'app/models/properties/sha256_hash'
require 'app/models/properties/aes256_key'
require 'app/models/properties/aes256_iv'

class Content
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "content"

  property :id, Serial, key: true
  updatable_property :content_hash, SHA256Hash, unique: true
  # Note: right now the policy is to forbid people who announce the same hash
  # but not the same salted hash from uploading a file. although very unlikely,
  # it is possible that those people simply have different files that have the
  # same hash, in which case this is totally unfair.
  # Note2: this is also commented for now...
#  updatable_property :content_salt, SHA256Salt
#  updatable_property :content_salted_hash, SHA256Hash
  updatable_property :crypt_key, AES256Key
  updatable_property :init_vector, AES256Iv
  updatable_property :size, Integer
  updatable_property :file_type, String
  property :start_upload, Integer
end
