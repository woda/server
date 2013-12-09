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

  def delete current_user
    raise RequestError.new(:internal_error, "Delete: no user specified") if current_user.nil?

    if current_user.id != self.original_user_id then # if random owner 
      FileUserAssociation.all(x_file_id: self.id, user_id: current_user.id).destroy!
      FileFolderAssociation.all(file_id: self.id).each do |asso|
        asso.destroy! if current_user.x_files.get(asso.parent_id)
      end
    else # if true owner 
      FileUserAssociation.all(x_file_id: self.id).destroy!
      FileFolderAssociation.all(file_id: self.id).destroy!
      self.content.delete if self.content
      self.destroy!
    end
  end

end
