require 'data_mapper'
require 'app/models/properties/sha256_hash'

class Block
  include DataMapper::Resource

  storage_names[:default] = "Block"

  property :id, Serial, key: true
  property :block_hash, SHA256Hash, unique: true, unique_index: true
  property :file_offset, Integer
  property :deleted, Boolean

  belongs_to :content
  belongs_to :device
end
