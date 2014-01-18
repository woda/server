require 'data_mapper'
require 'app/models/base/woda_resource'
require 'app/models/xfile'
require 'app/models/association'
require 'app/models/folder'

class WFile < XFile
  include DataMapper::Resource
  include WodaResource

  storage_names[:default] = "xfile"

  property :id, Serial, key: true

  has n, :file_folder_associations, child_key: [:file_id]
  has n, :parents, 'WFolder', through: :file_folder_associations, via: :parent

  def initialize *args, &block
    super *args, &block
    self.folder = false
  end

  ##
  # Delete the current file and all its associations
  def delete current_user
    raise RequestError.new(:internal_error, "Delete: no user specified") if current_user.nil?

    if current_user.id != self.user_id then # if random owner 
      # remove all links between this file and the current user
      FileUserAssociation.all(x_file_id: self.id, user_id: current_user.id).destroy!
      # remove all associations where this file is "inside" a folder for the current user only
      FileFolderAssociation.all(file_id: self.id).each do |asso|
        asso.destroy! if current_user.x_files.get(asso.parent_id)
      end
      # remove all associations where this file is shared >TO< another user
      SharedToMeAssociation.all(x_file_id: self.id, user_id: current_user.id).destroy!

    else # if true owner 
      # remove all links between this file and ALL users
      FileUserAssociation.all(x_file_id: self.id).destroy!
      # remove all associations where this file is "inside" a folder for ALL users
      FileFolderAssociation.all(file_id: self.id).destroy!
      # remove all associations where this file is shared >BY< the current user
      SharedByMeAssociation.all(x_file_id: self.id, user_id: current_user.id).destroy!      

      # if a content exist and if the user is the original owner, reduce the user's used space
      current_user.remove_file_size self.content.size if content

      # remove the content if and only if the true owner removes the file
      # a hook inside the content.delete method will check it this content is referenced by antoher file.
      self.content.delete if self.content

      # now remove the entity
      self.destroy!
    end
  end

  ##
  # Create a file and its parent folders.
  def self.create user, path
    path = path.split('/')
    folder = WFolder.get_for_path(user, path[0...path.size-1].join('/'))
    file = folder.files.first(name: path[-1], folder: false)
    if file.nil? then
      file = WFile.new(name: path[-1], last_update: DateTime.now, user: user)
      user.x_files << file
      user.save
      folder.files << file
      folder.save
      file.save
    end
    file
  end

  ##
  # Create a file from another public file.
  def self.create_from_origin user, origin
    folder = user.root_folder
    file = folder.files.first(name: origin.name, folder: false)
    if file.nil? then
      file = WFile.new(name: origin.name, last_update: DateTime.now, user: user)
      file.content_hash = origin.content_hash
      file.uploaded = origin.uploaded
      file.folder = origin.folder
      file.public = true

      user.x_files << file
      user.save
      folder.files << file
      folder.save
      file.save
    end
    file
  end

  ##
  # Link a file from another public file.
  def self.link_from_origin user, origin
    folder = user.root_folder
    if origin then
      user.x_files << origin
      user.save
      folder.files << origin
      folder.save
      origin.save
    end
    origin
  end

  ##
  # Share a file to another user.
  def self.share_to_user current_user, user, origin
    if origin && user then
      user.x_files_shared_to_me << origin
      user.save
      current_user.x_files_shared_by_me << origin
      current_user.save
      origin.save
    end
    origin
  end

  ##
  # Unshare a file to another user.
  def self.unshare_to_user current_user, user, origin
    SharedToMeAssociation.all(x_file_id: origin.id, user_id: user.id).destroy! if origin && user
    SharedByMeAssociation.all(x_file_id: origin.id, user_id: current_user.id).destroy! if origin && current_user
    origin
  end

  ##
  # Move a file into a destination folder
  def self.move file, source, destination
    FileFolderAssociation.all(file_id: file.id, parent_id: source.id).each do |asso|
      asso.parent_id = destination.id
      asso.save
    end
  end

  ##
  # Update the given file, save it and update its parent recursively 
  def update_and_save
    self.last_update = Time.now
    self.save!

    self.parents.each do |parent|
      parent.update_and_save
    end
  end

  ##
  # Update the parent of the given file and remove its children and itself
  def update_and_delete user
    self.parents.each do |parent|
      parent.update_and_save
    end
    self.delete user
    user.save
  end

end
