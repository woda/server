require 'eventmachine'
require 'connection/parser/serializer'
require 'connection/connection_protocol'
require 'controllers/users_controller'
require 'controllers/synchronisation_controller'
require 'tempfile'
require 'helpers/stringbuffer'

BUF_SIZE = 2048

##
# This is a secondary connection that is used to transfer the files.
# When a file needs transfering, it is assigned a token. Then a
# FileConnection is opened which receives the token on a single line,
# then the whole file until the connection is closed. When it is closed,
# it is assumed the whole file was transfered.
class FileConnection < EventMachine::Connection
  attr_reader :file, :tmpfile, :token

  def initialize
    @buffer = StringBuffer.new
    @file = nil
    @tmpfile = nil
    @controller = nil
  end

  ##
  # Standard eventmachine callback. Receives the data as a string calls the appropriate
  # function to process it
  def receive_data data
    @buffer << data
    if !@file then
      self.continue_connection
    end
    # We might have connected successfully thanks to continue_connection
    if @controller && @buffer.length > BUF_SIZE
      @tmpfile.write(@buffer.read)
    end
  end

  ##
  # This function tries to read the file token from the data. This file token
  # is a unique id associated with the file and that is sufficiently secure
  # to be the only form of identification needed.
  def continue_connection
    line = @buffer.nextline
    return unless line
    line.chomp!
    @token = line
    data = SyncController[@token]
    unless data
      send_data 'Invalid token!'
      close_connection_after_writing
    end
    @file = data.file
    @controller = data.controller
    @tmpfile = File.new("/tmp/woda_file_#{@file.content.content_hash}", 'w+')
  end

  ##
  # Flushes everything when the connection is closed.
  def unbind
    @tmpfile.write(@buffer.read)
    @controller.file_received(self)
  end
end

##
# SSL version of FileConnection
class FileSslConnection < FileConnection
  def post_init
    super
    start_tls
  end
end
