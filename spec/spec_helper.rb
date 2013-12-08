require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

@saved_session = nil

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

def db_clear
  # => DataMapper::Model.descendants.each {|model| model.destroy!}
  Folder.destroy!
  XFile.destroy!
  User.destroy!
end

def put_description
  puts "\nTesting #{self.class.description}\n"
end

def get_user
  session[:user] = User.first id: session[:user] if session[:user]
end

def create_user(params)
  return nil unless params.is_a? Hash

  pwd = params[:password]
  params.delete :password
  user =  User.new(params)
  user.set_password pwd
  user.save
  user.create_root_folder
  session[:user] = user.id
  user
end

def require_login
  session[:user].should_not be_nil
end

def get_json
  JSON.parse response.body
end

def generate_files(user)
  user.create_folder("/Movies/")
  user.create_folder("/Movies/MKV/English")
  user.create_folder("/Movies/MKV/French")
  user.create_folder("/Movies/AVI/English")
  user.create_folder("/Movies/AVI/French")

  user.create_file("/FileInRoot.txt")
  user.create_file("/Movies/Youtube_Funny_Jokes.flv")
  user.create_file("/Movies/Clip_Video_Teletubies.mpeg")
  user.create_file("/Movies/Power_Rangers.flv.")
  user.create_file("/Movies/Pokemon.flv")

  user.create_file("/Movies/MKV/English/Avatar_(2010).mkv")
  user.create_file("/Movies/MKV/English/The_Lord_Of_The_Ring.mkv")
  user.create_file("/Movies/MKV/English/Inception.mkv")
  user.create_file("/Movies/MKV/English/Gravity.mkv")
  user.create_file("/Movies/MKV/French/Asterix_Mission_Cleopatre.mkv")
  user.create_file("/Movies/MKV/French/Brice_De_Nice.mkv")
  user.create_file("/Movies/MKV/French/Jeux_Enfant.mkv")
  user.create_file("/Movies/MKV/French/Asterix_Chez_Les_Bretons.mkv")

  user.create_file("/Movies/AVI/English/Harry_Potter_The_Chamber_Of_Secret.avi")
  user.create_file("/Movies/AVI/English/Xmen_Origins.avi")
  user.create_file("/Movies/AVI/English/Gravity.avi")
  user.create_file("/Movies/AVI/English/Batman_Begins.avi")
  user.create_file("/Movies/AVI/French/Asterix_Le_Gaulois.avi")
  user.create_file("/Movies/AVI/French/Qui_A_Tue_Pamela_Rose.avi")
  user.create_file("/Movies/AVI/French/OSS_117_Le_Caire_Nid_Despion.avi")
  user.create_file("/Movies/AVI/French/OSS_117_A_Rio.avi")
end

def save_session
  @saved_session = session[:user]
end

def load_session
  session[:user] = @saved_session
  @saved_session = nil
end

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:suite) { DataMapper.auto_migrate! }
end
