set :application, "Woda server"
require 'capistrano-offroad'
require 'capistrano-offroad/modules/defaults'
set :repository,  "ssh://git@tango-mango.net:5220/woda_serv.git"

set :rvm_ruby_string, '1.9.3'
set :rvm_install_shell, :bash

before 'deploy', 'rvm:install_ruby'
set :rvm_install_ruby_threads, 1
set :rvm_type, :system

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :ssh_options, {:forward_agent => true}

set :port, 5220

set :deploy_to, "/var/serv"

server "woda-server.tango-mango.net", :app, :db, :primary => true

set :use_sudo, false

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

set :runner, nil

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :migrate do Kernel.system "bundle exec rake upgrade" end
  task :start do Kernel.system "script/start_server" end
  task :stop do Kernel.system "script/stop_server" end
  task :restart do Kernel.system "script/stop_server; script/start_server" end
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
