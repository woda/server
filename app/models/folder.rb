require 'data_mapper'
require 'app/models/base/woda_resource'
require 'app/models/xfile'

class Folder
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "folder"

  property :id, Serial, key: true
  property :read_only, Boolean, default: false, required: false

  updatable_property :name, String, index: true
  updatable_property :last_update, DateTime, default: Time.now
  updatable_property :favorite, Boolean, default: false
  updatable_property :public, Boolean, default: false

  has n, :access_rights
  belongs_to :user, child_key: :user_id, index: true
  has n, :children, self, child_key: :parent_id
  belongs_to :parent, self, required: false
  has n, :x_files, XFile, child_key: :parent_id

  def description
    { id: self.id, name: self.name, public: self.public, favorite: self.favorite, read_only: self.read_only, last_update: self.last_update }
  end

end
