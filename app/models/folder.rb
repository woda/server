require 'data_mapper'
require 'app/models/base/woda_resource'
require 'app/models/xfile'
require 'app/models/association'
require 'app/models/file'

class WFolder < XFile
  include DataMapper::Resource
  include WodaResource

  storage_names[:default] = "xfile"

  property :id, Serial, key: true

  has n, :file_folder_associations, child_key: [:parent_id]
  has n, :files, 'WFile', through: :file_folder_associations, via: :file

  # in this relationship, self is the child of someone
  has n, :link_to_parents, 'FolderFolderAssociation', child_key: [:children_id]
  # in this relationship, self is the parent of someone
  has n, :link_to_childrens, 'FolderFolderAssociation', child_key: [:parent_id]

  has n, :parents, self, through: :link_to_parents, via: :parent
  has n, :childrens, self, through: :link_to_childrens, via: :children

  def initialize *args, &block
    super *args, &block
    self.folder = true
  end

  ##
  # Delete the current folder and all its associations
  def delete current_user
    raise RequestError.new(:internal_error, "Delete: no user specified") if current_user.nil?

    # remove all its files
    self.files.each { |item| item.delete current_user }
    # remove all its children, meaning all its subdirectories. (all sub-sub-directories and sub-files will me removed as well)
    self.childrens.each { |children| children.delete current_user }

    if current_user.id != self.user_id then # if random owner 
      # remove all links between this folder and the current user only
      FileUserAssociation.all(x_file_id: self.id, user_id: current_user.id).destroy!
      # remove all associations where this folder is a children of a folder belonging to the current user only
      FolderFolderAssociation.all(children_id: self.id).each do |asso|
        asso.destroy! if current_user.x_files.get(asso.parent_id)
      end
    else # if true owner 
      # remove all links between this folder and ALL users
      FileUserAssociation.all(x_file_id: self.id).destroy!
      # remove all associations where this folder is a children of a folder belonging ALL users
      FolderFolderAssociation.all(children_id: self.id).destroy!

      # there is no need to remove the association where this folder is a parent (of a file or folder) because of the children have already been removed
      # FolderFolderAssociation.all(parent_id: self.id).destroy!
      # FileFolderAssociation.all(parent_id: self.id).destroy!
      
      # now remove the entity
      self.destroy!
    end
  end

  ##
  # Create the root folder for the current user
  def self.create_root user
    folder = WFolder.new(name: "/", last_update: DateTime.now, user: user)
    user.x_files << folder
    user.root_folder = folder
    folder.save
    user.save
  end

  ##
  # Gets and creates a folder and if it does not exist.
  def self.create user, path
    raise RequestError.new(:bad_param, "Path can't be nil") if path.nil?
    
    path = path.split('/')
    folder = user.root_folder
    path.reject! { |c| c.empty? }
    path.size.times do |i|
      child = folder.childrens.first(name: path[i], folder: true)
      if child.nil? then
          child = WFolder.new(name: path[i], last_update: DateTime.now, user: user)
          user.x_files << child
          user.save
          folder.childrens << child
          folder.save
          child.save
      end
      folder = child
    end
    folder
  end

  ##
  # Move the folder into a destination folder
  def self.move folder, source, destination
    FolderFolderAssociation.all(children_id: folder.id, parent_id: source.id).each do |asso|
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
  end

end
