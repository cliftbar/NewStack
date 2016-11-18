#!/bin/bash
#spark deploy

docker swarm init --advertise-addr 10.10.3.180

docker network create --driver overlay spark_net

docker service create --name proxy \
    --constraint 'node.role == manager' \
    -p 80:80 \
    -p 443:443 \
    -p 8080:8080 \
    --network spark_net \
    --mount type=bind,source=/home/cwbarclift/NewStack/docker_flow_proxy,destination=/consulTemplates \
    -e MODE=swarm \
    vfarcic/docker-flow-proxy
    
docker service create \
    --name master \
    --constraint 'node.role == manager' \
    --env MASTER=spark://tasks.master:7077 \
    --env ZEPPELIN_PORT=8070 \
    --env SPARK_CONF_DIR=/conf \
    --env SPARK_PUBLIC_DNS=localhost \
    --env SPARK_MASTER_WEBUI_PORT=8075 \
    --network spark_net \
    dylanmei/zeppelin bash -c "/usr/spark-2.0.1/bin/spark-class org.apache.spark.deploy.master.Master -h tasks.master"

    # & /usr/zeppelin/bin/zeppelin.sh"
    
docker service create \
    --name zeppelin \
    --constraint 'node.role == manager' \
    --env MASTER=spark://tasks.master:7077 \
    --env ZEPPELIN_PORT=8070 \
    --env SPARK_CONF_DIR=/conf \
    --env SPARK_PUBLIC_DNS=localhost \
    --network spark_net \
    dylanmei/zeppelin #bash -c "/usr/spark-2.0.1/bin/spark-class org.apache.spark.deploy.master.Master -h tasks.master & /usr/zeppelin/bin/zeppelin.sh"

#--env MASTER=spark://$(hostname -f):7077 \
    
docker service create \
    --name worker \
    --env SPARK_CONF_DIR=/conf \
    --env SPARK_WORKER_CORES=1 \
    --env SPARK_WORKER_MEMORY=1g \
    --env SPARK_WORKER_PORT=8881 \
    --env SPARK_WORKER_WEBUI_PORT=8076 \
    --env SPARK_PUBLIC_DNS=localhost \
    --network spark_net \
    gettyimages/spark bash -c "bin/spark-class org.apache.spark.deploy.worker.Worker spark://tasks.master:7077"
    
#docker service scale worker=2

sleep 6

var_2=$(curl "matebuntu:8080/v1/docker-flow-proxy/reconfigure?consulTemplateBePath=/consulTemplates/zeppelin_be_config.tmpl&consulTemplateFePath=/consulTemplates/zeppelin_fe_config.tmpl&serviceName=tasks.zeppelin&servicePath=/zeppelin&port=8070")

#sleep 1

#var_1=$(curl "matebuntu:8080/v1/docker-flow-proxy/reconfigure?serviceName=tasks.master&servicePath=/&port=8075")

#curl "matebuntu:8080/v1/docker-flow-proxy/reconfigure?serviceDomain=spark&serviceName=tasks.master&pathType=path&servicePath=/&port=8075"

#echo $var_2
#echo $var_1
#docker service update --publish-add 8078:8080 master
#docker service update --publish-add 8075:8075 master

    #--publish 8078:8080 \
    #--publish 8075:8075 \

#--network docker_network \