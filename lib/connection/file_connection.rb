require 'eventmachine'
require 'connection/parser/serializer'
require 'connection/connection_protocol'
require 'controllers/users_controller'
require 'controllers/synchronisation_controller'
require 'tempfile'
require 'helpers/stringbuffer'

BUF_SIZE = 2048

# TODO: handle connection errors.
class FileConnection < EventMachine::Connection
  attr_reader :file, :tmpfile, :token

  def initialize
    @buffer = StringBuffer.new
    @file = nil
    @tmpfile = nil
    @controller = nil
  end

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
    @tmpfile = Tempfile.new('woda_file')
  end

  def unbind
    @tmpfile.write(@buffer.read)
    @controller.file_received(self)
  end
end

class FileSslConnection < FileConnection
  def post_init
    super
    start_tls
  end
end
