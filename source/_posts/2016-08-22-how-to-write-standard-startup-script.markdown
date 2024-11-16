---
layout: post
title: "how to write standard startup script"
date: 2016-08-22 09:09:06 +0800
comments: true
categories: tools
---
centos6中的init.d systemV script升级为systemd startup script，让我们有个easy setup的模板...

模板实例:
<!-- more -->

## systemV init script template

```
#!/bin/bash

# testclient - Startup script for testclient

# chkconfig: 35 85 15
# description: testclient is your openstack VMS monitor and ovs auto config bot.
# processname: testclient
# config: /etc/testclient.conf

. /etc/rc.d/init.d/functions

# NOTE: if you change any OPTIONS here, you get what you pay for:
# this script assumes all options are in the config file.
CONFIGFILE="/etc/testclient.conf"

testCLIENT=/usr/local/bin/testclient

testCLIENT_USER=helloworldtest
testCLIENT_GROUP=helloworldtest

# things from testclient.conf get there by testclient reading it
PIDFILEPATH=`awk -F'[:=]' -v IGNORECASE=1 '/^[[:blank:]]*(processManagement\.)?pidFilePath[[:blank:]]*[:=][[:blank:]]*/{print $2}' "$CONFIGFILE" | tr -d "[:blank:]\"'" | aw
PIDDIR=`dirname $PIDFILEPATH`
LOGFILEPATH=`awk -F'[:=]' -v IGNORECASE=1 '/^[[:blank:]]*(processManagement\.)?logFilePath[[:blank:]]*[:=][[:blank:]]*/{print $2}' "$CONFIGFILE" | tr -d "[:blank:]\"'" | aw
LOGDIR=`dirname $LOGFILEPATH`

OPTIONS=" -c $CONFIGFILE"

start()
{
  # Make sure the default pidfile directory exists
  if [ ! -d $PIDDIR ]; then
    install -d -m 0755 -o $testCLIENT_USER -g $testCLIENT_GROUP $PIDDIR
  fi
  if [ ! -d $LOGDIR ]; then
    install -d -m 0755 -o $testCLIENT_USER -g $testCLIENT_GROUP $LOGDIR
  fi

  echo -n $"Starting testclient: "
  daemon --pidfile "$PIDFILEPATH" --user "$testCLIENT_USER" --check $testCLIENT "$testCLIENT $OPTIONS >$LOGFILEPATH 2>&1 &"

  RETVAL=$?
  pid=`ps -A x | grep $testCLIENT | grep -v grep | cut -d" " -f1 | head -n 1`
  if [ -n "$pid" ]; then
          echo $pid > $PIDFILEPATH
  fi

  [ $RETVAL -eq 0 ] && touch /var/lock/subsys/testclient
  echo
  return $RETVAL
}

stop()
{
  echo -n $"Stopping testclient: "
  testclient_killproc "$PIDFILEPATH" $testCLIENT
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/testclient
}

restart () {
        stop
        start
}

# Send TERM signal to process and wait up to 300 seconds for process to go away.
# If process is still alive after 300 seconds, send KILL signal.
# Built-in killproc() (found in /etc/init.d/functions) is on certain versions of Linux
# where it sleeps for the full $delay seconds if process does not respond fast enough to
# the initial TERM signal.
testclient_killproc()
{
  local pid_file=$1
  local procname=$2
  local -i delay=10
  local -i duration=1
  local pid=`pidofproc -p "${pid_file}" ${procname}`

  kill -TERM $pid >/dev/null 2>&1
  usleep 1000
  local -i x=0
  while [ $x -le $delay ] && checkpid $pid; do
    sleep $duration
    x=$(( $x + $duration))
  done

  kill -KILL $pid >/dev/null 2>&1
  usleep 1000

  checkpid $pid # returns 0 only if the process exists
  local RC=$?
  [ "$RC" -eq 0 ] && failure "${procname} shutdown" || rm -f "${pid_file}"; success "${procname} shutdown"
  RC=$((! $RC)) # invert return code so we return 0 when process is dead.
  return $RC
}

RETVAL=0

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart|reload|force-reload)
    restart
    ;;
  condrestart)
    [ -f $PIDFILEPATH] && restart || :
    ;;
  status)
    status $testCLIENT
    RETVAL=$?
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart|reload|force-reload|condrestart}"
    RETVAL=1
esac

exit $RETVAL

```


## systemd startup script template

#### helloworld.conf


```
node = 1

[system]
pidFilePath=/var/lib/helloworldtest/run/hello.pid
logFilePath=/var/lib/helloworldtest/log/hello.log

```


####/usr/lib/systemd/system/helloworld.service

```
[Unit]
Description=helloworld

[Service]
Type=forking
EnvironmentFile=/etc/helloworld.conf
ExecStartPre=/bin/sh -c '/bin/install -d -m 0755 -o root -g root $( /usr/bin/dirname ${logFilePath} )'
ExecStartPre=/bin/sh -c '/bin/install -d -m 0755 -o root -g root $( /usr/bin/dirname ${pidFilePath} )'
ExecStart=/usr/local/sbin/daemonize -p ${pidFilePath} -a -o ${logFilePath} -e ${logFilePath} /usr/local/bin/helloworld -c /etc/helloworld.conf
ExecStopPost=/bin/kill $MAINPID
Restart=always

[Install]
WantedBy=default.target

```
