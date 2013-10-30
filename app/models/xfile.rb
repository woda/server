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

  belongs_to :user, child_key: :user_id, index: true
  belongs_to :x_file, index: true, required: false
  has n, :x_files
  
  def children
    x_files.select { |item| item.folder }
  end

  def files
    x_files.select { |item| !item.folder }
  end
 
  def update_and_save
    self.last_update = Time.now
    # puts "------------------->  #{self.name} : #{self.last_update}"
    self.save
    # puts "-------------------> x_file: #{self.x_file}"
    if (self.x_file)
      self.x_file.update_and_save
    end
  end

  def description
    if self.folder then
        { id: self.id, name: self.name, public: self.public, favorite: self.favorite, last_update: self.last_update }
      else
        { 
          id: self.id, name: self.name, last_update: self.last_update, type: File.extname(self.name),
          size: self.size, part_size: XFile.part_size, uploaded: self.uploaded, public: self.public, 
          shared: self.uuid != nil, downloads: self.downloads, favorite: self.favorite
        }
      end
  end

  def self.part_size
    return 5242880 # 5 * 1024 * 1024
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
    h['size'] = size
    h['part_size'] = XFile.part_size
    JSON.generate h
  end

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
    # puts "getting content #{content_hash}"
    return nil if content_hash.nil?
    # puts content_hash
    Content.first content_hash: content_hash
  end

  def content= arg
    if !arg.nil? then
      self.content_hash = arg.content_hash
      # puts "setting content hash: #{content_hash}"
    else
      # puts "unsetting content"
      self.content_hash = nil
    end
  end
end
