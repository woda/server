set :application, "Woda server"

require 'rvm/capistrano'
require 'bundler/capistrano'
require 'capistrano-offroad'
require 'capistrano-offroad/modules/defaults'

default_run_options[:pty] = true

set :repository,  "git@github.com:woda/server.git"
set :user, "kevin"
set :password, "kikoolol"
server "kobhqlt.fr", :app, :db, :primary => true

before 'deploy:setup', 'rvm:install_ruby'
before 'deploy:setup', 'rvm:install_rvm'
#before 'deploy', 'rvm:install_ruby'

after "deploy:restart", "deploy:cleanup"

set :rvm_ruby_string, '1.9.3'
set :rvm_install_shell, :bash

set :rvm_install_ruby_threads, 1
set :rvm_install_with_sudo, true
set :rvm_type, :system
set :rvm_install_ruby, :install

set :scm, :git
# set :ssh_options, {:forward_agent => true, :keys=>["#{ENV['HOME']}/.ssh/id_rsa", './server.pem']}
set :branch, 'new_architecture'

set :port, 22

set :deploy_to, "/home/wodaserver"
set :deploy_via, :remote_cache
set :copy_strategy, :export
set :deploy_group, "rvm"
set :use_sudo, true

set :runner, nil

DIST_PATH = '/var/serv/current'

namespace :deploy do
  task :update_timestamp do run "sudo ntpdate -b pool.ntp.org" end
  task :migrate do run "cd #{DIST_PATH}; cp config/database.yml.example config/database.yml; /usr/local/rvm/bin/rvm 1.9.3 do bundle exec rake db:autoupgrade" end
  task :start do run "cd #{DIST_PATH}; cp config/database.yml.example config/database.yml; script/start_server" end
  task :stop do run "cd #{DIST_PATH}; script/stop_server" end
  task :restart do run "cd #{DIST_PATH}; script/stop_server; cp config/database.yml.example config/database.yml; script/start_server" end
end