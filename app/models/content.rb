require 'data_mapper'
require 'app/helpers/woda_hash.rb'
require 'app/helpers/woda_crypt.rb'
require 'app/models/base/woda_resource'
require 'app/models/properties/sha256_hash'
require 'app/models/properties/aes256_key'

class Content
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "content"

  property :id, Serial, key: true
  property :content_hash, SHA256Hash, unique: true
  property :crypt_key, AES256Key
  property :size, Integer
  
  has n, :x_parts

  # Note: At the moment there is a security problem when a user wants to upload a file
  # by knowing its content_hash but without having the file. As the server will tell
  # the user to not upload the file because it's already stored, the user will be able
  # to download a file without having it in the beginning.

  # Note 2: right now the policy is to forbid people who announce the same hash
  # but not the same salted hash from uploading a file.
#  property :content_salt, SHA256Salt
#  property :content_salted_hash, SHA256Hash

  def self.create(content_hash, size)
    content = Content.new(content_hash: content_hash, size: size, crypt_key: WodaCrypt.new.random_key.to_hex)
    i = 0
    while size > 0 do
      content.x_parts << XPart.new(part_number: i)
      size -= PART_SIZE
      i += 1
    end
    content.save
    content
  end

  def needed_parts 
    parts = []
    self.x_parts.each { |x_part| parts << x_part.part_number }
    parts
  end

  def uploaded
    XFile.count(content_hash: self.content_hash, uploaded: true) >= 1
  end

  def delete
    if XFile.count(content_hash: self.content_hash) <= 1 then
      self.x_parts.destroy!
      self.destroy!
    end
  end

  def description
    { id: self.id, content_hash: self.content_hash, crypt_key: self.crypt_key, size: self.size }
  end

end
