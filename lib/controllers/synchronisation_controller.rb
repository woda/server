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
  before [:check_params, :size], :upload

  @@files = {}

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
  
  def upload
    @connection
  end

  def put
    LOG.info "Adding file: #{param['filename']} for user #{@connection.data[:current_user].login}"
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
    LOG.info "Removing file #{param['filename']}"
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
    LOG.info "A file like #{f.filename} already exists"
    f.content = content
    # This is temporary, when we check for the salted hash thing there will be
    # more stuff in this function
    connection.data[:current_user].files << f
    connection.data[:current_user].save
    connection.send_message :file_add_successful
  end

  def add_new_file f
    LOG.info "Requesting upload of file #{f.filename}"
    f.content = Content.new content_hash: param['content_hash']
    f.user = @connection.data[:current_user]
    token = SecureRandom.base64(64)
    @@files[token] = OpenStruct.new(file: f, controller: self)
    connection.send_message :file_need_upload, token: token
  end

  def compute_hash(file)
    FileSyncResults.new(file)
  end

  def on_file_splitted results, file
    connection.error_bad_hash unless results.hash == file.content.content_hash
    file.content.crypt_key = WodaCrypt.new.random_key.to_hex
    file.content.init_vector = WodaCrypt.new.random_iv.to_hex
    file.content.size = results.size
    file.save
    connection.send_message :file_add_successful
    error_bad_hash unless results.hash == file.content.content_hash
    connection.send_message :file_synced
  end

  def sync_received_file tmpfile, file_in_db
    return FileSyncResults.new tmpfile
  end

  def file_received fileco
    # TODO: send some indication that we received the file
    file = fileco.tmpfile
    file.seek 0
    file_database = fileco.file
    EM.defer Proc.new { self.sync_received_file(file, file_database) }, Proc.new { |results| on_file_splitted results, file_database }
    connection.send_message :file_received
  end
end

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
