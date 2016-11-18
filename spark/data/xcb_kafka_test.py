#import pyspark_cassandra
#import pyspark_cassandra.streaming

#from pyspark_cassandra import CassandraSparkContext
#import pyspark_cassandra

from pyspark.sql import SQLContext, SparkSession, Row
from pyspark import SparkContext, SparkConf
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils
# from uuid import uuid
import datetime as dt
import json

conf = SparkConf().setAppName("PySpark Cassandra Test").setMaster("spark://master:7077").set("spark.cassandra.connection.host", "cassandra")

# set up our contexts
sc = SparkContext(conf=conf)
sql = SQLContext(sc)
stream = StreamingContext(sc, 1) # 1 second window

#sc = CassandraSparkContext(conf=conf)
#sql = SQLContext(sc)
#stream = StreamingContext(sc, 1) # 1 second window
def getSparkSessionInstance(sparkConf):
    if ('sparkSessionSingletonInstance' not in globals()):
        globals()['sparkSessionSingletonInstance'] = SparkSession\
            .builder\
            .config(conf=sparkConf)\
            .getOrCreate()
    return globals()['sparkSessionSingletonInstance']

def update_and_return(d, new_key, new_value):
    d.update({new_key: new_value})
    return d

def process(time, rdd):
    print("========= %s =========" % str(time))
    if rdd.isEmpty():
        print('empty')
        return
    try:
        # Get the singleton instance of SparkSession
        #spark = getSparkSessionInstance(rdd.context.getConf())
        #test = sql.format("com.databricks.spark.avro").createDataFrame(rdd)
        #print(test.count())
        #test.show(1)
        #print(rdd.count())
        rdd_json = rdd.map(lambda y: json.loads(y))
        #rdd_json = sc.jsonRDD(rdd)
        #print('1')
        #print(rdd.take(10))
        rdd_json_ts = rdd_json.map(lambda z: update_and_return(z, 'insert_timestamp', str(dt.datetime.now())))
        print('2')
        #df = sql.createDataFrame(rdd_json)
        df = rdd_json_ts.toDF()
        #df.show()
        #print(rdd_json_ts.take(10))
        
        #print(rdd.count())
        #rowRdd = rdd.map(lambda line: json.loads(line).values)
        #rowRdd.collect().show()
        #print(rowRdd.coll      ect())
        # Convert RDD[String] to RDD[Row] to DataFrame
        #wordsDataFrame = rowRdd.toDF()
        #df = sql.createDataFrame(rowRdd)
        #print(df.count())
        #df.show()
        

        # Do word count on table using SQL and print it
        #spark.read.format("com.databricks.spark.avro").load(rdd)
        #wordsDataFrame.select("*").write.format("org.apache.spark.sql.cassandra").options(table="stream_test_2", keyspace="test").save(mode="append")
        df.select("*").write.format("org.apache.spark.sql.cassandra").options(table="stream_test", keyspace="test").save(mode="append")
        #wordsDataFrame.show()
    except:
        #print(str(e))
        print("except")
        raise

kafka_stream = KafkaUtils.createStream(stream, "kafka:2181", "raw-event-streaming-consumer", {"test":1})
#, valueDecoder=io.BytesIO
# (None, u'{"site_id": "02559c4f-ec20-4579-b2ca-72922a90d0df", "page": "/something.css"}')
#parsed = kafka_stream.map(lambda x: x[1]).map(lambda x: x.split('\n')[1]).map(lambda x: x + '\t'+ str(dt.datetime.now()))
parsed = kafka_stream.map(lambda x: x[1])
#print(parsed.count())
print('xcb')
#sql.read.format("org.apache.spark.sql.cassandra").options(table="stream_test", keyspace="test").load().show()
parsed.foreachRDD(process)
#kafka_stream.foreachRDD(process)

#parsed.saveToCassandra("test", "stream_test")

# aggregate page views by site
#summed = parsed.map(lambda event: (event['site_id'], 1)).\
#                reduceByKey(lambda x,y: x + y).\
#                map(lambda x: {"site_id": x[0], "ts": str(uuid1()), "pageviews": x[1]})

#summed.pprint()
#summed.saveToCassandra("killranalytics", "real_time_data")

stream.start()
stream.awaitTermination()