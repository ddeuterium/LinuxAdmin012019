#!/usr/bin/env bash

vagrant scp httpd@.service lvm:~/
vagrant scp httpd.target lvm:~/
vagrant scp httpd_site1.conf lvm:~/
vagrant scp httpd_site2.conf lvm:~/
vagrant scp sysconf_httpd_site1 lvm:~/
vagrant scp sysconf_httpd_site2 lvm:~/
vagrant scp file_move.sh lvm:~/



