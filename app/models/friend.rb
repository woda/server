require 'data_mapper'
require 'app/models/base/woda_resource'
require 'app/models/User'

##
# The Friend model represents a friend of a user just with the id it.
class Friend
  include DataMapper::Resource
  include WodaResource
  
  storage_names[:default] = "friend"

  property :id, Serial, key: true
  
  property :friend_id, Integer, unique: false, unique_index: true, key: true

  belongs_to :user

  ##
  # Friend description
  def description
    { id: self.id, user: self.user.id, friend: friend_id }
  end

  ##
  # Destroy a friend
  def delete
    self.destroy!
  end

end
