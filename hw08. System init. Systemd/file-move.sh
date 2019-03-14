#!/bin/bash

mv watchdog /etc/sysconfig
mv watchlog.log /var/log
mv watchlog.service /etc/systemd/system
mv watchlog.sh /opt
mv watchlog.timer /etc/systemd/system
