require 'data_mapper'

class Device
  include DataMapper::Resource

  storage_names[:default] = "Device"

  property :id, Serial, key: true
  property :total_space, Integer
  property :free_space, Integer
  property :time_connected_last_month, Integer
  property :last_connection_time, DateTime
  property :has_deleted_blocks, Boolean

  belongs_to :user

  has n, :blocks
end
