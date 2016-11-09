#!/bin/bash


#echo $1
case $1 in
    'up' )
        echo "Setting up docker."
        docker-compose up -d --force-recreate
        
        # Loop to make sure kafka topics created
        for i in {1..5}
        do
            #echo $i
            var=$(docker exec -it newstack_kafka_1 bash  -c "/opt/kafka_2.11-0.8.2.1/bin/kafka-topics.sh --zookeeper \$ZOOKEEPER --list")
            #echo "var: $var"
            if [ -z "$var" ]; then
                echo "Test topic created"
                break
            else
            echo "Attempt $i to create topic"
                docker exec -it newstack_kafka_1 sh /kafka/create_test_topic.sh
            fi
        done
        
        # Loop to make sure any nifi template starts
        for i in {1..10}
        do
            py_var=$(python3 nifi/start_template.py)
            #echo "var: '$py_var'"
            if [ -z "$py_var" ]; then
                echo "Nifi template launched."
                break
            fi
            echo "Attempt $i to launch nifi template."
            sleep 6
        done
        
        # Launch web interfaces
        firefox http://0.0.0.0:8073/nifi/ http://0.0.0.0:8080/ http://0.0.0.0:8081/ http://0.0.0.0:8082/ &
        
        # Continue tailing the docker-compose logs
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

