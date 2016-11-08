#!/bin/bash


#echo $1
case $1 in
    'up' )
        echo Setting up docker""
        docker-compose up -d --force-recreate
        
        # Loop to make sure any post start docker scripts run
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
        
        # Launch web interfaces
        firefox http://0.0.0.0:8073/nifi/ http://0.0.0.0:8080/ http://0.0.0.0:8081/ http://0.0.0.0:8082/ &
        
        #curl -iv -F template=@nifi/TsvToKafka.xml -X POST  http://0.0.0.0:8073/nifi-api/process-groups/root/templates/upload
        #curl -iv -d '{"templateId":"6da1f04f-ee0e-4a84-adac-c28f400a8c8a", "originX": 0.0, "originY": 0.0}' -X POST -H "Content-Type: application/json"  http://0.0.0.0:8073/nifi-api/process-groups/root/template-instance

        # Continue tailing the logs
        docker-compose logs --follow
        ;;
    'down' )
        echo 'Shutting down Docker'
        docker-compose down
        ;;
    'logs' )
        docker-compose logs --follow
        ;;
    'help' )
        echo "'up' sets up docker compose.
'down' spins down the session.
'logs' tails the docker-compose logs."
        ;;
    * )
        echo "unsupported arguement '$1'.  Use 'up', 'down', 'logs', or 'help'."
        ;;
esac

