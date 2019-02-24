#!/usr/bin/env bash

# TODO запилить проверку почтового пакета, его может не быть

SERVICES="mysqld"
lockfile=/tmp/localfile


echo "Checking existing directory /tmp/"
  if ! [ -d /tmp/ ]; 
    then
      mkdir /tmp/
      echo "No directory /tmp/. Creating..."
      echo ""
      if ! [ -e /tmp/watchdog.log ];
        then
          touch /tmp/watchdog.log
      fi
    else
      echo "directory /tmp/ existing"
      echo ""
  fi

for SERVICE in ${SERVICES}
  do
    service $SERVICE status &> /tmp/watchdog.log

    if [ $? -ne 0 ];
      then
        sudo service $SERVICE restart
        echo $SERVICE "restarted" | mail -v -s "$SERVICE restarted" -S smtp="smtp.gmail.com:587" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="pva12.test@gmail.com" -S smtp-auth-password="zaqZAQzaq" -S ssl-verify=ignore -S nss-config-dir=/etc/pki/nssdb -S from=pva12.test@gmail.com shaadowsky@gmail.com
      else
        echo -e "$SERVICE is running! All right ..."
    fi


done


