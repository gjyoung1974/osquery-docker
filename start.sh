#!/bin/bash
/opt/td-agent-bit/bin/td-agent-bit -c /etc/td-agent-bit/td-agent-bit.conf && /usr/sbin/cron -f &&  service cron start


