import subprocess as sub
import json
import re

spark_master_create = "docker service create --name master --publish 4040:4040 --publish 6066:6066 --publish 7077:7077 --publish 8078:8080 --publish 8075:8075 --env ZEPPELIN_PORT=8080 --env SPARK_CONF_DIR=/conf --env SPARK_PUBLIC_DNS=localhost --env SPARK_MASTER_WEBUI_PORT=8075 --network docker_network dylanmei/zeppelin"

spark_worker_create = "docker service create --name worker --env SPARK_CONF_DIR=/conf --env SPARK_WORKER_CORES=1 --env SPARK_WORKER_MEMORY=1g --env SPARK_WORKER_PORT=8881 --env SPARK_WORKER_WEBUI_PORT=8081 --env SPARK_PUBLIC_DNS=localhost --network docker_network gettyimages/spark"

# create master
exitcode = sub.call(["bash", "-c", spark_master_create])

# get information for master
#output = sub.check_output(["bash", "-c", "docker service inspect master"])
#output = json.loads(output.decode("utf-8"))



output = sub.check_output(["bash", "-c", "docker service ps master"])
#print(output)
output = output.decode("utf-8")
#print(output)
output = output.strip().splitlines()
#print(output)
output = list(map((lambda y: re.split(r"\s{2,}", y)), output))

#print(output)

master_id = output[1][1] + "." + output[1][0]

print(master_id)

spark_worker_create = 'docker service create --name worker --env SPARK_CONF_DIR=/conf --env SPARK_WORKER_CORES=1 --env SPARK_WORKER_MEMORY=1g --env SPARK_WORKER_PORT=8881 --env SPARK_WORKER_WEBUI_PORT=8081 --env SPARK_PUBLIC_DNS=localhost --network docker_network gettyimages/spark'

#bash -c "bin/spark-class org.apache.spark.deploy.worker.Worker spark://' + master_id + ':7077"

exitcode = sub.call(["bash", "-c", spark_worker_create])