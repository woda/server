require 'data_mapper'
require 'app/models/base/woda_resource'

##
# A model representing a file belonging to a user.
class XFile
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "xfile"

  property :id, Serial, key: true
  updatable_property :name, String, index: true
  updatable_property :last_modification_time, DateTime
  updatable_property :favorite, Boolean, :default => false
  has n, :access_rights
  belongs_to :user, :child_key => :user_id, index: true
  belongs_to :folder, :child_key => :parent_id, index: true
  has 1, :content
  updatable_property :downloads, Integer , :default => 0
  updatable_property :public, Boolean, :default => false
end
