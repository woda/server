require 'data_mapper'
require 'helpers/hash_digest.rb'
require 'helpers/crypt_helper.rb'
require 'models/properties/sha256_hash'
require 'models/properties/aes256_key'
require 'models/properties/aes256_iv'

class Content
  include DataMapper::Resource

  storage_names[:default] = "Content"

  property :content_hash, SHA256Hash, key: true
  property :crypt_key, AES256Key
  property :init_vector, AES256Iv

  has n, :blocks
end
