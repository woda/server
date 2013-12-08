require 'data_mapper'
require 'app/models/base/woda_resource'
require 'app/models/xfile'
require 'app/models/association'
require 'app/models/folder'

class WFile < XFile
  include DataMapper::Resource
  include WodaResource

  storage_names[:default] = "xfile"

  property :id, Serial, key: true

  has n, :file_folder_associations, child_key: [:file_id]
  has n, :parents, 'WFolder', through: :file_folder_associations, via: :parent

  def initialize *args, &block
    super *args, &block
    self.folder = false
  end

  def delete
    FileUserAssociation.all(x_file_id: self.id).destroy!
    FileFolderAssociation.all(file_id: self.id).destroy!

    super
  end

end
