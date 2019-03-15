В [unit](https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw08.%20System%20init.%20Systemd/4.%20jira/jira.service) определить переменные CATALINA_HOME, CATALINA_BASE, CATALINA_TMPDIR, JIRA_HOME, CATALINA_OPTS(tomcat env), JRE_HOME, CLASSPATH, CATALINA_PID и опции для tomcat, например - выделение памяти под heap

посмотреть диагностический лог можно в _/opt/atlassian/jira/logs/catalina.out_

будет сопротивляться - это selinux ругается

    setenforce 0
