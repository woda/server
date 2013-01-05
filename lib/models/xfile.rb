require 'data_mapper'
require 'models/base/woda_resource'

class XFile
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "XFile"

  property :id, Serial, key: true
  updatable_property :name, String, index: true
  updatable_property :last_modification_time, DateTime

  has n, :access_rights
  belongs_to :user, :child_key => :user_id
  belongs_to :w_folder, :child_key => :parent_id
#  has 1, :content
end
