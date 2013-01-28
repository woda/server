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

server "ec2-54-242-98-168.compute-1.amazonaws.com", :app, :db, :primary => true

set :use_sudo, true

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

set :runner, nil

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

DIST_PATH = '/var/serv/current'

namespace :deploy do
  task :migrate do run "cd #{DIST_PATH}; WODA_ENV=prod bundle exec rake upgrade" end
  task :start do run "cd #{DIST_PATH}; script/start_server" end
  task :stop do run "cd #{DIST_PATH}; script/stop_server" end
  task :restart do run "cd #{DIST_PATH}; script/stop_server; script/start_server" end
end
namespace :db do
  # TODO: find a clean way not to expose the credentials to the developpers, for instance
  # by storing the database.yml file on the server and only creating the link
  task :setup do
    run "mkdir -p #{shared_path}/config"

    # configuring database
    yaml = <<-EOF
    prod:
        addr: postgres://postgres:klWEbbVX49$Z@localhost/prod
    EOF
    put yaml, "#{shared_path}/config/database.yml"

    # configuring emails
    yaml = <<-EOF
    dev:
      tls: true
      address: "smtp.gmail.com"
      port: 587
      domain: "smtp.gmail.com" # 'your.domain.com' for GoogleApps
      user_name: "redmine.woda@gmail.com"
      password: "RedmineWodaMail"
    EOF
    put yaml, "#{shared_path}/config/mail.yml"
  end
  task :symlink, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after "deploy:setup",           "db:setup"   unless fetch(:skip_db_setup, false)
after "deploy:finalize_update", "db:symlink"

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
