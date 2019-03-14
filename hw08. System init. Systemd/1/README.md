скрипты [file-copy.sh](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/1/file-copy.sh) и [file-move.sh](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/1/file-move.sh). Существует для облегчения жизни: копирования файлов в ВМ и переноса файла в нужные места

[watchdog](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/1/watchdog) файл с переменными WORD (какое слово мониторим) и LOG (где лежит лог для наблюдения)

[watchlog.log](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/1/watchlog.log) тренировочный лог

[watchlog.sh](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/1/watchlog.sh) скрипт, добавляющий через logger в _/var/log/messages_. Почему-то в мурзилке указано сделать _if grep $WORD $LOG &> /dev/null_, но взлетает с _if [ "grep $WORD $LOG &> /dev/null" ];_

[watchlog.service](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/1/watchlog.service) unit-файл самого сервиса. Сделан как oneshot, для запуска демоном используется notify и др.

[watchlog.timer](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/1/watchlog.timer) Таймер, несмотря на указание запуска раз в 30 секунд, будет отрабатывать ежеминутно из-за глобальной переменной точности systemd.timer

если не взлетают скрипты надо сделать _chmod +x <script>_
