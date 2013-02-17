require 'data_mapper'
require 'app/models/base/woda_resource'

class AccessRight
  include DataMapper::Resource

  storage_names[:default] = "AccessRight"

  property :access, Flag[:read, :write, :execute]

  belongs_to :user, key: true
  belongs_to :folder, key: true, required: false
  belongs_to :x_file, key: true, required: false
end
