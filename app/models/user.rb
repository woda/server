require 'data_mapper'
require 'app/helpers/woda_hash'
require 'app/models/properties/sha256_hash'
require 'app/models/base/woda_resource'
require 'app/models/file'
require 'app/models/folder'
require 'app/models/association'

##
# The User model. represents a user with login, first name, last name, email and password.
# Also links to the folders and files of the user.
class User
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "user"

  property :id, Serial, key: true
  property :pass_hash, SHA256Hash, required: true
  property :pass_salt, SHA256Salt, required: true
  property :active, Boolean, required: true, default: true
  property :locked, Boolean, required: true, default: false
  property :admin, Boolean, required: true, default: false
  property :space, Integer, required: true, default: DEFAULT_SPACE
  property :used_space, Integer, required: true, default: 0

  updatable_property :login, String, unique: true, unique_index: true, required: true
  updatable_property :email, String, unique: true, unique_index: true, format: :email_address, required: true

  has 1, :root_folder, WFolder
  has n, :original_files, XFile

  has n, :file_user_associations
  has n, :x_files, XFile, through: :file_user_associations

  has n, :shared_to_me_associations, 'SharedToMeAssociation', child_key: [:user_id]
  has n, :x_files_shared_to_me, XFile, through: :shared_to_me_associations, via: :x_file

  has n, :shared_by_me_associations, 'SharedByMeAssociation', child_key: [:user_id]
  has n, :x_files_shared_by_me, XFile, through: :shared_by_me_associations, via: :x_file

  has n, :favorite_file_association, 'FavoriteFileAssociation', child_key: [:user_id]
  has n, :favorite_files, XFile, through: :favorite_file_association, via: :x_file

  has n, :friendships, :child_key => [:source_id]
  has n, :friends, self, :through => :friendships, :via => :target

  ##
  # User's description
  def description
    { id: self.id, login: self.login, email: self.email }
  end

  ##
  # User's private description
  def private_description
    {
      id: self.id, login: self.login, email: self.email, active: self.active, locked: self.locked,
      admin: self.admin, space: self.space, used_space: self.used_space
    }
  end

  ##
  # Always use this function to test for password
  def has_password? pass
    WodaHash.digest(self.pass_salt + pass).to_hex.downcase == pass_hash.downcase
  end

  ##
  # Always use this function to set password. Never set it by hand
  def set_password pass
    self.pass_salt = SHA256Salt.generate_random
    self.pass_hash = WodaHash.digest(self.pass_salt + pass).to_hex
  end

  ##
  # Destroy a user and all its attributes, files, folders, relationships, etc.
  def delete
    # no need to delete all the associations because root_folder.delete does it
    self.root_folder.delete self
    self.friends.each { |friend| friend.delete }
    self.destroy!
  end

  def can_add_file_size size
    (self.used_space + size) <= self.space
  end

  def add_file_size size
    self.used_space += size
  end

  def remove_file_size size
    self.used_space -= size
    self.used_space = 0 if self.used_space < 0
  end

end
