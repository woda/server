set :application, "Woda server"
require 'capistrano-offroad'
require 'capistrano-offroad/modules/defaults'
set :repository,  "git@github.com:woda/server.git"

set :user, "ubuntu"

set :rvm_ruby_string, '1.9.3'
set :rvm_install_shell, :bash

before 'deploy:setup', 'rvm:install_rvm'
set :rvm_install_with_sudo, true
before 'deploy:setup', 'rvm:install_ruby'
before 'deploy', 'rvm:install_ruby'
set :rvm_install_ruby_threads, 1
set :rvm_type, :system
set :rvm_install_ruby, :install

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :ssh_options, {:forward_agent => true, :keys=>["#{ENV['HOME']}/.ssh/id_rsa", './server.pem']}
set :branch, 'master'

set :port, 22

set :deploy_to, "/var/serv"
set :deploy_via, :copy
set :copy_strategy, :export
set :deploy_group, "rvm"

server "ec2-54-242-50-191.compute-1.amazonaws.com", :app, :db, :primary => true

set :use_sudo, true

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"
before "deploy:update", 'deploy:update_timestamp'

set :runner, nil

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

DIST_PATH = '/var/serv/current'

namespace :deploy do
  task :update_timestamp do run "sudo ntpdate -b pool.ntp.org" end
  task :migrate do run "cd #{DIST_PATH}; cp config/database.yml.example config/database.yml; /usr/local/rvm/bin/rvm 1.9.3 do bundle exec rake db:autoupgrade" end
  task :start do run "cd #{DIST_PATH}; cp config/database.yml.example config/database.yml; script/start_server" end
  task :stop do run "cd #{DIST_PATH}; script/stop_server" end
  task :restart do run "cd #{DIST_PATH}; script/stop_server; cp config/database.yml.example config/database.yml; script/start_server" end
end

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
require 'rvm/capistrano'
require 'bundler/capistrano'
