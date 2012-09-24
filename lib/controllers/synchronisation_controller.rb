require 'models/file'
require 'helpers/hash_digest'
require 'connection/client_connection'

class SyncController < Controller::Base
  actions :put, :get, :delete, :change
  before :check_authenticate, :put, :get, :delete, :change
  before [:check_param, :content_hash, :filename], :put, :change
  before [:check_param, :filename], :get, :delete
  
  def model
    File
  end
  
  def put
    current_content = Content.first content_hash: param['content_hash']
    f = File.new(filename: param['filename'],
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
    f = File.first filename: param['filename'], user_id: connection.data[:current_user]
    destroy_content = nil
    if File.count(content_id: f.content.id) == 1 then
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
    
  end
end
