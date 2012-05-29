require 'data_mapper'

class AccessRight
  include DataMapper::Resource

  storage_names[:default] = "AccessRight"

  property :access, Flag[:read, :write, :execute]

  belongs_to :user, key: true
  belongs_to :file, key: true
end
