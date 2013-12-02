RAILS_ROOT = "/ruby_projects/weihnachten"
RAILS_ENV = ENV['RAILS_ENV'] || 'production'
working_directory RAILS_ROOT + "/current"

stderr_path RAILS_ROOT + "/current/log/unicorn.stderr.log"
stdout_path RAILS_ROOT + "/current/log/unicorn.stdout.log"

worker_processes 4
preload_app true
timeout 30
Dir.mkdir(RAILS_ROOT + "/shared/sockets") unless Dir.exists?(RAILS_ROOT + "/shared/sockets")
listen RAILS_ROOT + "/shared/sockets/unicorn.weihnachten.sock", backlog: 64

# PIDS = RAILS_ROOT + "/tmp/pids"
# STDERR.puts "=== #{ PIDS }"
# Dir.mkdir(PIDS) unless Dir.exists?( PIDS )
Dir.mkdir(RAILS_ROOT + "/shared/pids") unless Dir.exists?(RAILS_ROOT + "/shared/pids")
pid RAILS_ROOT + "/shared/pids/unicorn.pid"

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  # The following is only recommended for memory/DB-constrained
  # installations.  It is not needed if your system can house
  # twice as many worker_processes as you have configured.
  #
  # This allows a new master process to incrementally
  # phase out the old master process with SIGTTOU to avoid a
  # thundering herd (especially in the "preload_app false" case)
  # when doing a transparent upgrade.  The last worker spawned
  # will then kill off the old master process with a SIGQUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  #
  # Throttle the master from forking too quickly by sleeping.  Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  # sleep 1
end

after_fork do |server, worker|
  # per-process listener ports for debugging/admin/migrations
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end

# before_fork do |server, worker|
#   pid_old = RAILS_ROOT + '/shared/pids/unicorn.pid.oldbin'
#   if File.exists?(pid_old) && server.pid != pid_old
#     begin
#       Process.kill("QUIT", File.read(pid_old).to_i)
#     rescue Errno::ENOENT, Errno::ESRCH
#       # someone else did our job for us
#     end
#   end
# end

# after_fork do |server, worker|
#   ActiveRecord::Base.establish_connection
#   begin
#     uid, gid = Process.euid, Process.egid
#     user, group = 'deployer', 'staff'
#     target_uid = Etc.getpwnam(user).uid
#     target_gid = Etc.getgrnam(group).gid
#     worker.tmp.chown(target_uid, target_gid)
#     if uid != target_uid || gid != target_gid
#       Process.initgroups(user, target_gid)
#       Process::GID.change_privilege(target_gid)
#       Process::UID.change_privilege(target_uid)
#     end
#   rescue => e
#     if RAILS_ENV == 'development'
#       STDERR.puts "Cannot change Unicorn's worker UID/GID in development environment."
#     else
#       raise e
#     end
#   end
# end