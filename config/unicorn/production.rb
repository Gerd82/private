APP_PATH = "/ruby_projects/weihnachten/current"
working_directory APP_PATH
pid APP_PATH + "/tmp/unicorn.pid"
stderr_path APP_PATH + "/log/unicorn.stderr.log"
stdout_path APP_PATH + "/log/unicorn.stdout.log"

listen "/tmp/unicorn.weihnachten.sock"
worker_processes 2
timeout 30
