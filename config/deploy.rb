set :application, "Woda server"
set :repository,  "ssh://git@tango-mango.net:5220/woda_serv.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :ssh_options, {:forward_agent => true}

set :port, 5220

set :deploy_to, "/var/serv"

server "woda-server.tango-mango.net", :app, :db, :primary => true

set :use_sudo, false

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

set :deploy_via, :copy
set :runner, :deploy

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
