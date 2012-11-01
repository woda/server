require File.join(File.dirname(__FILE__), "..", "models/sync")


class SyncController
  attr_accessor :sync, :connection

  def initialize(connection)
    @sync = nil
    @connection = connection
  end

  def self.get_file_list
    
  end

  def sync(command)
    @sync = Sync.open command[2]
    return if @sync == nil
    synchronize if sync_autorisation? == true
  end
  
  private
  def sync_autorisation?
    json_data = JsonController.generate("action"=>"sync/put",
                                        "content_hash"=>@sync.hexhash,
                                        "path"=>@sync.path)
    puts json_data[1..json_data.size-2]
    @connection.puts json_data[1..json_data.size - 2]
    
    res = @connection.gets
    res = JsonController.new(res)
    if res.error?
      puts "Something went wrong. We can't synchronize the file with Woda's cloud".red
      puts "** Server response: " + res.message.yellow
      return false
    end
    return true
  end

  def synchronize
    ## TODO
    ## Get the new port for the sending from the server response
    ## Open a TCPServer socket
    puts "Sending file: 42%"
  end
end
