## Web-servers

### homework

Простая защита от DDOS
Написать конфигурацию nginx, которая даёт доступ клиенту только с определенной cookie.

** Защита от продвинутых ботов связкой nginx + java script

Защиту из предыдудщего задания можно проверить/преодолеть командой curl -c cookie -b cookie http://localhost/otus.txt -i -L
Ваша задача написать такую конфигурацию, которая отдает контент клиенту умеющему java script и meta-redirect

Необходимо редактировать nginx.conf из этого репозитория (не следует использовать include и править Dockerfile)

Cделанную работу нужно залить hub.docker.com, при этом content в otus.txt должен содержать в себе название Вашего репозитория hub.docker.com и только его

Базовое задание должно быть в образе с тегом latest, задание для продвинутых в образе с тегом advanced.

### проверка

выполнить

    docker run -p 80:80 shaadowsky/ddos:latest
    curl http://localhost/otus.txt -i -L    # проверка без куки
    curl http://localhost/otus.txt -i -L -b cookie -c cookie    # проверка с куки

в ответе будет 302 и 200

### выполнение

собрать образ

    docker build -t ddos .

запустить контейнер

    docker run --rm -d -p 80:80 ddos

проверить ss/netstat, что контейнер слушает на 80 порту

подключиться к докерхабу

    docker login

задать тег latest

    docker tag ddos:latest shaadowsky/ddos:latest

запушить образ

    docker push shaadowsky/ddos:latest