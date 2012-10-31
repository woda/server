require 'timeout'

class Connection
  attr_accessor :timout, :serverSocket

  def initialize(host, port, t = 5)
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
      puts "** Server does not respond. is it online ? Try again later".red
      exit
    end
    @serverSocket.puts("json");
    
    line = @serverSocket.gets
    line = JsonController.new(line)
    if (line.error?)
      puts "[CONNECTION ERROR]: Server response was negative for connection"
      puts "\t\t\tPlease try again later"
      exit
    end
    
  end
  
  def puts(data)
    @serverSocket.puts data
  end

  def gets
    begin
      timeout(@timout) do
        @serverSocket.gets
      end
    rescue Timeout::Error
      puts "** Server closes the connection"
    end
  end
end
