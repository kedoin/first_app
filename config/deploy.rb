set :application, "first_app"
set :repository,  "git@github-first_app:kedoin/first_app.git"
# looks like git is being run on my laptop, not on the server...
set :local_repository,  "git@github.com:kedoin/first_app.git"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :scm, 'git'

role :web, "kedoin.com"                          # Your HTTP server, Apache/etc
role :app, "kedoin.com"                          # This may be the same as your `Web` server
role :db,  "kedoin.com", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

# more boilerplate for kedoin.com
require "bundler/capistrano" 

set :user, 'kedoinco'                                 # NEEDED. Without tries to ssh as "rob"
ssh_options[:keys] = %w('/Users/rob/.ssh/kedoin.key') # NEEDED. Without it doesn't attempt key exchange
                                                      # The path is irrelevant. The array can be empty.
                                                      # All keys found in .ssh are checked.
#ssh_options[:verbose] = :debug                       # Useful to find out why SSH isn't working

default_run_options[:pty] = true                      # NEEDED. deploy:setup failed without it

set :deploy_via, :remote_cache                        # recommended by GitHub

set :deploy_to, "/home/kedoinco/#{application}"
set :use_sudo, false
set :group_writable, false
after 'deploy:update_code' do
    desc "Ensure proper permissions and Passenger-required .htaccess"
    run "chmod 755 #{release_path}/public"
    run "echo 'RackBaseURI /' >> #{release_path}/public/.htaccess"
    run "echo 'PassengerAppRoot #{current_path}' >> #{release_path}/public/.htaccess"
end
# end kedoin.com boilerplate