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
  property :folder, Boolean, default: false
  property :uuid, String, required: false

  updatable_property :name, String, index: true, :length => 1..2048
  updatable_property :last_update, DateTime, default: Time.now
  updatable_property :downloads, Integer, default: 0
  updatable_property :public, Boolean, default: false

  belongs_to :user, required: true

  has n, :file_user_associations
  has n, :users, through: :file_user_associations

  has n, :favorite_file_association, 'FavoriteFileAssociation', child_key: [:x_file_id]
  has n, :favorite_users, User, through: :favorite_file_association, via: :user

  has n, :shared_to_me_associations, 'SharedToMeAssociation', child_key: [:x_file_id]
  has n, :x_files_shared_to_me, User, through: :shared_to_me_associations, via: :user

  has n, :shared_by_me_associations, 'SharedByMeAssociation', child_key: [:x_file_id]
  has n, :x_files_shared_by_me, User, through: :shared_by_me_associations, via: :user  

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

  def description user=nil
    favorite = self.favorite_users.include? user if user
    owner = ( (user == self.user || !user) ? nil : self.user.description)
    if self.folder then
        {
          id: self.id, name: self.name, public: self.public, last_update: self.last_update, favorite: favorite,
          folder: self.folder, downloads: self.downloads, owner: owner
        }
      else
        size = ( self.content.nil? ? 0 : self.content.size )
        { 
          id: self.id, name: self.name, last_update: self.last_update, type: File.extname(self.name),
          size: size, part_size: PART_SIZE, uploaded: self.uploaded, public: self.public, owner: owner,
          downloads: self.downloads, folder: self.folder, favorite: favorite, link: self.link, uuid: self.uuid
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
