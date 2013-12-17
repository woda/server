require 'data_mapper'
require 'app/models/base/woda_resource'
require 'app/helpers/woda_hash'
require 'app/models/properties/sha256_hash'
require 'securerandom'

##
# A model representing a file belonging to a user.
class XFile
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "xfile"

  property :id, Serial, key: true
  property :content_hash, SHA256Hash, index: true, required: false
  property :uploaded, Boolean, default: false
  property :shared, Boolean, default: false
  property :folder, Boolean, default: false
  property :uuid, String, required: false

  updatable_property :name, String, index: true
  updatable_property :last_update, DateTime, default: Time.now
  updatable_property :favorite, Boolean, default: false
  updatable_property :downloads, Integer, default: 0
  updatable_property :public, Boolean, default: false

  belongs_to :user, required: true

  has n, :file_user_associations
  has n, :users, through: :file_user_associations

  def initialize *args, &block
    super *args, &block
    self.folder = false
  end

  def link
    (self.uuid.nil? ? nil : "#{BASE_URL}/dl/#{self.uuid}")
  end

  def generate_link
    self.uuid = SecureRandom::uuid unless self.uuid
    self.save
    "#{BASE_URL}/dl/#{self.uuid}"
  end

  def description
    if self.folder then
        {
          id: self.id, name: self.name, public: self.public, favorite: self.favorite, last_update: self.last_update,
          folder: self.folder, shared: self.shared, downloads: self.downloads
        }
      else
        size = ( self.content.nil? ? 0 : self.content.size )
        { 
          id: self.id, name: self.name, last_update: self.last_update, type: File.extname(self.name),
          size: size, part_size: PART_SIZE, uploaded: self.uploaded, public: self.public, 
          shared: self.shared, downloads: self.downloads, favorite: self.favorite, folder: self.folder,
          link: self.link, uuid: self.uuid
        }
      end
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
