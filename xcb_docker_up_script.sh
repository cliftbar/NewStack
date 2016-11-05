#!/bin/bash

docker-compose up -d --force-recreate
sleep 5
docker exec -it newstack_kafka_1 sh /kafka/create_test_topic.sh
docker-compose logs --follow
