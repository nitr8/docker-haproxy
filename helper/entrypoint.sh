#!/bin/sh
set -o errexit
set -o nounset

readonly RSYSLOG_PID="/var/run/rsyslogd.pid"

main() {
  start_rsyslogd
  start_httpd
  start_lb "$@"
}

start_rsyslogd() {
  rm -f $RSYSLOG_PID
  rsyslogd
}

start_httpd() {
  mini_httpd -C /etc/mini_httpd.conf
}

start_lb() {
  exec haproxy "$@"
}

main "$@"
