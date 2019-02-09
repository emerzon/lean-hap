#!/bin/sh -ex
/sbin/syslogd -O /proc/1/fd/1
haproxy -f /etc/haproxy/haproxy.cfg -db