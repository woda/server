require 'data_mapper'

class Device
  include DataMapper::Resource
  include WodaResource

  storage_names[:default] = "Device"

  updatable_property :uuid, DataMapper::Types::UUID, key: true
  updatable_property :total_space, Integer
  updatable_property :free_space, Integer
  property :time_connected_last_month, Integer
  property :last_connection_time, DateTime
  property :has_deleted_blocks, Boolean

  belongs_to :user

  has n, :blocks
end
