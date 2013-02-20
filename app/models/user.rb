require 'data_mapper'
require 'lib/helpers/hash_digest'
require 'app/models/properties/sha256_hash'
require 'app/models/base/woda_resource'

class User
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "User"

  property :id, Serial, key: true
  updatable_property :login, String, unique: true, unique_index: true, required: true
  updatable_property :email, String, unique: true, unique_index: true,
    format: :email_address, required: true
  updatable_property :first_name, String, required: true
  updatable_property :last_name, String, required: true
  property :pass_hash, SHA256Hash, required: true
  property :pass_salt, SHA256Salt, required: true

  has n, :folders
  has n, :x_files

  def has_password? pass
    WodaHash.digest(self.pass_salt + pass).to_hex.downcase == pass_hash.downcase
  end

  def set_password pass
    self.pass_salt = SHA256Salt.generate_random
    self.pass_hash = WodaHash.digest(self.pass_salt + pass).to_hex
  end

  def get_file(path, options = {})
    folder = Folder.first user: self, name: nil
    if folder.nil? then
      folder = Folder.new name: nil, last_modification_time: DateTime.now, user: self
      self.folders << folder
      self.save
      folder.save
    end
    (path.size - 1).times do |i|
      folder2 = folder.children.first(name: path[i])
      if folder2.nil? then
        if options[:create] then
          folder2 = Folder.new name: path[i], last_modification_time: DateTime.now, user: self
          folder.children << folder2
          folder.save
        else
          raise RequestError.new(:folder_not_found, "Folder #{path[i]} not found")
        end
      end
      folder = folder2
    end
    f = folder.x_files.first(name: path[-1])
    if f.nil? then
      if options[:create] then
        f = XFile.new name: path[-1], last_modification_time: DateTime.now, user: self
        folder.x_files << f
        folder.save
      else
        raise RequestError.new(:file_not_found, "File #{path[-1]} not found")
      end
    end
    f
  end
end
