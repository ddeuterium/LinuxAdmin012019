# Почта

### hw

установка почтового сервера

1. Установить в виртуалке postfix+dovecot для приёма почты на виртуальный домен любым обсужденным на семинаре способом
2. Отправить почту телнетом с хоста на виртуалку
3. Принять почту на хост почтовым клиентом

Результат

1. Полученное письмо со всеми заголовками
2. Конфиги postfix и dovecot

Всё это сложить в git, ссылку прислать в "чат с преподавателем"

#### для стенда

1. https://habr.com/ru/post/193220/ (сделано по центос 6, я делал на центос 7)
2. https://hostpresto.com/community/tutorials/how-to-install-clamav-on-centos-7/ (установка clamav)

### теория

MTA - Mail Transfer Agent - сервис передачи сообщения
MDA - Mail Delivery Agent - сервис получения и доставки сообщения
пользователю
LDA - Local Delivery Agent - сервис получения и доставки сообщения
пользователю в пределах одной системы
Postfix - MTA, MDA и LDA
Dovecot - MDA и LDA
MTA - sendmail, postfix, qmail, exim
MDA - dovecot
LDA - postfix, dovecot

За обнаружение почтового сервера отвечает запись в зоне домена типа MX
Но до сих пор, для обратной совместимости, если нет записи MX, то
используется запись типа A

Все существующие почтовые системы оперируют
• очередями - директорией с файлами писем
• почтовыми ящиками - файлом (mailbox) или директорией (maildir) с файлами сообщений
Очереди - бутылочное горлышко всех почтовых систем. Нужны, что бы не потерять почту.

DKIM (Domain Keys Identified Mail) - это øифровая подпись, которая подтверждает подлинность отправителя и гарантирует целостность доставленного письма
Особенности:

- используются два ключа шифрования: приватный для подписи сообщений и публичный для проверки подписи
- для доступа к публичному ключу по технологии DomainKeys используется DNS
- ключи добавлятся в служебные заголовки писем
- подпись автоматически проверяется почтовым сервером в соответствии с заданными политиками

DMARC (Domain-based Message Authentication, Reporting and Conformance) - это механизм защиты от спама и от несанкционированной рассылки почты с домена
Особенности:

- информирование почтового сервера получателя о наличии записей DKIM, SPF и их использовании
- рекомендаøии почтовому серверу получателя об обработке почты с невалидными DKIM и SPF
- получение обратной связи от серверов получателей в формате RFC 5969 и RFC 5070, которые позволят, в частности, узнать о несанкøионированной рассылке с домена

#### SPAM

Причины:

- боты и ботнеты
- открытые почтовые релеи
- зомби-сервера
- интерфейсы iKVM, iLo и прочие
- взломанные аккаунты почтовых систем
- некорректно настроенные тикет-системы (битва роботов)

Отличительные черты:

- невалидный обратный адрес
- неправильные заголовки
- хост отправления не является публичным MX
- не повторяят отправку
- тело письма содержит спам

Что делать, чтобы почта отправлялась?

- hostname сервера = A запись + PTR запись
- сервер должен быть в MX записях
- адрес отправителя должен быть валиден
- настроен SPF
- настроен DKIM
- настроен DMARC

Как защититься?

- проверка PTR записей
- проверка MX записей
- проверка SPF, DKIM
- проверка отправителя и получателя
- graylist (сервер временно недоступен)
- Blacklist, DNSBL (RBL) - не рекомендуется, но бывает
- использовать SpamAssassin или rspamd

### Postfix

Postfix построен по модульной архитектуре, т.е. состоит из кучи разных демонов, которые общаются между собой через unixсокеты и перекладывают почту между очередями и ящиками пользователя.

Утилиты:

- postqueue - смотрим оùереди
- postsuper - работа с писþмами в оùередāх (удаление, перезапуск)
- postalias - работа с базой даннýх алиасов
- postconf - работа с конфигураøией Postfix (просмотр, редактирование)
- postlog - записþ даннýх в лог Postfix (например в скриптах)
- postcat - просмотр содержимого файла в оùереди
- postmap - вýполнение запросов к вспомогателþнýм таблиøам или создание ÿтих таблиø

postqueue - утилита просмотра и управления очередью
-f или -i <id> или -s <site> - flush очереди или конкретного письма или писем для
домена
-p - просмотр очереди

postconf - утилита отображения конфигурационных параметров
-d - показать дефолтные значения
-n - показать только измененные в конфиге значения

Чтобы работать с чистым конфигом выполняем

    # postconf -n > /etc/main.cf-new
    # mv /etc/main.cf /etc/main.cf-orig && mv /etc/main.cf-new /etc/main.cf

Конфигурация postfix Состоит из двух файлов
main.cf - конфигурация всей почтовой системы
master.cf - конфигурация модулей почтовой системы

