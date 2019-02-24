Работа с LVM
на имеющемся образе
/dev/mapper/VolGroup00-LogVol00 38G 738M 37G 2% /
    $ vagrant box add centos/7 --box-version 1804.02

уменьшить том под / до 8G
выделить том под /home
выделить том под /var
/var - сделать в mirror
/home - сделать том для снэпшотов
прописать монтирование в fstab
попробовать с разными опциями и разными файловыми системами ( на выбор)
- сгенерить файлы в /home/
- снять снэпшот
- удалить часть файлов
- восстановится со снэпшота
- залоггировать работу можно с помощью утилиты script

* на нашей куче дисков попробовать поставить btrfs/zfs - с кешем, снэпшотами - разметить здесь каталог /opt
Критерии оценки: основная часть обязательна
задание со звездочкой +1 бал


хост - vagrant 2.1.5, virtualbox, ubuntu 18.04
виртуалка - centos/7 1804.02

для начала немного про LVM. Надо помнить, что уровни абстракции располагаютсю
в следующем порюдке: pv (physical) -> vg (volume group) -> lv (logical)


# #1 уменьшение тома XFS без создания LiveCD

необходимо помнить, что xfs в лоб, как ext4, не ресайзится. Основная мысль
заключается в создании нового раздела, перенос на него данных,
уменьшение существующего раздела, перенос на него данных, удаление 
временного раздела.

установить xfsdump, без него с xfsFS ничего не сделать

    # yum install xfsdump -y

Подготовить временный том длю переносимого раздела (здесь /):

    # pvcreate /dev/sdb
 Physical volume "/dev/sdb" successfully created.
 
    # vgcreate vg_root /dev/sdb
 Volume group "vg_root" successfully created
 
    # lvcreate -n lv_root -l +100%FREE /dev/vg_root
 Logical volume "lv_root" created.

создать на нем файловую систему и смонтировать его для переноса данных:
 
    # mkfs.xfs /dev/vg_root/lv_root
    # mount /dev/vg_root/lv_root /mnt

скопировать данные с / раздела в /mnt:
 
    # xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
    здесь будет большой вывод, но главное, чтоб была такаю строка
    xfsrestore: Restore Status: SUCCESS

проверить как скопировалось
    # ls /mnt

переконфигурировать grub длю того, чтобы при старте перейти в новый /
Сымитируем текущий root -> сделаем в него chroot и обновим grub:
кстати, монтирование одной строкой - очень удачное решение: сильно удобнее, чем каждую перечислють
    
    # for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
    # chroot /mnt/
    # grub2-mkconfig -o /boot/grub2/grub.cfg
    Generating grub configuration file ...
    Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
    Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
    done

Обновить образ initrd.
тут тоже очень изющное решение с использованием регулюрных выражений, надо их всё-таки начать применють. 

    # cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
    будет ругаться примерно так:
    dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
    не обращать вниманию, главное, что в конце дракат скажет done
    *** Creating image file ***
    *** Creating image file done ***
     *** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***

не выходя из chroot надо в файле /boot/grub2/grub.cfg заменить rd.lvm.lv=VolGroup00/LogVol00 на rd.lvm.lv=vg_root/lv_root, чтобы при загрузке был смонтирована перенесённая файловая система

