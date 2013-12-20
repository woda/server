require 'data_mapper'
require 'app/models/base/woda_resource'
require 'app/models/file'
require 'app/models/folder'
require 'app/models/xfile'

class FileFolderAssociation
  include DataMapper::Resource
  include WodaResource

  storage_names[:default] = 'FileFolderAssociation'

  belongs_to :parent, 'WFolder', key: true
  belongs_to :file, 'WFile', key: true
end

class FolderFolderAssociation
  include DataMapper::Resource
  include WodaResource

  storage_names[:default] = 'FolderFolderAssociation'

  belongs_to :parent, 'WFolder', key: true
  belongs_to :children, 'WFolder', key: true
end

class FileUserAssociation
  include DataMapper::Resource
  include WodaResource

  storage_names[:default] = 'FileUserAssociation'
  
  belongs_to :user, 'User', key: true
  belongs_to :x_file, 'XFile', key: true
end

class FavoriteFileAssociation
  include DataMapper::Resource
  include WodaResource

  storage_names[:default] = 'FavoriteFileAssociation'
  
  belongs_to :favorite_user, 'User', key: true
  belongs_to :favorite_file, 'XFile', key: true
end

