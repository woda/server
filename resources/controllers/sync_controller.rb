require File.join(File.dirname(__FILE__), "..", "models/sync")

class SyncController
  attr_accessor :sync, :connection


  def initialize(connection)
    @sync = nil
    @connection = connection
    @token = nil
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
                                        "filename"=>@sync.path,
                                        "content_hash"=>@sync.hexhash,)
    puts json_data[1..json_data.size-2]
    @connection.put_data json_data[1..json_data.size - 2]
    
    res = @connection.get_data
    res = JsonController.new(res)
    puts res.inital_string
    if res.error?
     puts "Something went wrong. We can't synchronize the file with Woda's cloud".red
     puts "** Server response: " + res.get("message").yellow
     return false # uncomment after testing
    end
    if res.get("type") == "file_add_successful"
      puts "File added successfuly, don't need to upload"
      return false
    elsif res.get("type") == "file_need_upload"
      puts "We need to upload file"
      @token =  res.get("token")
      return true
    end
    return false
  end

  def sync_end    
     res = @connection.get_data
     res = JsonController.new(res)
     puts res.inital_string
     if res.error?
      puts "Something went wrong. We can't synchronize the file with Woda's cloud".red
      puts "** Server response: " + res.get("message").yellow
      return false # uncomment after testing                                                                                    
     end
    puts "Sync ended successfully".green
    return true
  end
  
  def server_confirmation
    res = @connection.get_data
    res = JsonController.new(res)
    puts res.inital_string
    if res.error?
      puts "Something went wrong. We can't synchronize the file with Woda's cloud".red
      puts "** Server response: " + res.get("message").yellow
      return false # uncomment after testing                                                                                    
    end
    if res.get("type") == "file_add_successful"
      puts "Server confirm :" + "File added successfuly".green
    end
    return true
  end
  
  def synchronize
    ## TODO
    ## Get the new port for the sending from the server response
    ## Open a TCPServer socket
    data_connection = Connection.new
    puts "Connecting to data socket..."
    if data_connection.connectToHost(ARGV[0], ARGV[1].to_i + 1) == false
      puts "Failed to connection to data stream".red
      return false
    end
    begin
#      puts "Need to Upload " + @sync.size
      puts "Uploading.. in progress".yellow
      puts @token
      data_connection.write_binary(@token+"\n")
     while @sync.eof == false
        buffer = @sync.read(10000)
       puts buffer.size
        data_connection.write_binary(buffer)
      end
    rescue
      puts "Failed to upload a file!".red
      data_connection.disconnectFromHost
      return false
    end
    data_connection.disconnectFromHost
    if sync_end == false || server_confirmation == false
      return false
    end
    puts "Upload complete".green
    return true
  end
end
