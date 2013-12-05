require 'data_mapper'
require 'app/models/base/woda_resource'
require 'app/models/xfile'
require 'app/models/association'
require 'app/models/folder'

module Woda
  class File < XFile
    include DataMapper::Resource
    include WodaResource

    property :id, Serial, key: true

    has n, :file_folder_associations
    has n, :folder, :through => :file_folder_associations

	  def initialize *args, &block
	    super *args, &block
	    self.folder = false
	  end
	end
end
