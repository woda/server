require 'data_mapper'
require 'app/models/base/woda_resource'

class Folder
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "Folder"

  property :id, Serial, key: true
  updatable_property :name, String, index: true
  updatable_property :last_modification_time, DateTime

  has n, :access_rights
  belongs_to :user, :child_key => :user_id
  has n, :children, :model => 'Folder', :child_key => [:parent_id]
  belongs_to :parent, :model => 'Folder', :child_key => [:parent_id]
  has n, :x_files
end

