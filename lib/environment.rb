require 'set'
require 'bundler'
Bundler.setup

$: << "#{File.dirname(__FILE__)}"

# The valid values are :test, :dev and :prod
def determine_environment
  return ENV['WODA_ENV'].to_sym if ENV['WODA_ENV']
  :dev
end

ENVIRONMENT = determine_environment

def assert_good_environment env
  unless Set.new([:dev, :prod, :test]).include? env
    puts "Error: unknown environment: #{env}"
    exit 1
  end
end

assert_good_environment ENVIRONMENT

require 'active_support/all'
require 'controllers/base/base.rb'
require 'data_mapper'
require 'dm-migrations'
require 'helpers/data_mapper_ext.rb'
require 'yaml'
#require 'active_column'

# TODO: Need to use the configuration file
#$cassandra = Cassandra.new 'woda_dev'

#ActiveColumn.connection = $cassandra

class Server
  def self.root
    File.expand_path "../..", __FILE__
  end
end

config = YAML::load File.read("#{Server.root}/config/database.yml")

DataMapper::Property.required(true)
DataMapper::Model.raise_on_save_failure = true

DataMapper::Logger.new($stdout, ENVIRONMENT == :test ? :fatal : :info)
DataMapper.setup(:default, config[ENVIRONMENT.to_s]['addr'])

models_dir = File.expand_path "../models", __FILE__
Dir.glob("#{models_dir}/**/*.rb").each do |file|
  require file
end

DataMapper.finalize

DataMapper.auto_upgrade!
