require 'data_mapper'
require 'app/models/base/woda_resource'
require 'app/models/xfile'

class Folder < XFile
  def initialize *args, &block
    super *args, &block
    self.folder = true
  end
end
