### MySQL

#### homework

1. развернуть базу из дампа _bet.dmp_ и настроить репликацию
2. базу развернуть на мастере и настроить чтобы реплицировались таблицы _bookmaker_, _competition_, _market_, _odds_ и _outcome_

* Настроить GTID репликацию

варианты которые принимаются к сдаче
- рабочий вагрантфайл
- скрины или логи SHOW TABLES
* конфиги
* пример в логе изменения строки и появления строки на реплике

### выполнение

percona-server-57 устанавливается vagrant'ом, подкладывает нужные файлы из /vagrant/conf/conf.d/ в /etc/my.cnf.d/ и запускает мускул

По умолчанию Percona хранит файлы в таком виде:
● Основной конфиг в /etc/my.cnf
● Так же инклудится директория /etc/my.cnf.d/ - куда мы и будем
складывать наши конфиги.
● Дата файлы в /var/lib/mysql

При установке Percona автоматически генерирует пароль для пользователя root и кладет его в
файл /var/log/mysqld.log:

    # cat /var/log/mysqld.log | grep 'root@localhost:' | awk '{print $11}'
    pass

Подключаемся к mysql и меняем пароль для доступа к полному функционалу:

    # mysql -u root -p 
    mysql > ALTER USER USER() IDENTIFIED BY 'YourStrongPassword';

Для успешной работы репликации __обязательно__ должны быть разные _server-id_

    mysql> SELECT @@server_id;

Проверяем, что GTID включен

    mysql> SHOW VARIABLES LIKE 'gtid_mode';

На мастере создать базу _bet_, загрузить в неё дамп и проверить

    mysql> CREATE DATABASE bet;
    Query OK, 1 row affected (0.00 sec)

    # mysql -u root -p -D bet < /vagrant/bet.dmp
    mysql> USE bet;
    mysql> SHOW TABLES;
    +-------------------+
    | Tables_in_bet     |
    +-------------------+
    | bookmaker         |
    | competition       |
    | events_on_demand  |
    | market            |
    | odds              |
    | outcome           |
    | v_same_event      |
    +-------------------+

Создадим пользователя для репликации и даем ему права на ÿту самуя репликация:

    mysql> CREATE USER 'repl'@'%' IDENTIFIED BY '!OtusLinux2018';
    mysql> SELECT user,host FROM mysql.user where user='repl';
    +------+-----------+
    | user | host      |
    +------+-----------+
    | repl | %         |
    +------+-----------+
    mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY '!OtusLinux2018';

Сдампить базу для заливки на слэйв, проигнорировав таблицы по заданию

    # mysqldump --all-databases --triggers --routines --master-data --ignore-table=bet.events_on_demand --ignore-table=bet.v_same_event -uroot -p > master.sql

На слейве вагрантом меняются:
- _/conf/conf.d/01-base_ server-id выставлен в значение 2
- _/conf/conf.d/05-binlog.cnf_ указывает игнорирование таблиц bet.events_on_demand и bet.v_same_event

Заливаем дамп мастера

    (на мастере)
    # rsync master.sql root@192.168.20.102:/root/
    
    (на слейве)
    mysql> SOURCE /mnt/master.sql
    mysql> SHOW DATABASES LIKE 'bet';
    +-------------------+
    | Database (bet)    |
    +-------------------+
    | bet               |
    +-------------------+
    mysql> USE bet;
    mysql> SHOW TABLES;
    +-------------------+
    | Tables_in_bet     |
    +-------------------+
    | bookmaker         |
    | competition       |
    | market            |
    | odds              |
    | outcome           |
    +-------------------+

Подклячаем и запускаем слейв:

    mysql> CHANGE MASTER TO MASTER_HOST = "192.168.20.101", MASTER_PORT = 3306, MASTER_USER = "repl", MASTER_PASSWORD = "!OtusLinux2018", MASTER_AUTO_POSITION = 1;
    mysql> START SLAVE;
    mysql> SHOW SLAVE STATUS\G

