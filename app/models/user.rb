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
  
  has n, :folders
  has n, :x_files

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

  def create_root_folder 
    folder = Folder.new(name: "/", last_update: DateTime.now, user: self)
    self.x_files << folder
    folder.save
  end

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
  # Gets the folder and creates the root folder if it does not exist. The path must
  # already be split.
  # If you send create: true the folder will be created.
  # TODO: remove this method
  def get_folder(path, options = {})
    folder = Folder.first user: self, name: nil

    if folder.nil? then
      # TODO name:"/" instead? 
      folder = Folder.new(name: nil, last_update: DateTime.now, user: self)
      self.folders << folder
      self.save
      folder.save
    end
    path.reject! { |c| c.empty? }
    path.size.times do |i|
      folder2 = folder.x_files.first(name: path[i], folder: true)   
      if folder2.nil? then
        if options[:create] then
          folder2 = Folder.new name: path[i], last_update: DateTime.now, user: self
          folder.x_files << folder2
          folder.save
        else
          raise RequestError.new(:folder_not_found, "Folder #{path[i]} not found")
        end
      end
      folder = folder2
    end
    folder
  end

  ##
  # Gets the file for a given paths. This is two versions in one:
  # The first version, with no options, tries to get an existing file and
  #  returns nil if it doesn't find it.
  # The second version, with :create => true tries to get a file and creates
  #  all the folders and the file itsel if they do not exit.
  # /!\ Both versions create a root folder if it doesn't exist!
  def get_file(path, options = {})
    folder = get_folder(path[0...path.size-1], options)
    f = folder.x_files.first(name: path[-1], folder: false)
    if f.nil? then
      if options[:create] then
        f = XFile.new(name: path[-1], last_update: DateTime.now, user: self, uuid: nil)
        folder.x_files << f
        folder.save
      else
        raise RequestError.new(:file_not_found, "File #{path[-1]} not found")
      end
    end
    f
  end
end
