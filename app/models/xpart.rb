require 'data_mapper'
require 'app/models/base/woda_resource'

##
# A model representing a part belonging to a file.
class XPart
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "xpart"

  property :id, Serial, key: true
  property :part_number, Integer, index: true, required: true

  belongs_to :content, index: true, required: true

  def description
    { id: self.id, part_number: self.part_number, content_id: self.content_id}
  end

end
