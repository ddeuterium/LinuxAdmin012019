### Docker

Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)

в докерфайле должны быть следующие конструкции

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

важно, при создании образов и контейнеров НАДО называть их с помощью флага _--name_, иначе они будут получать случайные названия, вычисляемые из хэша