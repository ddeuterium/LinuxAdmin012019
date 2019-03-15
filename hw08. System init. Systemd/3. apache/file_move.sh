#!/usr/bin/env bash

#yum install -y httpd
mv httpd_site1.conf /etc/httpd/conf/
mv httpd_site2.conf /etc/httpd/conf/
mv httpd@.service /etc/systemd/system/
mv httpd.target /etc/systemd/system
mv sysconf_httpd* /etc/sysconfig/