Читать про (конфиги)[http://www.postfix.org/postconf.5.html]

Многие параметры конфигураций принимают на вход таблицы

Простейшие таблицы - файловые (типа hash), их формат - значения, разделенные пробелами. Такие файлы не обязательно, но желательно хешировать (создавать индексы) утилитой postmap

Отдельный тяжелый случай - исторический файл /etc/aliases, который имеет формат "ключ: значение" и хешируется отдельной исторической командой newaliases

В качестве таблиц postfix поддерживает SQL, LDAP, etc...

Postfixadmin - веб-интерфейс длā работý с полþзователāми в базе

http://postfixadmin.sourceforge.net/

#### Dovecot

LDA и MDA
Может так же доставлять писма в почтовые ящики существующих
пользователей (как и настроен по-умолчанию), так и предоставлять
обслуживание виртуальных доменов.
Кроме того, как MDA, он реализует удалённый доступ к ящикам
пользователей по протоколам POP3/IMAP
Так же, как и postfix имеет утилиту doveconf, с таким-же параметром -n
Виртуальные домены - домены, которые не принадлежат хосту, пользователи этих доменов не
локальные. Т.е. именно то, что нам чаще всего нужно.

#### Варианты взаимодействия postfix и dovecot

1. (Postfix - MTA + LDA, Dovecot - MDA)[http://www.postfix.org/VIRTUAL_README.html]

+ Наиболее простая конфигурация
- Необходимость Dovecot сканировать папку пользователя
= Подходит для малых инсталляций

2. (Postfix - MTA, Dovecot - LDA + MDA)[https://wiki.dovecot.org/LDA/Postfix]

- Более сложная настройка
= Подходит для любых инсталляций

3. (Postfix - MTA + LDA, Dovecot - MDA)[http://www.postfix.org/VIRTUAL_README.html]

    /etc/postfix/main.cf:
     virtual_alias_domains = example.com ...other hosted domains...
     virtual_alias_maps = hash:/etc/postfix/virtual
     virtual_mailbox_base = /var/mail/mydomain
     virtual_mailbox_maps = hash:/etc/postfix/vmailbox
     virtual_minimum_uid = 100
     virtual_uid_maps = static:5000
     virtual_gid_maps = static:5000

   /etc/postfix/vmailbox:
    info@example.com info/Maildir
    sales@example.com sales/Maildir
    # Comment out the entry below to implement a catch-all.
    # @example.com catchall/Maildir
    ...virtual mailboxes for more domains...

   /etc/postfix/virtual:
    postmaster@example.com postmaster

   /etc/dovecot/dovecot.conf:
    mail_location = mailbox:/var/mail/mydomain/%u

4. (Postfix - MTA, Dovecot - LDA + MDA)[https://wiki.dovecot.org/LDA/Postfix#Virtual_users]

    /etc/postfix/master.cf
    dovecot unix - n n - - pipe
     flags=DRhu user=vmail:vmail
     argv=/usr/local/libexec/dovecot/dovecot-lda -f ${sender} -d ${recipient}

    /etc/postfix/main.cf
     dovecot_destination_recipient_limit = 1
     virtual_mailbox_domains = your.domain.here
     virtual_transport = dovecot

    /etc/dovecot/dovecot.conf
     mail_home = /var/vmail
     mail_location = mailbox:/var/vmail/mydomain/%u
     passdb {
      driver = passwd-file
      args = scheme=sha256 username_format=%n /etc/dovecot/users
     }
    userdb {
     driver = passwd-file
     args = username_format=%n /etc/dovecot/users
     default_fields = id=vmail id=vmail home=/var/vmail/%u 
    
    /etc/dovecot/users
     dolphin:{SHA256}pmWkWSBCL51Bfkhn79xPuKBKHz//H6B+mY6G9/eieuM=::::::
    
    # doveadm pw -s SHA256
    Enter new password:
    Retype new password:
    {SHA256}47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=

##### Postfix authentication

http://www.postfix.org/SASL_README.html

    /etc/dovecot/dovecot.conf
     service auth {
     ...
     unix_listener /var/spool/postfix/private/auth {
     mode = 0660ga
     # Assuming the default Postfix user and group
     user = postfix
     group = postfix
     }
     ...
     }
     auth_mechanisms = plain login
    
    /etc/postfix/main.cf
     smtpd_sasl_type = dovecot
     smtpd_sasl_path = private/auth
     smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, ...

Индексные файлы

https://wiki.dovecot.org/MailLocation

    /etc/dovecot/dovecot.conf
     mail_location = maildir:~/Maildir:INDEX=/var/indexes/%u

Релей

    /etc/postfix/main.cf
     relay_domains = domain1.com, domain2.com
     transport_maps = hash:/etc/postfix/transport
     relay_recipient_maps = hash:/etc/postfix/relay_recipients
     relay_transport = relay
    /etc/postfix/transport
     domain1.com smtp:[mail.example.com]
     domain2.com smtp:[mail.example.com]
    /etc/postfix/relay_recipients
     @domain1.com x
     @domain2.com x 

Литература:
1. про конфиг http://www.postfix.org/postconf.5.html
2. http://www.postfix.org/DATABASE_README.html
3. Один из гайдов с Хабра: https://habr.com/ru/post/193220/
4. Очень подробный гайд по Postfix: http://dummyluck.com/page/postfix_konfiguracia_nastroika
5. Сервис проверки доменов в блэк-листах: https://whatismyipaddress.com/blacklist-check
6. Сервис проверки доменов в блэк-листах: http://www.anti-abuse.org/multi-rbl-check
7. Многофункциональный сервис онлайн-проверок: https://mxtoolbox.com
8. Сервис для проверки SMTP-сервера: https://www.wormly.com/test-smtp-server
