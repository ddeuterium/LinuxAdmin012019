Работа с загрузчиком
1. Попасть в систему без пароля несколькими способами
2. Установить систему с LVM, после чего переименовать VG
3. Добавить модуль в initrd

4(*). Сконфигурировать систему без отдельного раздела с /boot, а только с LVM
Репозиторий с пропатченым grub: https://yum.rumyantsev.com/centos/7/x86_64/
PV необходимо инициализировать с параметром --bootloaderareasize 1m
Критерии оценки: Описать действия, описать разницу между методами получения шелла в процессе загрузки.
Где получится - используем script, где не получается - словами или копипастой описываем действия.

существует 3 способа войти в систему без пароля, если есть к ней физический доступ или удаленка на этап загрузки ядра. Во всех случаях надо выбрать ядро и нажать кнопку _E(dit)_. После этого в конец строки, начинающейся на linux16 (linuxefi если на машине EFI), добавить:

1. #### init=/bin/sh

Загрузится минимальный shell, поменять пароль не получится, либо нужно сильное колдунство, т.к. нет команды chroot

2. #### rd.break 

отсюда можно сбросить пароль рута. Лучше сделать так: _rw rd.break enforcing=0_, это позволит не подкидывать данные SElinux об изменном пароле. Мало такого, такой способ является рекомендованным [Procedure 25.6 RedHat Adm. Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/sec-terminal_menu_editing_during_boot#proc-Resetting_the_Root_Password_Using_rd.break#Procedure%2025.6.) _rw_ монтирует /sysroot ReadWrite, _enforcing=0_ позволит не подкидывать данные для SELinux (touch /.autorelabel)

    mount -o remount,rw /sysroot
    chroot /sysroot
    passwd
    touch /.autolabel
    exit
    exit
  
#пойдет загрузка системы
  
3. #### init=/sysroot/bin/sh

работает примерно как п.2, только не работает флаг enforcing=0 и надо перезагружать.

Script started on 2019-03-03 21:02:37+0800

    $ sudo su

посмотрим, что происходит

    # vgs
    VG         #PV #LV #SN Attr   VSize   VFree
    VolGroup00   1   2   0 wz--n- <38.97g    0 

переименуем VG

    # vgrename VolGroup00 OtusRoot
      Volume group "VolGroup00" successfully renamed to "OtusRoot"

заменим старое название VG на новое

    # sed -i 's/VolGroup00/OtusRoot/g' /etc/fstab
    # sed -i 's/VolGroup00/OtusRoot/g' /boot/grub2/grub.cfg 
    # sed -i 's/VolGroup00/OtusRoot/g' /etc/default/grub

пересобираем образ initrd
    
    # dracut -f -v
    или так
    # mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)

создадим папку для кастомных скриптов

    # mkdir /usr/lib/dracut/modules.d/01test

скопируем скрипты внутрь VM

    # reboot
    $ vscp test.sh lvm:~/
    $ vscp module-setup.sh lvm:~/ 
    $ vssh
      Last login: Sun Mar  3 13:15:11 2019 from 10.0.2.2
      
проверим как переименовалось

    # vgs
      VG       #PV #LV #SN Attr   VSize   VFree
      OtusRoot   1   2   0 wz--n- <38.97g    0 

скопируем скрипты в модули

    $ sudo cp * /usr/lib/dracut/modules.d/01test

пересоберем initrd

    $ sudo dracut -f -v
    или
    $ sudo mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)

*** Creating image file ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***

После чего можно пойти двумя путями для проверки:

1. Перезагрузиться и руками выключить опции _rghb_ и _quiet_ и позырить пингвина

2. Либо отредактировать _grub.cfg_ убрав эти опции. ВНИМАНИЕ! не использовать _sed_, сломается загрузчик!!

В итоге при загрузке будет пауза на 10 секунд и можно позырить на пингвина


