# Sparklyr Docker Image

## Master Usage

`supervisord` starts
  - The rstudio web interface on `8787` 
  - The spark master UI on `8080`.

Add a mount point to persist spark jobs

```
--mount type=bind,dst=/root/rstudio/sparklyr,src=/home/ubuntu/spark-jobs
```

```
docker service create --name spark-master \
  --label 'com.sparklyr.service == spark-master' \
  --mode global \
  --network my-network \
  --constraint 'node.role == manager' \
  -e MASTER=spark://spark-master:7077 \
  -e SPARK_CONF_DIR=/conf \
  -e SPARK_PUBLIC_DNS=localhost \
  --publish 4040:4040 \
  --publish 6066:6066 \
  --publish 7077:7077 \
  --publish 8080:8080 \
  --publish 8787:8787 \
  akhilnairamey/sparklyr \
  /usr/bin/supervisord
```
 
## Worker Usage
 
May be a bit more bloat in the worker than necessary, but for ease use the same image

```
 docker service create --name spark-worker \
  --label 'com.sparklyr.service == spark-worker' \
  --network my-network \
  --constraint 'node.role != manager' \
  -e SPARK_CONF_DIR=/conf \
  -e SPARK_WORKER_CORES=7 \
  -e SPARK_WORKER_MEMORY=15g \
  -e SPARK_WORKER_INSTANCES=6 \
  -e SPARK_WORKER_PORT=8881 \
  -e SPARK_WORKER_WEBUI_PORT=8081 \
  -e SPARK_PUBLIC_DNS=localhost \
  --publish 8081:8081 \
  akhilnairamey/sparklyr \
  $RSTUDIO_SPARK_HOME/bin/spark-class org.apache.spark.deploy.worker.Worker spark://tasks.spark-master:7077

docker service scale spark-worker=1  # How many worker nodes are being run?
```
