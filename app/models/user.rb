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
  property :roles, Text, required: true, default: 'a:1:{i:0;s:9:"ROLE_USER";}'

  updatable_property :login, String, unique: true, unique_index: true, required: true
  updatable_property :email, String, unique: true, unique_index: true, format: :email_address, required: true

  has 1, :root_folder, WFolder

  has n, :file_user_associations
  has n, :x_files, XFile, through: :file_user_associations

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
  # Destroy a user and all its attributes, files, folders, relationships, etc.
  def delete
    self.root_folder.delete
    FileUserAssociation.all(user_id: self.id).destroy!
    self.destroy!
  end

  ##
  # Create the root folder for the current user
  def create_root_folder 
    folder = WFolder.new(name: "/", last_update: DateTime.now)
    self.x_files << folder
    self.root_folder = folder
    folder.save
    self.save
  end

  ##
  # Gets and creates a folder and if it does not exist.
  def create_folder path
    raise RequestError.new(:bad_param, "Path can't be nil") if path.nil?
    path = path.split('/')
    folder = self.root_folder
    path.reject! { |c| c.empty? }
    path.size.times do |i|
      puts "path: #{path[i]}"
      child = folder.childrens.first(name: path[i], folder: true)
      puts "child: #{child.description}" if child
      puts "child does not exist" if child.nil?
      if child.nil? then
          child = WFolder.new(name: path[i], last_update: DateTime.now)
          self.x_files << child
          self.save
          folder.childrens << child
          folder.save
          child.save
          puts "new child: #{child.description}"
          puts "child.parents: #{child.parents.last}"
          puts "parent.childrens: #{folder.childrens.last}"
          puts "----------------------------------------------------"
      end
      folder = child
    end
    puts "return #{folder.description}"
    folder
  end

  ##
  # Create a file and its parent folders.
  def create_file path
    path = path.split('/')
    folder = create_folder(path[0...path.size-1].join('/'))
    file = folder.files.first(name: path[-1], folder: false)
    if file.nil? then
      file = WFile.new(name: path[-1], last_update: DateTime.now)
      self.x_files << file
      self.save
      folder.files << file
      folder.save
      file.save
    end
    file
  end

end
