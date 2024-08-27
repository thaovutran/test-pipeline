#!/bin/bash

echo "Starting Docker daemon..."
sudo dockerd > /home/jenkins/dockerd.log 2>&1 &

tries=0
until docker info > /dev/null 2>&1; do
    tries=$((tries+1))
    if [ $tries -ge 20 ]; then
        echo "Docker daemon failed to start."
        exit 1
    fi
    sleep 1
done

echo "Docker daemon is running."

exec /usr/local/bin/jenkins-agent "$@"
