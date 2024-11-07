#!/bin/bash

MYSQL_SERVICE="mysql"

function check_mysql {
  docker compose exec $MYSQL_SERVICE mysqladmin ping --silent
}

echo "Waiting for MySQL..."

MAX_WAIT_TIME=60
WAIT_TIME=0

while ! check_mysql; do
  if [ $WAIT_TIME -ge $MAX_WAIT_TIME ]; then
    echo "MySQL has not been available for $MAX_WAIT_TIME secods. Exit."
    exit 1
  fi
  sleep 1
  WAIT_TIME=$((WAIT_TIME + 1))
done

sleep 5
echo "MySQL ready."