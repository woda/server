require File.join(File.dirname(__FILE__), "..", "models/sync")


class SyncController
  attr_accessor :sync, :connection

  def initialize(sync, connection)
    @sync = sync
    @connection = connection
  end

  def self.get_file_list
    
  end

  def sync(command)
    sync @sync if sync == nil
    
    sync_file if get_autorisation == true
  end

  
  private
  def get_autorisation
    json_data = JsonController.generate("action"=>"sync/put",
                                        "content_hash"=>sync.hexhash,
                                        "path"=>@sync.path)
  
    @connection.puts json_data[1..json_data.size - 2]
    
    res = @connection.gets
    res = JsonController.parse(res)
    if res.error?
      puts "Something wrong happened. We can't synchronize the file with Woda's cloud".red
      puts "** Server response: " + res.message.yellow
      return false
    end
    return true
  end

  def sync_file
    puts "Sending file: 42%"
  end
end
