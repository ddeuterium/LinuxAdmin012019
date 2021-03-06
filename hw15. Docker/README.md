### Docker

Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx). В докерфайле должны быть следующие конструкции

    FROM image name
    RUN apt update -y && apt upgrade -y
    COPY или ADD filename /path/in/image
    EXPOSE portopenning
    CMD or ENTRYPOINT or both

Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.

Дать письменно ответы на вопросы:
1. Определите разницу между контейнером и образом
2. Можно ли в контейнере собрать ядро?

Задание со * (звездочкой)
Создайте кастомные образы nginx и php, объедините их в docker-compose. После запуска nginx должен показывать php info. Все собранные образы должны быть в docker hub

#### basic hw

    $ docker pull shaadowsky/shaad
    $ docker run --name otus-nginx -dp 80:80 shaadowsky/shaad

#### answers

Q. Определите разницу между контейнером и образом
A. образ - слепок будущих контейнеров, контейнер - запущенный экземпляр образа
Q. Можно ли в контейнере собрать ядро?
A. по идее, собрать ядро в контейнере можно, надо собрать окружение для сборки.

#### useful links

https://wiki.merionet.ru/servernye-resheniya/9/kak-rabotat-s-dockerfile/
https://rtfm.co.ua/docker-dobavit-svoj-obraz-v-repozitorij-na-docker-hub/
https://habr.com/ru/post/310460/#feedback
https://www.8host.com/blog/samye-rasprostranyonnye-oshibki-pri-rabote-s-docker/

#### memo & history

установить docker в ubuntu 1804

    # apt install -y docker.io docker

у меня была проблема с запуском докера:

        $ sudo systemctl start docker && sudo systemctl enable docker
        Failed to start docker.service: Unit docker.service is masked

после воскурения манов обнаружилось, что _masked_ это усиленный _disabled_. Лечится это следующим образом:

    $ sudo systemctl unmask docker.service 
    Removed /etc/systemd/system/docker.service.
    $ sudo systemctl unmask docker.socket
    $ sudo systemctl start docker.service 

проверим

    $ sudo systemctl list-unit-files | grep docker
    docker.service                             enabled        
    docker.socket                              enabled        

создадим контейнер из DockerHub. -it как опциональную функцию, чтобы дать контейнеру интегрированный терминал. Мы можем подключиться терминалу, а также запустить команду bash. Проброс порта в формате guest:host

    # docker run -d -p 80:80 nginx:alpine

проверим

    $ sudo docker ps -a
    CONTAINER ID        IMAGE               COMMAND                  CREATED          STATUS              PORTS                NAMES
    529c46e3cffd        nginx:alpine        "nginx -g 'daemon of…"   3 minutes ago       Up 3 minutes        0.0.0.0:80->80/tcp   mystifying_carson

подключаемся. _-it_ значит _--interactive --tty_ (оставить STDIN открытым, даже если контейнер запущен в неприкрепленном режиме и запустить псевдотерминал)

    $ docker exec -it 529c46e3cffd bash
    OCI runtime exec failed: exec failed: container_linux.go:348: starting container process caused "exec: \"bash\": executable file not found in $PATH": unknown

упс, в Alpine нет баша, подключимся в sh. Выходить по ctrl+d

    $ docker exec -it 529c46e3cffd sh
    / # 

ВАЖНО:
1. при создании контейнера можно ссылаться на локальный Dockerfile, типа так

     docker build -t shaad .
     Где . значит, что докерфайл лежит в этой же папке

2. при создании контейнеров НАДО называть их с помощью флага _--name_, иначе они будут получать случайные названия, вычисляемые из хэша

локальные образа можно запускать вот так:

    $ docker run --name test -dp 80:80 shaad
    Где --name test задает имя контейнера, -dp 80:80 задает проброс порта, shaad имя образа.

перед тем как запушить готовый образ, надо сделать:

    $ docker login
    $ docker tag YOURIMAGE YOUR_DOCKERHUB_NAME/YOURIMAGE

потом

    $ docker push YOUR_DOCKERHUB_NAME/YOURIMAGE