Перезагруиться успешно с новым рут томом. Убедиться в этом можно посмотрев вывод lsblk:
  
    # lsblk
    NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
    sda 8:0 0 40G 0 disk
    |-sda1 8:1 0 1M 0 part
    |-sda2 8:2 0 1G 0 part /boot
    `-sda3 8:3 0 39G 0 part
     |-VolGroup00-LogVol01 253:1 0 1.5G 0 lvm [SWAP]
     `-VolGroup00-LogVol00 253:2 0 37.5G 0 lvm
    sdb 8:16 0 10G 0 disk
    `-vg_root-lv_root 253:0 0 10G 0 lvm /
    sdc 8:32 0 2G 0 disk
    sdd 8:48 0 1G 0 disk
    sde 8:64 0 1G 0 disk

изменить размер старой VG и вернуть на него рут. Длю этого удалюем старый LV размером в 40G и создаем новый на 8G:

    # lvremove /dev/VolGroup00/LogVol00
    Do you really want to remove active logical volume VolGroup00/LogVol00? [y/n]: y
     Logical volume "LogVol00" successfully removed
    
    # lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
    WARNING: xfs signature detected on /dev/VolGroup00/LogVol00 at offset 0. Wipe it? [y/n]: y
     Wiping xfs signature on /dev/VolGroup00/LogVol00.
     Logical volume "LogVol00" created.

проделать на нем те же операции, что и в первый раз:

    # mkfs.xfs /dev/VolGroup00/LogVol00
    # mount /dev/VolGroup00/LogVol00 /mnt
    # xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
    xfsdump: Dump Status: SUCCESS
    xfsrestore: restore complete: 37 seconds elapsed
    xfsrestore: Restore Status: SUCCESS

Так же как в первый раз переконфигурируем grub, за исключением правки /etc/grub2/grub.cfg

    # for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
    # chroot /mnt/
    # grub2-mkconfig -o /boot/grub2/grub.cfg
    Generating grub configuration file ...
    Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
    Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
    done
 
    # cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
    *** Creating image file ***
    *** Creating image file done ***
    *** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***

на этом месте посмотри в #2 выделение тома под LVM mirroring

После чего можно успешно перезагружатьсю в новый (уменьшенный root) и удалить временную Volume Group:
    
    # lvremove /dev/vg_root/lv_root
    Do you really want to remove active logical volume vg_root/lv_root? [y/n]: y
     Logical volume "lv_root" successfully removed
    
    # vgremove /dev/vg_root
    Volume group "vg_root" successfully removed
    
    # pvremove /dev/sdb
    Labels on physical volume "/dev/sdb" successfully wiped.


# #2 выделение тома под LVM mirroring (зеркало) в примере - /var

На свободных дисках создать зеркало:
    
    # pvcreate /dev/sdc /dev/sdd
    Physical volume "/dev/sdc" successfully created.
    Physical volume "/dev/sdd" successfully created.

    # vgcreate vg_var /dev/sdc /dev/sdd
    Volume group "vg_var" successfully created

    # lvcreate -L 950M -m1 -n lv_var vg_var
    Rounding up size to full physical extent 952.00 MiB
    Logical volume "lv_var" created.

создать на нём ФС и перенести туда /var:
лучше использовать rsync, он показывает прогресс

    # mkfs.ext4 /dev/vg_var/lv_var
    Writing superblocks and filesystem accounting information: done

    # mount /dev/vg_var/lv_var /mnt
    # cp -aR /var/* /mnt/ # rsync -avHPSAX /var/ /mnt/

На всюкий случай сохранить содержимое старого var (или же можно его просто удалить):

    # mkdir /tmp/oldvar && mv /var/* /tmp/oldvar

замонтировать новый var в каталог /var:

    # umount /mnt
    # mount /dev/vg_var/lv_var /var

поправить fstab длю автоматического монтированию /var:
выражение записывает вывод грепа blkid по строке 'var:' по второму значению ($2),
 добавляя к нему '/var ext4 defaults 0 0' в fstab
    
    # echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab


# #3 сделать LVM-snapshot (в примере /home)

!!все восстановления со снапшотов на ОТКЛЮЧЕННОЙ ФС!!

Выделить том под /home (по тому же принципу что делали для /var):

    # lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
    Logical volume "LogVol_Home" created.

    # mkfs.xfs /dev/VolGroup00/LogVol_Home
    # mount /dev/VolGroup00/LogVol_Home /mnt/
    # cp -aR /home/* /mnt/
    # rm -rf /home/*
    # umount /mnt
    # mount /dev/VolGroup00/LogVol_Home /home/

поправить fstab для автоматического монтирования /home

    # echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab

/home - сделать том для снапшотов

Сгенерировать файлы в /home/:

    # touch /home/file{1..20}

снять снапшот:
    
    # lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home

Удалить часть файлов:

    # rm -f /home/file{11..20}

восстанавливать со снапшота так

    # umount /home
    # lvconvert --merge /dev/VolGroup00/home_snap
    # mount /home


# #4_1 работа с zfs на lvm

https://losst.ru/fajlovaya-sistema-zfs#_ZFS
https://github.com/zfsonlinux/zfs/wiki/RHEL-and-CentOS
https://docs.oracle.com/cd/E19253-01/820-0836/setup-1/index.html
https://habr.com/ru/sandbox/32271/

Script started on Mon 11 Feb 2019 08:53:29 AM UTC

NB: работа с ZFS идет в основном через 2 команды. Это zpool и zfs.
NB: zpool — работа с пулами. Их создание, изменение, удаление и т.д. 
NB: zfs — работа с самой файловой системой.
NB: пул можно создать из чего угодно. От файлов под другой фс, до дисков в дисковом массиве. 

установить пакеты для работы с ZFS

    # yum install http://download.zfsonlinux.org/epel/zfs-release.el7_5.noarch.rpm -y
	Installed:
    zfs-release.noarch 0:1-5.el7.centos                                           
	Complete!
 
	# gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
	gpg: new configuration file `/root/.gnupg/gpg.conf' created
	gpg: WARNING: options in `/root/.gnupg/gpg.conf' are not yet active during this run
	pub  2048R/F14AB620 2013-03-21 ZFS on Linux <zfs@zfsonlinux.org>
	      Key fingerprint = C93A FFFD 9F3F 7B03 C310  CEB6 A9D5 A1C0 F14A B620
	sub  2048R/99685629 2013-03-21

изменить файл /etc/yum.repos.d/zfs.repo. В разделе [zfs] поменять enabled=1 
на enabled=0, а в разделе [zfs-kmod] наоборот, enabled=0 на enabled=1

    # /etc/yum.repos.d/zfs.repo
     [zfs]
     name=ZFS on Linux for EL 7 - dkms
     baseurl=http://download.zfsonlinux.org/epel/7/$basearch/
     enabled=0
     metadata_expire=7d
     gpgcheck=1
     gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
     @@ -9,7 +9,7 @@
     [zfs-kmod]
     name=ZFS on Linux for EL 7 - kmod
     baseurl=http://download.zfsonlinux.org/epel/7/kmod/$basearch/
     enabled=1
     metadata_expire=7d
     gpgcheck=1
     gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux# 

установить саму zfs

    # yum install zfs -y
    Complete!

выключить модуль ядра, отвечающий за zfs

    # modprobe zfs

создать lvm-том

    # lsblk
    NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda                       8:0    0   40G  0 disk 
    ├─sda1                    8:1    0    1M  0 part 
    ├─sda2                    8:2    0    1G  0 part /boot
    └─sda3                    8:3    0   39G  0 part 
      ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
      └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
    sdb                       8:16   0   10G  0 disk 
    sdc                       8:32   0    2G  0 disk 
    sdd                       8:48   0    1G  0 disk 
    sde                       8:64   0    1G  0 disk 
    # pvcreate /dev/sdc
    Physical volume "/dev/sdc" successfully created.
    # vgcreate vg_opt /dev/sdc
    Volume group "vg_opt" successfully created
    # lvcreate -l+80%FREE -n lv_opt vg_opt
    Logical volume "lv_opt" created.

проверить нет ли zfs-пулов. В данном случае их нет

    # zpool list
    no pools available

создать zfs-пул
 
    # zpool create pool0 /dev/vg_opt/lv_opt
    
проверить как создалось

    # zpool list
    NAME    SIZE  ALLOC   FREE  EXPANDSZ   FRAG    CAP  DEDUP  HEALTH  ALTROOT
    pool0  1.58G   272K  1.58G         -     0%     0%  1.00x  ONLINE  -

создать ФС на пуле
 
    # zfs create pool0/opt

посмотреть все свойства ФС

    # zfs get all pool0/opt

установить точку монтирования

    # zfs set mountpoint=/opt pool0/opt
    NAME       PROPERTY    VALUE       SOURCE
    pool0/opt  mountpoint  /opt        local

посмотрим точку монтирования

    # mount | grep /opt
    pool0/opt on /opt type zfs (rw,seclabel,xattr,noacl)

снимем снапшот

    # zfs snapshot pool0/opt@snap1

проверим работоспобность снапшота

    # ls
    file1   file11  file13  file15  file17  file19  file20  file4  file6  file8
    file10  file12  file14  file16  file18  file2   file3   file5  file7  file9
    # rm -f file{11..20}
    # ls
    file1  file10  file2  file3  file4  file5  file6  file7  file8  file9
    # zfs rollback pool0/opt@snap1
    # ls
    file1   file11  file13  file15  file17  file19  file20  file4  file6  file8
    file10  file12  file14  file16  file18  file2   file3   file5  file7  file9

посмотреть список снапшотов

    # zfs list -t snapshot
    NAME              USED  AVAIL  REFER  MOUNTPOINT
    pool0/opt@snap1    14K      -    39K  -

# #4_2 применение lvm cache

http://man7.org/linux/man-pages/man7/lvmcache.7.html

т.к. у меня создан уже /dev/vg-opt/lv_opt, дальнейшее повествование про него

добавляем дополнительное блочное устройство

    # pvcreate /dev/sdd
      Physical volume "/dev/sdd" successfully created.
      
растягиваем VolumeGroup (vg) на новое блочное устройство

    # vgextend vg_opt /dev/sdd
    Volume group "vg_opt" successfully extended

создать lv для данных кэша (cache data)

    # lvcreate -n cache0 -L 600M vg_opt /dev/sdd
    Logical volume "cache0" created.

создать lv для метаданных кэша (cache metadata)

    # lvcreate -n cache0meta -L 12M vg_opt /dev/sdd
    Logical volume "cache0meta" created.

посмотрим что получилось

    # lvs -a vg_opt
      LV         VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
      cache0     vg_opt -wi-a----- 600.00m                                                    
      cache0meta vg_opt -wi-a-----  12.00m                                                    
      lv_opt     vg_opt -wi-ao----   1.59g

соберем кэши метаданных и данных в кэш-пул (cache-pool)

    # lvconvert --type cache-pool --poolmetadata vg_opt/cache0meta vg_opt/cache0
      WARNING: Converting vg_opt/cache0 and vg_opt/cache0meta to cache pool's data and metadata volumes with metadata wiping.
      THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)
    Do you really want to convert vg_opt/cache0 and vg_opt/cache0meta? [y/n]: y
      Converted vg_opt/cache0 and vg_opt/cache0meta to cache pool.

посмотрим как собралось

    # lvs -a vg_opt
      LV              VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
      cache0          vg_opt Cwi---C--- 600.00m                                                    
      [cache0_cdata]  vg_opt Cwi------- 600.00m                                                    
      [cache0_cmeta]  vg_opt ewi-------  12.00m                                                    
      lv_opt          vg_opt -wi-ao----   1.59g                                                    
      [lvol0_pmspare] vg_opt ewi-------  12.00m       

создаем lv кэша (cache LV), зацепив кэш-пул (cache pool LV) к lv_opt (origin LV)

    # lvconvert --type cache --cachepool vg_opt/cache0 vg_opt/lv_opt
    Do you want wipe existing metadata of cache pool vg_opt/cache0? [y/n]: y
    Logical volume vg_opt/lv_opt is now cached.

проверим как оно себя чувствует

    # lvs -a vg_opt
      LV              VG     Attr       LSize   Pool     Origin         Data%  Meta%  Move Log Cpy%Sync Convert
      [cache0]        vg_opt Cwi---C--- 600.00m                         0.01   0.98            0.00            
      [cache0_cdata]  vg_opt Cwi-ao---- 600.00m                                                                
      [cache0_cmeta]  vg_opt ewi-ao----  12.00m                                                                
      lv_opt          vg_opt Cwi-aoC---   1.59g [cache0] [lv_opt_corig] 0.01   0.98            0.00            
      [lv_opt_corig]  vg_opt owi-aoC---   1.59g                                                                
      [lvol0_pmspare] vg_opt ewi-------  12.00m                                                                

TODO не могу понять почему у меня _lvol0_pmspare_ появился в примере его нет

LVM кэш собран

если интересно как удалить кэш с сохранением/без сохранения originLV смотри в инструкцию
http://man7.org/linux/man-pages/man7/lvmcache.7.html
