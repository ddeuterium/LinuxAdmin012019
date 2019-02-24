#!/bin/bash

# в соответствии с лучшими практиками занулим суперблоки.
# Конструкция /dev/sd{b..f} может выглядеть как /dev/sd{b,c,d,e,f}
sudo mdadm --zero-superblock --force /dev/sd{b..f}

# Если диски новые, то никаких суперблоков там нет и будет ругаться
# вот так mdadm: Unrecognised md component device - /dev/sdb

# создаем raid 5. Опция --level или -l отвечает за уровень рейда,
# опция -n отвечает за количество дисков
sudo mdadm --create --verbose /dev/md0 --level 5 -n 5 /dev/sd{b..f}

# создаем папку для конфига raid и файл конфигурации
sudo mkdir /etc/mdadm/
sudo touch /etc/mdadm/mdadm.conf
sudo echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

# создадим на gpt раздел на raid
sudo parted -s /dev/md0 mklabel gpt

# создадим 5 партиций
sudo parted /dev/md0 mkpart primary ext4 0% 20%
sudo parted /dev/md0 mkpart primary ext4 20% 40%
sudo parted /dev/md0 mkpart primary ext4 40% 60%
sudo parted /dev/md0 mkpart primary ext4 60% 80%
sudo parted /dev/md0 mkpart primary ext4 80% 100%

# parted работает так:
# parted [целевое устройство (ЦУ)] [что делаем] [первичная/логическая] [тип ФС] [место начала раздела на ЦУ] [место окончания раздела на ЦУ]

# в процессе будет ругаться вот так:
# Information: You may need to update /etc/fstab.
# это значит - добавь меня в /etc/fstab. Если не добавить, то оно не будет монтироваться при загрузке

# создаем ФС на партициях
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done

# создадим точки монтирования, опция -p (--parents) говорит создавать родительские каталоги, если их нет. 
sudo mkdir -p /raid/part{1..5}

# замонтируем созданные партиции
for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done
