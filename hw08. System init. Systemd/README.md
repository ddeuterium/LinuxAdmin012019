[1. Написать сервис](https://github.com/shaadowsky/LinuxAdmin012019/tree/master/hw08.%20System%20init.%20Systemd/1), который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig. 

[2. переписать init-скрипт на unit-файл](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/2/README.md). Из epel установить spawn-fcgi. Имя сервиса должно так же называться.

Unit-файлы более удобная штука, чем init-файлы. Ими удобней управлять.

[3. Дополнить юнит-файл apache httpd]() возможностью запустить несколько инстансов сервера с разными конфигами

4*. Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл


