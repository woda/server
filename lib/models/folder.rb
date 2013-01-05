require 'data_mapper'
require 'models/base/woda_resource'

class WFolder
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "Folder"

  property :id, Serial, key: true
  updatable_property :name, String, index: true
  updatable_property :last_modification_time, DateTime

  has n, :access_rights
  belongs_to :user, :child_key => :user_id
  has n, :tree_relationships, :child_key => [ :parent ]
  has n, :children, self, :through => :tree_relationships, :via => :child
  has 1, :parent, self, :through => :tree_relationships, :via => :parent
  has n, :x_files
end

class TreeRelationship
  include DataMapper::Resource

  belongs_to :child, 'WFolder', :key => true
  belongs_to :parent, 'WFolder', :key => true
end
