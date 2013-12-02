RAILS_ROOT = "/ruby_projects/weihnachten"
RAILS_ENV = ENV['RAILS_ENV'] || 'production'
working_directory RAILS_ROOT + "/current"

stderr_path RAILS_ROOT + "/current/log/unicorn.stderr.log"
stdout_path RAILS_ROOT + "/current/log/unicorn.stdout.log"

worker_processes 4
preload_app true
timeout 30
Dir.mkdir(RAILS_ROOT + "/current/tmp/sockets") unless Dir.exists?(RAILS_ROOT + "/current/tmp/sockets")
listen RAILS_ROOT + "/current/tmp/sockets/unicorn.weihnachten.sock", backlog: 64

# PIDS = RAILS_ROOT + "/tmp/pids"
# STDERR.puts "=== #{ PIDS }"
# Dir.mkdir(PIDS) unless Dir.exists?( PIDS )
Dir.mkdir(RAILS_ROOT + "/shared/pids") unless Dir.exists?(RAILS_ROOT + "/shared/pids")
pid RAILS_ROOT + "/shared/pids/unicorn.pid"

before_fork do |server, worker|
  pid_old = RAILS_ROOT + '/shared/pids/unicorn.pid.oldbin'
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
    user, group = 'unicorn', 'unicorn'
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