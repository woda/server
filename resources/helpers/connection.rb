require 'timeout'

class Connection
  attr_accessor :timout, :serverSocket

  def initialize (t = 10)
   @timout = t
  end

  def connectToHost(host, port, t = 5)
    @timout = t
    begin
      timeout(@timout) do
        socket = TCPSocket.new(host, port)
        sslContext = OpenSSL::SSL::SSLContext.new
        @serverSocket = OpenSSL::SSL::SSLSocket.new(socket, sslContext)
        @serverSocket.sync_close = true
        @serverSocket.connect
      end
    rescue Timeout::Error
      return false
    end
    return true
 end

  def disconnectFromHost
    @serverSocket.close
    puts @serverSocket.state
  end

  def put_data(data)
    @serverSocket.puts data
  end

  def write_binary(data)
    @serverSocket.write data
  end
  
  def get_data
    begin
      timeout(@timout) do
        @serverSocket.gets
      end
    rescue Timeout::Error
      puts "** Server closes the connection"
    end
  end
end
