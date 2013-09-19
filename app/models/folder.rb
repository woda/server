require 'data_mapper'
require 'app/models/base/woda_resource'
require 'app/models/xfile'

class Folder
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "folder"

  property :id, Serial, key: true
  updatable_property :name, String, index: true, required: false
  updatable_property :last_modification_time, DateTime

  has n, :access_rights
  belongs_to :user, :child_key => :user_id, index: true
  has n, :children, self, :child_key => :parent_id
  belongs_to :parent, self, :required => false
  has n, :x_files, XFile, :child_key => :parent_id

#  has n, :folders
#  belongs_to :folder, index: true, require: false

  updatable_property :favorite, Boolean, :default => false, required: false
  updatable_property :public, Boolean, :default => false, required: false

  property :read_only, Boolean, :default => false, required: false
end

