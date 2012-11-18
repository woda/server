require 'digest'

# Etablie le lien
# {"action":"sync/put","content_hash":"27249918282","filename":"/path/to/file/bonjourlemonde.txt"}
# Reponse
#
#

class Sync
  attr_accessor :file, :name, :hash, :hexhash
  @file = nil

  def initialize(file_name)
    @name = File.basename(file_name)
    @file = File.open file_name, "rb"
    @hash = Digest::SHA256.file(file_name)
    @hexhash = @hash.hexdigest
  end

  def self.open(file_name)
    file_name = File.absolute_path(File.expand_path(file_name)) if file_name.nil? == false
    if file_name.nil? || File.exists?(file_name) == false
      puts "Can't reach or read the file".red
      return nil
    end
    Sync.new file_name
  end

  def read(size)
    return @file.read(size)
  end
  
  def eof
   return @file.eof?
  end

  def path
    @file.path
  end

  def asbolute_path
    @file.absolute_path @name
  end

  def directory
    @file.dirname @name
  end

  def ext
    @file.extname @name
  end

  def hexhash
    @hexhash
  end
  
end
