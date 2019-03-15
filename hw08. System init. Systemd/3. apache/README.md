если запускать отдельно, то надо выполнить
    
    # yum install -y httpd
    
есть скрипты [копирования](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/3.%20apache/file_copy.sh) и [раскладки по нужным местам](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/3.%20apache/file_move.sh) файлов.

также могут не стартовать инстансы из-за selinux. Временно выполняем

    setenforce 0

создать unit-файл по шаблону из /etc/systemd/system/httpd.service. ОБЯЗАТЕЛЬНО сделать его в виде [httpd@.service](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/3.%20apache/httpd%40.service), иначе не взлетит

Создать конфиг на каждый экземпляр(instance) ([httpd_site1.conf](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/3.%20apache/httpd_site1.conf) [httpd_site2.conf](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/3.%20apache/httpd_site2.conf)), поместить их в _/etc/httpd/conf_, добавить в них путь к PidFile _(/var/run/httpd/httpd_siteX.pid)_.

создать в _/etc/sysconfig/_ файлы окружение (EnvironmentFile) [sysconf_httpd_site1](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/3.%20apache/sysconf_httpd_site1) [sysconf_httpd_site2](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/3.%20apache/sysconf_httpd_site2)

Cоздать [httpd.target](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/3.%20apache/httpd.target) для запуска инстансов по одному target.

    Wants=httpd@site1.service httpd@site2.service

