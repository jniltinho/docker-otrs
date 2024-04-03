#!/bin/bash

/etc/init.d/fcgiwrap start
chmod 766 /var/run/fcgiwrap.socket
cron -l &
nginx -g "daemon off;"
