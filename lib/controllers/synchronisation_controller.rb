require 'models/file'
require 'helpers/hash_digest'
require 'connection/client_connection'
require 'securerandom'

class SyncController < Controller::Base
  actions :put, :get, :delete, :change, :upload
  before :check_authenticate, :put, :get, :delete, :change
  before [:check_param, :content_hash, :filename], :put, :change
  before [:check_param, :filename], :get, :delete
  before [:check_param, :size], :upload

  @@controllers = {}

  def self.[] uuid
    @@controllers[uuid]
  end

  def initialize connection
    super
    @uuid = SecureRandom.uuid
    @@controllers[@uuid] = self
  end

  def destroy
    @@controllers.delete uuid
  end

  def model
    WFile
  end
  
  def upload
    @connection
  end

  def put
    current_content = Content.first content_hash: param['content_hash']
    f = WFile.new(filename: param['filename'],
                  last_modification_time: DateTime.now)
    if current_content
      add_existing_file f, current_content
    else
      add_new_file f
    end
  end

  def change
    delete
    put
  end

  def delete
    f = WFile.first filename: param['filename'], user_id: connection.data[:current_user]
    destroy_content = nil
    if WFile.count(content_id: f.content.id) == 1 then
      destroy_content = f.content
    end
    file.destroy
    if destroy_content then
      f.content.blocks.each do |b|
        b.deleted = true
        b.save
      end
      # Warning: this is going to delete all the blocks, which is clearly not
      # what we want
      destroy_content.destroy
    end
  end
  
  # Note: we should add an additional security step here to prevent people from
  # being able to get another user's file content by pretending to have a file
  # with the same hash. The solution would be to store another hash which would
  # be salted, and to ask the client to give us the hash with the salt. If he
  # does, then he probably has the file.
  def add_existing_file f, content
    f.content = content
    # This is temporary, when we check for the salted hash thing there will be
    # more stuff in this function
    connection.data[:current_user].files << f
    connection.data[:current_user].save
    connection.send_message :file_add_successful
  end

  def add_new_file f
    @current_file = f
    connection.send_message :file_need_upload
  end

  def file_received fileco
    # TODO: send some indication that we received the file
    # TODO: write this
  end
end
