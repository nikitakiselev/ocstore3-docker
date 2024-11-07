#!/bin/bash

SERVICES=("web" "mysql")

function check_containers {
  for service in "${SERVICES[@]}"; do
    if ! docker compose ps $service | grep "Up" > /dev/null; then
      return 1
    fi
  done
  return 0
}

echo "Waiting for docker containers..."

MAX_WAIT_TIME=60
WAIT_TIME=0

while ! check_containers; do
  if [ $WAIT_TIME -ge $MAX_WAIT_TIME ]; then
    echo "Containers have not started within $MAX_WAIT_TIME seconds. Exit."
    exit 1
  fi
  sleep 1
  WAIT_TIME=$((WAIT_TIME + 1))
done

echo "Waiting for mysql..."
docker compose exec mysql bash -c 'mysqladmin ping -h localhost'

echo "All docker containers executed."
