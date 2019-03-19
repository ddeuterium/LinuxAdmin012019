Script started on 2019-03-16 16:36:51+0800
$ python -V
Python 2.7.15rc1
$ 
$ 
$ 
$ ansible --version
ansible 2.7.8
  config file = /home/shaad/otus/hw09. ansible/ansible.cfg
  configured module search path = [u'/home/shaad/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.15rc1 (default, Nov 12 2018, 14:31:15) [GCC 7.3.0]
$ 
$ 
$ 
$ vagrant up
$ 
$ 
$ 
$ vagrant ssh-config
Host nginx
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile "/home/shaad/otus/hw09. ansible/.vagrant/machines/nginx/virtualbox/private_key"
  IdentitiesOnly yes
  LogLevel FATAL

$ 
$ 
$ 
$ touch staging/hosts
$ nano staging/hosts 

создаем инвентори следующего содержания

$ cat staging/hosts 
[web]
nginx ansible_host=127.0.0.1 ansible_port=2222 aansible_user=vagrant ansible_private_key_file=.vagrant/machines/nginx/virtualbox/private_key
$ 
$ 
$ 
проверяем может ли ансибл управлять хостом

$ 
$ ansible nginx -i staging/hosts K-m ping
nginx | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
$ 
$ чтобы не указывать постоянно инвентори-файл, создаем конфиг и прописываем  в нем инвентори

$ touch ansible.cfg
$ cat ansible.cfg 
[defaults]
inventory = staging/hosts
remote_user = vagrant
host_key_checking = False
retry_files_enabled = False



$ теперь можно удалить из инвентори инфу о пользователе
$ 
$ 
$ cat staging/hosts 
[web]
nginx ansible_host=127.0.0.1 ansible_port=2222 ansible_private_key_file=.vagrant/machines/nginx/virtualbox/private_key
$ 
$ 
$ 
$ убедимся в доступности хоста

$ ansible nginx -m ping
nginx | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
$ 
$ 
$ 
 начинаем конфигурировать хост Ad-Hoc командами
 проверим какое ядро установлено на хосте
$ 
$ 
$ 
$ ansible nginx -m command -a "uname -r"
nginx | CHANGED | rc=0 >>
3.10.0-862.2.3.el7.x86_64

$ 
$ 
$ 

$ ansible nginx -m systemd -a name=firewalld | grep Active
        "ActiveEnterTimestampMonotonic": "0", 
        "ActiveExitTimestampMonotonic": "0", 
        "ActiveState": "inactive", 
$ 
$ 
$ 

Установим пакет epel-release на наш хост. Ключ -b значит --become, т.е. выполнить от рута

$ ansible nginx -m yum -a "name=epel-release state=present" -b
nginx | CHANGED => {
    "ansible_facts": {
        "pkg_mgr": "yum"
    }, 
    "changed": true, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: mirror.logol.ru\n * extras: mirror.logol.ru\n * updates: ftp.nsc.ru\nResolving Dependencies\n--> Running transaction check\n---> Package epel-release.noarch 0:7-11 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package                Arch             Version         Repository        Size\n================================================================================\nInstalling:\n epel-release           noarch           7-11            extras            15 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package\n\nTotal download size: 15 k\nInstalled size: 24 k\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : epel-release-7-11.noarch                                     1/1 \n  Verifying  : epel-release-7-11.noarch                                     1/1 \n\nInstalled:\n  epel-release.noarch 0:7-11                                                    \n\nComplete!\n"
    ]
}
$ 
$ 
$ 
$ ansible nginx -m yum -a "name=epel-release state=present" -b
nginx | FAILED! => {
    "msg": "The module ыуегз was not found in configured module paths. Additionally, core modules are missing. If this is a checkout, run 'git pull --rebase' to correct this problem."
}
$ 
$ 
$ 
$ 
$ 
$ 
$ 
$ 
$ 
$ ansible nginx -m yum -a "name=epel-release state=present" -b
nginx | SUCCESS => {
    "ansible_facts": {
        "pkg_mgr": "yum"
    }, 
    "changed": false, 
    "msg": "", 
    "rc": 0, 
    "results": [
        "epel-release-7-11.noarch providing epel-release is already installed"
    ]
}


$ создаем playbook установки пакета epel-release
$ 
$ 
$ touch epel.yml

$ cat epel.yml
---
- name: Install EPEL Repo
  hosts: nginx
  become: true
  tasks:
    - name: Install EPEL Repo package from standard repo
      yum:
        name: epel-release
        state: present
...


$ ansible-playbook epel.yml

PLAY [Install EPEL Repo] ******************************************************************************************

TASK [Gathering Facts] ********************************************************************************************
ok: [nginx]

TASK [Install EPEL Repo package from standard repo] ***************************************************************
ok: [nginx]

PLAY RECAP ********************************************************************************************************
nginx                      : ok=2    changed=0    unreachable=0    failed=0   




 посмотрим на вывод той же команды со state=absent.

    $ ansible nginx -m yum -a "name=epel-release state=absent" -b
    nginx | CHANGED => {
        "ansible_facts": {
            "pkg_mgr": "yum"
        }, 
        "changed": true, 
        "msg": "", 
        "rc": 0, 
        "results": [
            "Loaded plugins: fastestmirror\nResolving Dependencies\n--> Running transaction check\n---> Package epel-release.noarch 0:7-11 will be erased\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package                Arch             Version        Repository         Size\n================================================================================\nRemoving:\n epel-release           noarch           7-11           @extras            24 k\n\nTransaction Summary\n================================================================================\nRemove  1 Package\n\nInstalled size: 24 k\nDownloading packages:\nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Erasing    : epel-release-7-11.noarch                                     1/1 \n  Verifying  : epel-release-7-11.noarch                                     1/1 \n\nRemoved:\n  epel-release.noarch 0:7-11                                                    \n\nComplete!\n"
        ]
    }


