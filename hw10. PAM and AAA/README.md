надо:

1. Запретить всем пользователям, кроме группы adm-group, логин в выходные и праздничные дни
2. Дать конкретному пользователю права рута

посмотрим какие есть пользователи с оболочкой

    # cat /etc/passwd | grep /bin/bash

создадим пользователя test с оболочкой и паролем 123. если надо создать пользователя с добавлением в группы, используется флаг -G с перечислением групп.

    # useradd -p 123 -s /bin/bash test

если надо посмотреть в каких группах состоит пользователь, используется командап _id_

создаем группу adm_group. На чистой системе GID=1001. Если надо сделать группу с определенным GID, то команда будет иметь вид _groupadd -g myGID mygroup_

    # groupadd adm_group

добавляем в неё пользователей root и vagrant. Флаг _-G_ обязателен, если мы не хотим перезаписать принадлежность к группе (т.е. по умолчанию идет выход из одной группы и вход в новую)

    # usermod -a -G adm_group vagrant
    # usermod -a -G adm_group root

###### переходим к запретам:

конфиги лежат в _/etc/pam.d/_

включаем модуль _pam_time.so_

    sudo sed -i '5i\account required pam_time.so' /etc/pam.d/login
    sudo sed -i '4i\account required pam_time.so' /etc/pam.d/sshd 

если есть возможность входа через GUI надо добавить строку _account required pam_time.so_ в файл гуя, у гнома - это _gdm_

затем, на развалинах часовни, в смысле в _/etc/security/time.conf_ (конфиг модуля pam_time.so) добавляем строки

    login ; tty* & !ttyp* ; !adm_group ; Wd
    sshd ;  tty* & !ttyp* ; !adm_group ; Wd

в этом же конфиге по умолчанию есть небольшое howto. 

###### наделим пользователя правами рута

есть два способа:

cпособ раз. Создание нового пользователя с uid и gid равным 0.

    $ sudo useradd -ou 0 -g 0 -p 123 -s /bin/bash test_root
   
способ двас. Изменение uid и gid существующего пользователя в _/etc/passwd_

способ полторас. Внести пользователя в список _sudoers_

NB для удаления пользователя с _uid 0_ надо поменять uid на любой другой, лучше более 1000.

Ссылки:
1. [РОДИТЕЛЬСКИЙ КОНТРОЛЬ ПОСРЕДСТВОМ LINUX-PAM](https://xubuntu-ru.net/how-to/101-roditelskiy-kontrol-posredstvom-linux-pam.html)
2. [PAM на страже ваших компьютеров](http://rus-linux.net/lib.php?name=/MyLDP/sec/pam.html)
3. [pam_time - time controled access](http://linux-pam.org/Linux-PAM-html/sag-pam_time.html)
4. 
