дано: 
Делаем собственную сборку ядра 
Взять любую версию ядра с kernel.org 
Подложить файл конфигурации ядра 
Собрать ядро (попутно доставляя необходимые пакеты) 
Прислать результирующий файл конфигурации 
Прислать списк доустановленных пакетов, взять его можно из /var/log/yum.log
Устанавливать будем на следующем занятии =) 
Критерии оценки: 
- Ядро собрано 
- Прислан результирующий файл конфигурации 
- Прислан списк доустановленных пакетов

disclamer
linux-hw1 = 1st linux homework
29-30.01.2019
сделано на основе занятия LPIC 201.2 Семаева
https://www.youtube.com/watch?v=LDImATiV0nc
вероятно, я бы наступил на бОльшее количество граблей, если бы сделал
как на последнем слайде. Попробую позже
    
    cd /usr/src
    wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.9.153.tar.xz
    ls
внезапно обнаружил, что скачал два одинаковых ядра. Отвлекался в процессе

    man mv
    mv linux-4.9.153.tar.xz.1 linux-4.9.153.tar.xz
    ls
опция -J работает с архивами *.xz

    tar -Jxvf linux-4.9.153.tar.xz
    ls
    rm -rf linux-4.9.153.tar.xz
    ls
создал ссылку, так было у Семаева. Наверное, в своем курсе дальше
рассказывает зачем она нужна

    ln -s linux-4.9.153/ linux
    ls -la
позырил внутрь

    less cpu-load.txt
    yum groupinstall "Development Tools" -y
    yum install ncurses-devel -y
    ls
    cd linux
    make mrproper
    make menuconfig
    ls
menu *config создает файл .config

    less .config
на всякий случай проверить зависимостиб но т.к. ничего не менял все было ОК

    make dep
у меня не оказалось этого пакета

    yum install elfutils-libelf-devel -y
    make dep
    make bzImage
у меня не оказалось этого пакета
по идее запуск make с флагом -j распараллелит процесс, но я так еще не пробовал

    yum install bc
    make bzImage
у меня не оказалось этого пакета
    
    yum install openssl-devel -y
    make bzImage
    make modules
    make modules_install
    make install
    reboot
    uname -r
внезапно версия ядра та же, надо поправить grub

    cat /boot/grub2/grub.cfg | grep menuentry
    nano /etc/default/grub
    vim /etc/default/grub
блин, в центосе нет ни нано, ни вима

    yum install nano
    nano /etc/default/grub
поменять значение grub_default на 0 (было saved)
перегенерировать grub

    grub2-mkconfig -o /boot/grub2/grub.cfg
    reboot
    uname -r
ура, я его победил
