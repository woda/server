require 'data_mapper'
require 'models/base/woda_resource'

class WFile
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "File"

  property :id, Serial, key: true
  updatable_property :filename, FilePath, index: true
  updatable_property :last_modification_time, DateTime

  has n, :access_rights
  belongs_to :user, :child_key => :user_id
  has 1, :content
end
