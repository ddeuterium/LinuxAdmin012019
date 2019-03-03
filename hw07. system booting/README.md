Работа с загрузчиком
1. Попасть в систему без пароля несколькими способами
2. Установить систему с LVM, после чего переименовать VG
3. Добавить модуль в initrd

4(*). Сконфигурировать систему без отдельного раздела с /boot, а только с LVM
Репозиторий с пропатченым grub: https://yum.rumyantsev.com/centos/7/x86_64/
PV необходимо инициализировать с параметром --bootloaderareasize 1m
Критерии оценки: Описать действия, описать разницу между методами получения шелла в процессе загрузки.
Где получится - используем script, где не получается - словами или копипастой описываем действия.

существует 3 способа войти в систему без пароля, если есть к ней физический доступ или удаленка на этап загрузки ядра. Во всех случаях надо выбрать ядро и нажать кнопку E(dit). После этого в конец строки, начинающейся на linux16 (linuxefi если на машине EFI), добавить:

1. # init#=/bin/sh# Загрузится минимальный shell, поменять пароль не получится, либо нужно сильное колдунство, т.к. нет команды chroot

2. # rd.break# отсюда можно сбросить пароль рута. Лучше сделать так: # rw rd.break enforcing=0#, это позволит не подкидывать данные SElinux об изменном пароле. Мало такого, такой способ является рекомендованным [Procedure 25.6 RedHat Adm. Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/sec-terminal_menu_editing_during_boot#proc-Resetting_the_Root_Password_Using_rd.break#Procedure%2025.6.) #rw# монтирует /sysroot ReadWrite, #enforcing=0# позволит не подкидывать данные для SELinux (touch /.autorelabel)

    mount -o remount,rw /sysroot
    chroot /sysroot
    passwd
    touch /.autolabel
    exit
    exit
  
#пойдет загрузка системы
  
3. # init=/sysroot/bin/sh# работает примерно как п.2, только не работает флаг enforcing=0 и надо перезагружать.


