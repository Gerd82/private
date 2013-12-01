application = 'weihnachten'
set :application, application
set :repo_url, 'git@github.com:Gerd82/private.git'
set :branch, "master"
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'
set :deploy_to, '/ruby_projects/weihnachten'
set :deploy_via, :remote_cache
set :scm, :git
set :use_sudo, false
set :sudo, "sudo -u gerhard -i"

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# default_run_options[:pty] = true
# ssh_options[:forward_agent] = true
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_stage, "production"
set :keep_releases, 5

# for RoR 4
set :default_env, { rvm_bin_path: '~/.rvm/bin' }
set :bundle_gemfile, -> { release_path.join('Gemfile') }
set :bundle_dir, -> { shared_path.join('bundle') }
set :bundle_flags, ''
set :bundle_without, %w{test development}.join(' ')
set :bundle_binstubs, -> { shared_path.join('bin') }
set :bundle_roles, :all

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command do
      # on roles(:app), except: {no_release: true} do |host|
      #   execute "/etc/init.d/unicorn_#{application} #{command}"
      # end
      invoke "unicorn:#{ command }"
    end
  end

  task :setup do

  end

  task :setup_config do
    on roles(:app) do
      # execute :ln, '-nfs', "#{current_path}/config/nginx.conf", "/etc/nginx/sites-enabled/#{application}"
      # execute :ln, '-nfs', "#{current_path}/config/unicorn_init.sh", "/etc/init.d/unicorn_#{application}"
      execute :mkdir, '-p', "#{shared_path}/config"
      # put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
      # puts "Now edit the config files in #{shared_path}."
    end
  end
  after :setup, "deploy:setup_config"

  task :symlink_config do
    on roles(:app) do
      # run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end
  after "deploy:updated", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:web) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end
  before "deploy", "deploy:check_revision"
end 