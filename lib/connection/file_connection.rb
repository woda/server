require 'eventmachine'
require 'connection/parser/serializer'
require 'connection/connection_protocol'
require 'controllers/users_controller'
require 'tempfile'

BUF_SIZE = 2048

# TODO: handle connection errors.
class FileConnection < EventMachine::Connection


  def initialize
    @username = nil
    @user = nil
    @connected = false
    @file = nil
    @buffer = StringBuffer.new
    @controller = nil
  end

  def receive_data data
    @buffer << data
    if !@controller then
      self.continue_connection
    end
    # We might have connected successfully thanks to continue_connection
    if @controller && @buffer.length > BUF_SIZE
      @file.write(@buffer.read)
    end
  end

  def continue_connection
    line = @buffer.nextline
    line.chomp!
    if !@user then
      @username = line
      @user = User.first login: @username
      # TODO: handle errors
    elsif !@connected then
      @connected = @user.has_password? line
      # TODO: handle errors
    elsif !@controller then
      @controller = SyncController[line]
      @file = Tempfile.new 'woda'
      # TODO: handle errors (users can steal others' controller...)
    end
  end

  def connection_completed
    @file.write(@buffer.read)
    @controller.file_received(self)
  end
end

class FileSslConnection < ClientConnection
  def post_init
    super
    start_tls
  end
end
