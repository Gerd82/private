#!/bin/bash
### BEGIN INIT INFO
# Provides: unicorn_rails2-example
# Required-Start: $all
# Required-Stop: $network $local_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start the rails2-example unicorns at boot
# Description: Enable rails2-example.example.com at boot time.
### END INIT INFO

set -u
set -e

APP_NAME="rails4"
APP_ROOT="/ruby_projects/weihnachten"
PID="$APP_ROOT/shared/pids/unicorn.pid"
ENV="production"
RVM_RUBY_VERSION="ruby-2.0.0-p356"

GEM_HOME="/usr/local/rvm/gems/$RVM_RUBY_VERSION@$APP_NAME"

UNICORN_OPTS="-D -E $ENV -c $APP_ROOT/current/config/unicorn/production.rb"

SET_PATH="cd $APP_ROOT/current && rvm use $RVM_RUBY_VERSION@$APP_NAME && export GEM_HOME=$GEM_HOME"
# CMD="$SET_PATH; $GEM_HOME/bin/unicorn $UNICORN_OPTS"
CMD="cd $APP_ROOT/current; bundle exec unicorn -D -c $APP_ROOT/current/config/unicorn.rb -E $ENV"

old_pid="$PID.oldbin"

cd $APP_ROOT || exit 1

sig () {
  test -s "$PID" && kill -$1 `cat $PID`
}

oldsig () {
  test -s $old_pid && kill -$1 `cat $old_pid`
}

case ${1-help} in

start)
  sig 0 && echo >&2 "Already running" && exit 0
  su - unicorn -c "$CMD"
  ;;
stop)
  sig QUIT && exit 0
  echo >&2 "Not running"
  ;;

force-stop)
  sig TERM && exit 0
  echo >&2 "Not running"
  ;;

restart|reload)
  sig HUP && echo reloaded OK && exit 0
  echo >&2 "Couldn't reload, starting '$CMD' instead"
  su - unicorn -c "$CMD"
  ;;

upgrade)
  sig USR2 && exit 0
  echo >&2 "Couldn't upgrade, starting '$CMD' instead"
  su - unicorn -c "$CMD"
  ;;

rotate)
  sig USR1 && echo rotated logs OK && exit 0
  echo >&2 "Couldn't rotate logs" && exit 1
  ;;

*)
  echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>"
  exit 1
  ;;
esac