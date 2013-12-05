require 'data_mapper'
require 'app/models/base/woda_resource'
require 'app/models/xfile'
require 'app/models/association'
require 'app/models/file'

module Woda

  class Folder < XFile
    include DataMapper::Resource
    include WodaResource

    property :id, Serial, key: true

    has n, :file_folder_associations
    has n, :files, File, :through => :file_folder_associations

    def initialize *args, &block
      super *args, &block
      self.folder = true
    end

    def children
      x_files.select { |item| item.folder }
    end

    def files
      x_files.select { |item| !item.folder }
    end
  end

end
