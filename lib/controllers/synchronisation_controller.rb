require 'models/file'
require 'helpers/hash_digest'
require 'connection/client_connection'
require 'connection/file_connection'
require 'securerandom'
require 'ostruct'

class SyncController < Controller::Base
  actions :put, :get, :delete, :change, :upload
  before :check_authenticate, :put, :get, :delete, :change
  before [:check_params, :content_hash, :filename], :put, :change
  before [:check_params, :filename], :get, :delete

  @@files = {}

  ##
  # Gets the file corresponding to a token
  def self.[] token
    @@files[token]
  end

  def initialize connection
    super
    @files_allocated = []
  end

  def destroy
    @files_allocated.map { |name| @@files.delete(name) }
  end

  def model
    WFile
  end
  
  ##
  # Action: Receives request to add a file.
  # May answer by saying that the file is already there or by asking the user to upload
  def put
    LOG.info "Adding file: #{param['filename']} for user #{@connection.data[:current_user].login}"
    current_content = Content.first content_hash: param['content_hash']
    puts current_content
    f = WFile.new(filename: param['filename'],
                  last_modification_time: DateTime.now)
    if current_content
      add_existing_file f, current_content
    else
      add_new_file f
    end
  end

  ##
  # Action: Modifies a file. This is effectively a delete and a put, and should receive the same parameters
  def change
    delete
    put
  end

  ##
  # Action: Deletes a file.
  def delete
    LOG.info "Removing file #{param['filename']}"
    f = WFile.first filename: param['filename'], user: connection.data[:current_user]
    connection.error_file_not_found unless f
    destroy_content = nil
    if WFile.count(content: f.content) <= 1 then
      destroy_content = f.content
    end
    puts connection.data[:current_user].w_files.delete(f)
    puts f.destroy!
    if destroy_content then
      destroy_content.blocks.each do |b|
        b.deleted = true
        b.save
      end
      # Warning: this is going to delete all the blocks, which is clearly not
      # what we want
      destroy_content.destroy
    end
    connection.send_message(:delete_successful)
  end
  
  ##
  # If a file with the same hash already exists, just use that content.
  def add_existing_file f, content
    LOG.info "A file like #{f.filename} already exists"
    f.content = content
    # This is temporary, when we check for the salted hash thing there will be
    # more stuff in this function
    f.user = connection.data[:current_user]
    f.save
    connection.send_message :file_add_successful
  end

  ##
  # If the hash is new, generate a token and require an upload. The upload
  # is asynchronous and on a FileConnection
  def add_new_file f
    LOG.info "Requesting upload of file #{f.filename}"
    f.content = Content.new content_hash: param['content_hash']
    f.user = @connection.data[:current_user]
    token = SecureRandom.base64(64)
    @@files[token] = OpenStruct.new(file: f, controller: self)
    connection.send_message :file_need_upload, token: token
  end

  ##
  # When the file is fully uploaded, checked and processed, send a success message
  def on_file_splitted results, file
    connection.error_bad_hash unless results.hash == file.content.content_hash
    file.content.crypt_key = WodaCrypt.new.random_key.to_hex
    file.content.init_vector = WodaCrypt.new.random_iv.to_hex
    file.content.size = results.size
    file.save
    connection.send_message :file_add_successful
  end

  ##
  # Computes the temporary file information
  def sync_received_file tmpfile, file_in_db
    return FileSyncResults.new tmpfile
  end

  ##
  # Called when the file is fully received.
  #
  # fileco is the FileConnection object.
  def file_received fileco
    # TODO: send some indication that we received the file
    file = fileco.tmpfile
    file.seek 0
    file_database = fileco.file
    EM.defer Proc.new { self.sync_received_file(file, file_database) }, Proc.new { |results| on_file_splitted results, file_database }
    connection.send_message :file_received
  end
end

##
# Information on a received file. In particular its size and hash.
class FileSyncResults
  attr_reader :hash
  attr_reader :size

  CHUNK_SIZE = 8096

  def initialize(file)
    hash = WodaHash.new
    @size = 0
    until file.eof?
      chunk = file.read(CHUNK_SIZE)
      hash << chunk
      @size += chunk.size
    end
    @hash = hash.to_s
    file.close
  end
end
