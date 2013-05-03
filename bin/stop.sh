 #!/bin/bash

# This start and stop script is only meant for local development!!!

mongo_process=`ps aux | grep -v grep | grep mongo`

if [ ${#mongo_process} -gt 0 ]
then
  echo 'Stopping MongoDB...'
  pkill mongod
fi

memcache_process=`ps aux | grep -v grep | grep memcached`

if [ ${#memcache_process} -gt 0 ]
then
  echo 'Stopping memcached...'
  pkill memcached
fi

