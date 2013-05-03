 #!/bin/bash

# This start and stop script is only meant for local development!!!

mongo_process=`ps aux | grep -v grep | grep mongo`

if [ ${#mongo_process} -gt 0 ]
then
  echo 'MongoDB is running!'
else
  echo 'Starting MongoDB....'
  mongod --fork --logpath /usr/local/var/log/mongodb/mongo.log
fi


memcache_process=`ps aux | grep -v grep | grep memcached`

if [ ${#memcache_process} -gt 0 ]
then
  echo 'memcached is already running!'
else
  memcached -d -l 127.0.0.1 -p 11211
fi

