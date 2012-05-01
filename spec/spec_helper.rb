# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper.rb"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
require 'simplecov'
SimpleCov.start
SimpleCov.at_exit do
  SimpleCov.result.format!
  exit 2 if SimpleCov.result.covered_percent < 88
end

ENV['WODA_ENV'] = 'test'

require 'pathname'
require_relative '../lib/environment'

def require_corresponding file
  path = Pathname(file).relative_path_from(Pathname.new(File.expand_path("..", __FILE__))).to_s
  path = path.split("/")[1..-1]
  path[-1].gsub!(/_spec.rb$/, ".rb")
  path = path.join '/'
  path = File.expand_path("../../lib/#{path}", __FILE__)
  require path
end

require 'dm-transactions'

RSpec.configure do |config|
  config.failure_exit_code = 20

  config.before(:each) do
    DataMapper.auto_migrate!
  end

  config.around(:each) do |example|
    User.transaction do |t|
      example.run
      t.rollback
    end
  end
end
