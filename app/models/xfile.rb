require 'data_mapper'
require 'app/models/base/woda_resource'

##
# A model representing a file belonging to a user.
class XFile
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "xfile"

  property :id, Serial, key: true
  updatable_property :name, String, index: true
  updatable_property :last_modification_time, DateTime
  updatable_property :favorite, Boolean, :default => false
  has n, :access_rights
  belongs_to :user, :child_key => :user_id, index: true
  belongs_to :folder, :child_key => :parent_id, index: true
  belongs_to :x_file, index: true, required: false
 # A file either has a file or a content
  has n, :contents
  has n, :x_files

  def multiple_accessor acc
    if send(acc).size == 1 then
      return send(acc)[0]
    end
    nil
  end

  def multiple_setter acc, arg
    if send(acc).size == 1 then
      send(acc)[0] = arg
    else
      send(acc) << arg
    end
    arg
  end

  def x_file
    multiple_accessor :x_files
  end

  def x_file= arg
    multiple_setter :x_files, arg
  end

  def content
    multiple_accessor :contents
  end

  def content= arg
    multiple_setter :contents, arg
  end

  updatable_property :downloads, Integer , :default => 0
  updatable_property :is_public, Boolean, :default => false

  property :read_only, Boolean, :default => false
end
