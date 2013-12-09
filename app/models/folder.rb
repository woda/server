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

  def delete current_user
    raise RequestError.new(:internal_error, "Delete: no user specified") if current_user.nil?

    self.files.each { |item| item.delete current_user }
    self.childrens.each { |children| children.delete current_user }

    if current_user.id != self.original_user_id then # if random owner 
      FileUserAssociation.all(x_file_id: self.id, user_id: current_user.id).destroy!
      FolderFolderAssociation.all(children_id: self.id).each do |asso|
        asso.destroy! if current_user.x_files.get(asso.parent_id)
      end
    else # if true owner 
      FileUserAssociation.all(x_file_id: self.id).destroy!
      # FolderFolderAssociation.all(parent_id: self.id).destroy!
      FolderFolderAssociation.all(children_id: self.id).destroy!
      # FileFolderAssociation.all(parent_id: self.id).destroy!
      self.destroy!
    end
  end

end
