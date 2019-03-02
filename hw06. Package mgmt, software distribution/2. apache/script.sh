#!/bin/bash

# разворачивание репы c апачем, собранным с mod_mpm_event через nginx
# надо вручную включить модуль

yum install -y links mc redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc nginx
yumdownloader --source httpd
rpm -i httpd-2.4.6-88.el7.centos.src.rpm 
sed -i '275i\%package -n mod_mpm_event' /root/rpmbuild/SPECS/httpd.spec
sed -i '276i\Group: System Environment/Daemon' /root/rpmbuild/SPECS/httpd.spec
sed -i '277i\Summary: optimizing memory usage' /root/rpmbuild/SPECS/httpd.spec
sed -i '278i\ ' /root/rpmbuild/SPECS/httpd.spec
sed -i '279i\%description -n mod_mpm_event' /root/rpmbuild/SPECS/httpd.spec
sed -i '280i\adding dependency' /root/rpmbuild/SPECS/httpd.spec
sed -i '479d' /root/rpmbuild/SPECS/httpd.spec
sed -i '478d' /root/rpmbuild/SPECS/httpd.spec
sed -i '477d' /root/rpmbuild/SPECS/httpd.spec
sed -i '476d' /root/rpmbuild/SPECS/httpd.spec
sed -i '475d' /root/rpmbuild/SPECS/httpd.spec
sed -i '474d' /root/rpmbuild/SPECS/httpd.spec
yum-builddep -y /root/rpmbuild/SPECS/httpd.spec
rpmbuild -ba /root/rpmbuild/SPECS/httpd.spec
mkdir -p /usr/share/nginx/html/repo/
sed -i "11i\\        autoindex on;"  /etc/nginx/conf.d/default.conf
cp /root/rpmbuild/RPMS/x86_64/* /usr/share/nginx/html/repo/
touch /etc/yum.repos.d/nginx.repo 
echo "[nginx-stable]"  >> /etc/yum.repos.d/nginx.repo
echo "name=nginx stable repo"  >> /etc/yum.repos.d/nginx.repo
echo "baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/"  >> /etc/yum.repos.d/nginx.repo
echo "gpgcheck=1"  >> /etc/yum.repos.d/nginx.repo
echo "gpgcheck=1"  >> /etc/yum.repos.d/nginx.repo
echo "enabled=1"  >> /etc/yum.repos.d/nginx.repo
echo "gpgkey=https://nginx.org/keys/nginx_signing.key"  >> /etc/yum.repos.d/nginx.repo
echo " "  >> /etc/yum.repos.d/nginx.repo
echo "[nginx-mainline]"  >> /etc/yum.repos.d/nginx.repo
echo "name=nginx mainline repo"  >> /etc/yum.repos.d/nginx.repo
echo "baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/"  >> /etc/yum.repos.d/nginx.repo
echo "gpgcheck=1"  >> /etc/yum.repos.d/nginx.repo
echo "enabled=0"  >> /etc/yum.repos.d/nginx.repo
echo "gpgkey=https://nginx.org/keys/nginx_signing.key"  >> /etc/yum.repos.d/nginx.repo
yum install -y nginx
touch  /etc/yum.repos.d/otus.repo
echo "[otus]" >> /etc/yum.repos.d/otus.repo
echo "name=otus-linux" >> /etc/yum.repos.d/otus.repo
echo "baseurl=http://localhost/repo" >> /etc/yum.repos.d/otus.repo
echo "gpgcheck=0" >> /etc/yum.repos.d/otus.repo
echo "enabled=1" >> /etc/yum.repos.d/otus.repo
touch /usr/share/nginx/html/repo/readme.md
echo "после установки апача раскомментить mpm-event и закомментить mpm-prefork в /etc/httpd/conf.modules.d/00-mpm.conf" >> /usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md/usr/share/nginx/html/repo/readme.md
createrepo /usr/share/nginx/html/repo/
sed -i "11i\\        autoindex on;"  /etc/nginx/conf.d/default.conf
systemctl start nginx




