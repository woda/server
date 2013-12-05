require 'data_mapper'
require 'app/models/base/woda_resource'
require 'app/models/file'
require 'app/models/folder'

module Woda

  class FileFolderAssociation
    include DataMapper::Resource
    include WodaResource

    belongs_to :folder, Folder, :key => true
    belongs_to :file, File, :key => true
  end

end