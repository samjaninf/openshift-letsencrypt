#!/bin/bash

# install letsencrypt if not in persistentvolume
if [ ! -f /var/ssl/domains.txt ]; then
  cp -vfpr /tmp/ssl/* /var/ssl/
  cp /README /var/ssl
fi

cd /var/ssl
/root/letsencrypt.sh/letsencrypt.sh -c
rm certs.tgz > /dev/null 2>&1; rm certs.tgz.cpt; tar zcf certs.tgz certs
if [ -f /var/ssl/ccryptkey ]; then
  ccencrypt -K `cat ccryptkey` certs.tgz
fi

sleep 3600

# access log rotation
if [ ! -f /var/ssl/access.log ]; then
  file=/var/ssl/access.log
  minimumsize=100
  actualsize=$(wc -c <"$file")
  if [ $actualsize -ge $minimumsize ]; then
      echo "rotate nginx access.log";
      rm -f /var/ssl/access.log
      kill -USR1 `cat /var/run/nginx.pid`
  fi
fi

# error log rotation
if [ ! -f /var/ssl/access.log ]; then
  file=/var/ssl/error.log
  minimumsize=100
  actualsize=$(wc -c <"$file")
  if [ $actualsize -ge $minimumsize ]; then
      echo "rotate nginx error.log";
      rm -f /var/ssl/error.log
      kill -USR1 `cat /var/run/nginx.pid`
  fi
fi

# sleep 10 minutes
sleep 10m
