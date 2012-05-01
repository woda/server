require 'active_support/all'
require 'controllers/base/base.rb'
#require 'active_column'

# TODO: Need to use the configuration file
#$cassandra = Cassandra.new 'woda_dev'

#ActiveColumn.connection = $cassandra

class Server
  def self.root
    File.expand_path "../..", __FILE__
  end
end
