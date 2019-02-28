Script started on 2019-02-27 15:12:02+0800

ВНИМАНИЕ, в примере используется openssl версия 1.1.1b. для использования другой версии надо будет менять ссылку

ВНИМАНИЕ: в логе описана работа от обычного пользователя, сборка пакета происходит из-под sudo, поэтому пакет появится в /root/rpmbuild

[vagrant@lvm ~]$ sudo yum install -y \
        redhat-lsb-core \
        wget \
        rpmdevtools \
        rpm-build \
        createrepo \
        yum-utils \
        gcc \       # а чем ты собрался компилировать rpm??
        openssl-devel \
        zlib-devel \
        pcre-devel \
        links       # для проверки работы репы изнутре ВМ. Кхм, "внутре у ней не-неонка" (с)

[vagrant@lvm ~]$ wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm

[vagrant@lvm ~]$  rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm

будет ругаться так, но потом соберется нормально

  warning: nginx-1.14.1-1.el7_4.ngx.src.rpm: Header V4 RSA/SHA1 Signature, key ID 7bd9bf62: NOKEY
  warning: user builder does not exist - using root
  warning: group builder does not exist - using root

качаем последнюю версию openssl. ВНИМАНИЕ, в примере используется версия 1.1.1b

[root@lvm vagrant]# wget https://www.openssl.org/source/latest.tar.gz

[root@lvm vagrant]# tar -xvf latest.tar.gz 

для сборки nginx c openssl надо добавить опцию --with-openssl=<путь ДО каталога> в раздел %build spec-файла

поставим все зависимости чтобý в процессе сборки не бýло ошибок

[vagrant@lvm ~]$ yum-builddep rpmbuild/SPECS/nginx.spec

собираем rpm (ключ -bb). Ключ -bs собирает srpm, ключ -ba - srpm+rpm

[vagrant@lvm ~]$ rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec

Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.q93Tuj
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd nginx-1.14.1
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/nginx-1.14.1-1.el7_4.ngx.x86_64
+ exit 0

[vagrant@lvm ~]$ sudo yum -y localinstall /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm

запустить и проверить работу nginx

[vagrant@lvm ~]$ sudo systemctl start nginx
[vagrant@lvm ~]$ sudo systemctl status nginx

создать папку для репы

[vagrant@lvm ~]$ sudo mkdir /usr/share/nginx/html/repo

скопировать rpm в репу

[vagrant@lvm ~]$ sudo cp /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/

создаем репу по указанному адресу

[root@lvm vagrant]# createrepo /usr/share/nginx/html/repo/
Spawning worker 0 with 2 pkgs
Workers Finished
Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs
Sqlite DBs complete[root@lvm vagrant]# nano /etc/nginx/conf.d/default.conf

чтобы нжинкс автоиндексировал новые файлы надо поправить файл /etc/nginx/conf.d/default.conf. В раздел location добавить autoindex on. Для проверки правильности конфига нжинкса надо выполнить:

[root@lvm vagrant]# nginx -t

nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

[root@lvm vagrant]# nginx -s reload

создадим файл репы

[root@lvm vagrant]# cat >> /etc/yum.repos.d/otus.repo <<< EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

после каждого добавления в репу пакетов надо делать creatrepo

[root@lvm vagrant]# createrepo /usr/share/nginx/html/repo

Script done on 2019-02-27 16:47:29+0800
