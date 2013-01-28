# Load the rails application
require File.expand_path('../application', __FILE__)

$: << "#{File.dirname(__FILE__)}/.."

# Initialize the rails application
Server::Application.initialize!
