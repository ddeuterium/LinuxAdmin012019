#!/bin/bash

vagrant scp watchdog lvm:~/
vagrant scp watchlog.log lvm:~/
vagrant scp watchlog.service lvm:~/
vagrant scp watchlog.sh lvm:~/
vagrant scp watchlog.timer lvm:~/
vagrant scp file-move.sh lvm:~/

