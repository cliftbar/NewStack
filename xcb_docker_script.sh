#!/bin/bash


#echo $1
case $1 in
    'up' )
        echo Setting up docker""
        docker-compose up -d --force-recreate
        for i in {1..5}
        do
            #echo $i
            var=$(docker exec -it newstack_kafka_1 bash  -c "/opt/kafka_2.11-0.8.2.1/bin/kafka-topics.sh --zookeeper \$ZOOKEEPER --list")
            #echo "var: $var"
            if [ -n "$var" ]; then
                echo "Test topic created"
                break
            else
            echo "Attempt $i to create topic"
                docker exec -it newstack_kafka_1 sh /kafka/create_test_topic.sh
            fi
        done
        firefox http://0.0.0.0:8073/ http://0.0.0.0:8080/ http://0.0.0.0:8081/ http://0.0.0.0:8082/ &
        docker-compose logs --follow
        ;;
    'down' )
        echo 'Shutting down Docker'
        docker-compose down
        ;;
    * )
        echo "unsupported arguement '$1'.  Use 'up' or 'down'."
        ;;
esac