ачешуеть, она его удаляет, кто бы мог подумать



$ начинаем выполнять ДЗ
    $ mv epel.yml nginx.yml
    $ cat nginx.yml 
    ---
    - name: NGINX | Install and configure NGINX
      hosts: nginx
      become: true
      
      tasks:
        - name: NGINX | Install EPEL Repo package from standart repo
          yum:
            name: epel-release
            state: present
          tags:
            - epel-package
            - packages
    
        - name: NGINX | Install NGINX package from EPEL Repo
          yum:
            name: nginx
            state: latest
          tags:
            - nginx-package
            - packages

 
выведем все теги в консоль

    $ ansible-playbook nginx.yml --list-tags
    
    playbook: nginx.yml
    
      play #1 (nginx): NGINX | Install and configure NGINX	TAGS: []
          TASK TAGS: [epel-package, nginx-package, packages]



запускааем установку только nginx

    
    
    $ ansible-playbook -C nginx.yml -t nginx-package

    PLAY [NGINX | Install and configure NGINX] ************************************************************************
    
    TASK [Gathering Facts] ********************************************************************************************
    ok: [nginx]
    
    TASK [NGINX | Install NGINX package from EPEL Repo] ***************************************************************
    ok: [nginx]
    
    PLAY RECAP ********************************************************************************************************
    nginx                      : ok=2    changed=0    unreachable=0    failed=0   

да, вот так работает


добавим шаблон для конфига нжинкса и модуль, копирующий этот шаблон на хост

$ cat nginx.yml 
---
- name: NGINX | Install and configure NGINX
  hosts: nginx
  become: true
  
  tasks:
    - name: NGINX | Install EPEL Repo package from standart repo
      yum:
        name: epel-release
        state: present
      tags:
        - epel-package
        - packages

    - name: NGINX | Install NGINX package from EPEL Repo
      yum:
        name: nginx
        state: latest
      tags:
        - nginx-package
        - packages

    - name: NGINX | Create NGINX config file from template
        template:
          src: templates/nginx.conf.j2
          dest: /tmp/nginx.conf
        tags:
          - nginx-configuration


добавим переменную, чтобы нжинкс слушал порт 8080

$ cat nginx.yml
---
- name: NGINX | Install and configure NGINX
  hosts: nginx
  become: true
  vars:
    nginx_listen_port: 8080
    
  tasks:
    - name: NGINX | Install EPEL Repo package from standart repo
      yum:
        name: epel-release
        state: present
      tags:
        - epel-package
        - packages

    - name: NGINX | Install NGINX package from EPEL Repo
      yum:
        name: nginx
        state: latest
      tags:
        - nginx-package
        - packages

    - name: NGINX | Create NGINX config file from template
        template:
          src: templates/nginx.conf.j2
          dest: /etc/nginx/nginx.conf
        tags:
          - nginx-configuration
$ 
$ 
$ 
$ набарабаним шаблон

$ mkdir templates
$ touch templates/nginx.congf.j2
$ cat /templates/nginx.conf.j2 
# {{ ansible_managed }}
# generated by FairyPrawn (shaadowsky@gmail.com)
# MODIFY at your OWN risk


user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       {{ nginx_listen_port }} default_server;
        server_name  default_server;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
        }
    }
}



создаеми handler и добавляем notify к копированию шаблона. При изменении конфига сервис будет перезагружен

    $ cat nginx.yml 
    ---
    - name: NGINX | Install and configure NGINX
      hosts: nginx
      become: true
      vars:
        nginx_listen_port: 8080
    
      tasks:
        - name: NGINX | Install EPEL Repo package from standart repo
          yum:
            name: epel-release
            state: present
          tags:
            - epel-package
            - packages

        - name: NGINX | Install NGINX package from EPEL Repo
          yum:
            name: nginx
            state: latest
          notify:
            - restart nginx
          tags:
            - nginx-package
            - packages

        - name: NGINX | Create NGINX config file from template
            template:
              src: templates/nginx.conf.j2
              dest: /etc/nginx/nginx.conf
          notify:
            - reload nginx
            tags:
              - nginx-configuration

      handlers:
        - name: restart nginx
          systemd:
            name: nginx
            state: restarted
            enabled: yes

        - name: reload nginx
          systemd:
            name: nginx
            state: reloaded




проверяем


$ ansible-playbook nginx.yml

PLAY [NGINX | Install and configure NGINX] ************************************************************************

TASK [Gathering Facts] ********************************************************************************************
ok: [nginx]

TASK [NGINX | Install EPEL Repo package from standart repo] *******************************************************
ok: [nginx]

TASK [NGINX | Install NGINX package from EPEL Repo] ***************************************************************
ok: [nginx]

TASK [NGINX | Create NGINX config file from template] *************************************************************
ok: [nginx]

PLAY RECAP ********************************************************************************************************
nginx                      : ok=4    changed=0    unreachable=0    failed=0   


еее, заработало


$ curl http://192.168.11.150:8080
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
    <head>
        <title>Test Page for the Nginx HTTP Server on Fedora</title>



заработало
