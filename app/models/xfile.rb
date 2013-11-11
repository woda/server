require 'data_mapper'
require 'app/models/base/woda_resource'

##
# A model representing a file belonging to a user.
class XFile
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "xfile"

  property :id, Serial, key: true
  property :content_hash, SHA256Hash, index: true, required: false
  property :uploaded, Boolean, default: false
  property :folder, Boolean, default: false
  property :uuid, String, required: false

  updatable_property :name, String, index: true
  updatable_property :last_update, DateTime, default: Time.now
  updatable_property :favorite, Boolean, default: false
  updatable_property :downloads, Integer, default: 0
  updatable_property :public, Boolean, default: false

  belongs_to :user, index: true, required: true
  belongs_to :x_file, index: true, required: false
  
  has n, :x_files
  
  def children
    x_files.select { |item| item.folder }
  end

  def files
    x_files.select { |item| !item.folder }
  end

  def delete
    self.x_files.each do |item|      
      if item.x_files then
        item.delete
      else        
        item.content.delete if item.content
        item.destroy!
      end
    end    
    self.content.delete if self.content
    self.destroy!
  end

  def description
    if self.folder then
        { id: self.id, name: self.name, public: self.public, favorite: self.favorite, last_update: self.last_update, folder: self.folder }
      else
        { 
          id: self.id, name: self.name, last_update: self.last_update, type: File.extname(self.name),
          size: self.size, part_size: PART_SIZE, uploaded: self.uploaded, public: self.public, 
          shared: self.uuid != nil, downloads: self.downloads, favorite: self.favorite, folder: self.folder
        }
      end
  end

  def size
    size = 0
    if !content.nil? then
      size = content.size
    elsif x_files.size > 0 then
      size = x_files[0].size
    end
    size
  end

  def to_json *args
    json = super
    h = JSON.parse json
    h[:size] = size
    h[:part_size] = PART_SIZE
    JSON.generate h
  end

  def content
    return nil if content_hash.nil?
    Content.first content_hash: content_hash
  end

  def content= arg
    if !arg.nil? then
      self.content_hash = arg.content_hash
    else
      self.content_hash = nil
    end
  end
end
