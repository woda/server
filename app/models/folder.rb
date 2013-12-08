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

  belongs_to :user, required: false

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

  def delete
    self.files.each { |item| item.delete }
    self.childrens.each { |children| children.delete }

    FileUserAssociation.all(x_file_id: self.id).destroy!
    FolderFolderAssociation.all(parent_id: self.id).destroy!
    FolderFolderAssociation.all(children_id: self.id).destroy!
    FileFolderAssociation.all(parent_id: self.id).destroy!

    super
  end

end
