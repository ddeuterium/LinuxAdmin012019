$ sudo su
# yum install epel-release -y && yum install spawn-fcgi php php-cli

    Complete!

раскомментировать строчки с переменными SOCKET и OPTIONS. Можно сделать двумя способами:
1. подкинуть [готовый файл](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/2/spawn-fcgi)
2. или отредактировать имеющийся:

    # sed -i '7s/^.//' /etc/sysconfig/spawn-fcgi 
    # sed -i '8s/^.//' /etc/sysconfig/spawn-fcgi 

проверяем 

# systemctl start spawn-fcgi
# systemctl status spawn-fcgi

    spawn-fcgi.service - Spawn-fcgi startup service by Otus
       Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
       Active: active (running)[0m since Fri 2019-03-15 00:25:16 UTC; 13s ago
    Main PID: 7336 (php-cgi)
       CGroup: /system.slice/spawn-fcgi.service
               ├─7336 /usr/bin/php-cgi
               ├─7337 /usr/bin/php-cgi
               ├─7338 /usr/bin/php-cgi
               ├─7339 /usr/bin/php-cgi
               ├─7340 /usr/bin/php-cgi
               ├─7341 /usr/bin/php-cgi
               ├─7342 /usr/bin/php-cgi
               ├─7343 /usr/bin/php-cgi
               ├─7344 /usr/bin/php-cgi
               ├─7345 /usr/bin/php-cgi
               ├─7346 /usr/bin/php-cgi
               ├─7347 /usr/bin/php-cgi
               ├─7348 /usr/bin/php-cgi
               ├─7349 /usr/bin/php-cgi
               ├─7350 /usr/bin/php-cgi
               ├─7351 /usr/bin/php-cgi
               ├─7352 /usr/bin/php-cgi
               ├─7353 /usr/bin/php-cgi
               ├─7354 /usr/bin/php-cgi
               ├─7355 /usr/bin/php-cgi
               ├─7356 /usr/bin/php-cgi
               ├─7357 /usr/bin/php-cgi
               ├─7358 /usr/bin/php-cgi
               ├─7359 /usr/bin/php-cgi
               ├─7360 /usr/bin/php-cgi
               ├─7361 /usr/bin/php-cgi
               ├─7362 /usr/bin/php-cgi
               ├─7363 /usr/bin/php-cgi
               ├─7364 /usr/bin/php-cgi
               ├─7365 /usr/bin/php-cgi
               ├─7366 /usr/bin/php-cgi
               ├─7367 /usr/bin/php-cgi
               └─7368 /usr/bin/php-cgi
    
    Mar 15 00:25:16 lvm systemd[1]: Started Spawn-fcgi startup service by Otus.
    Mar 15 00:25:16 lvm systemd[1]: Starting Spawn-fcgi startup service by Otus...
