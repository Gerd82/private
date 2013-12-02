RAILS_ROOT = "/ruby_projects/weihnachten/current"
rails_env = ENV['RAILS_ENV'] || 'production'

PIDS = RAILS_ROOT + "/tmp/pids"
Dir.mkdir(PIDS) unless Dir.exists?( PIDS )

working_directory RAILS_ROOT
pid PIDS + "/unicorn.pid"
stderr_path RAILS_ROOT + "/log/unicorn.stderr.log"
stdout_path RAILS_ROOT + "/log/unicorn.stdout.log"

preload_app true
listen "/tmp/unicorn.weihnachten.socket", :backlog => 64
worker_processes 4
timeout 30

before_fork do |server, worker|
  pid_old = PIDS + '/unicorn.pid.oldbin'
  if File.exists?(pid_old) && server.pid != pid_old
    begin
      Process.kill("QUIT", File.read(pid_old).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
  begin
    uid, gid = Process.euid, Process.egid
    user, group = 'deployer', 'deployer'
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid
    worker.tmp.chown(target_uid, target_gid)
    if uid != target_uid || gid != target_gid
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue => e
    if RAILS_ENV == 'development'
      STDERR.puts "Cannot change Unicorn's worker UID/GID in development environment."
    else
      raise e
    end
  end
end