require 'data_mapper'

class File
  include DataMapper::Resource

  storage_names[:default] = "File"

  property :id, Serial, key: true
  property :filename, FilePath, index: true
  property :last_modification_time, DateTime

  has n, :access_rights
  belongs_to :user
  has 1, :content
end
