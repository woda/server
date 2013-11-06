require 'data_mapper'
require 'app/helpers/woda_hash'
require 'app/models/properties/sha256_hash'
require 'app/models/base/woda_resource'

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
  property :roles, Text, required: true, default: 'a:1:{i:0;s:9:"ROLE_USER";}'

  updatable_property :login, String, unique: true, unique_index: true, required: true
  updatable_property :email, String, unique: true, unique_index: true, format: :email_address, required: true

  has n, :x_files

  ##
  # User description
  def description
    { id: self.id, login: self.login, email: self.email, active: self.active, locked: self.locked }

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
  # Create the root folder for the current user
  def create_root_folder 
    folder = Folder.new(name: "/", last_update: DateTime.now, user: self )
    self.x_files << folder
    folder.save
  end

  ##
  # Gets and creates a folder and if it does not exist.
  def create_folder path
    raise RequestError.new(:bad_param, "Path can't be nil") if path.nil?
    
    path = path.split('/')
    folder = self.x_files.first
    path.reject! { |c| c.empty? }
    path.size.times do |i|
      folder2 = folder.x_files.first(name: path[i], folder: true)   
      if folder2.nil? then
          folder2 = Folder.new( name: path[i], last_update: DateTime.now, user: self )
          folder.x_files << folder2
          folder.save
      end
      folder = folder2
    end
    folder
  end

  ##
  # Create a file and its parent folders.
  def create_file path
    path = path.split('/')
    folder = create_folder(path[0...path.size-1].join('/'))
    file = folder.x_files.first(name: path[-1], folder: false)
    if file.nil? then
      file = XFile.new(name: path[-1], last_update: DateTime.now, user: self )
      folder.x_files << file
      folder.save
    end
    file
  end

end
