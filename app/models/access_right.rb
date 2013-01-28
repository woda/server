require 'data_mapper'
require 'models/base/woda_resource'

class AccessRight
  include DataMapper::Resource

  storage_names[:default] = "AccessRight"

  property :access, Flag[:read, :write, :execute]

  belongs_to :user, key: true
  belongs_to :w_file, key: true
end
