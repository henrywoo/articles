# Hive

https://cwiki.apache.org/confluence/display/Hive
https://cwiki.apache.org/confluence/display/Hive/Streaming+Data+Ingest

## version

Hive - Version 3.1.1

## developer guide

https://cwiki.apache.org/confluence/display/Hive/DeveloperGuide

`mvn package -DskipTests -Pdist`

## Setup

```xml
[1:hive-site.xml]*
  1 <?xml version="1.0"?>
  2 <configuration>
  3   <property>
  4     <name>hive.execution.engine</name>
  5     <value>spark</value>
  6     <description>
  7       Expects one of [mr, tez, spark].
  8       Chooses execution engine. Options are: mr (Map reduce, default), tez, spark. While MR
  9       remains the default engine for historical reasons, it is itself a historical engine
 10       and is deprecated in Hive 2 line. It may be removed without further warning.
 11     </description>
 12   </property>
 13 </configuration> 
```

```
hadoop fs -mkdir /tmp/hive
hadoop fs -mkdir /user/hive/repl
hadoop fs -mkdir /user/hive/cmroot
hadoop fs -mkdir /user/hive/repl/functions
hadoop fs -mkdir /user/hive/warehouse
hadoop fs -mkdir /hivedelegation
hadoop fs -mkdir /tmp/hive/_resultscache_
```

## Data

Download data from kaggle and then upload to hdfs:

```bash
[14560][uu][1][bash](08:43:11)[0](root) : /opt/share/kaggle/data
$hdfs dfs -put uber/  /uber
```

hdfs://u3:9000/uber/Uber-Jan-Feb-FOIL.csv

```csv
dispatching_base_number,date,active_vehicles,trips
B02512,1/1/2015,190,1132
B02765,1/1/2015,225,1765
B02764,1/1/2015,3427,29421
B02682,1/1/2015,945,7679
B02617,1/1/2015,1228,9537
...
```

```
$hdfs dfs -cat /uber/Uber-Jan-Feb-FOIL.csv | head
dispatching_base_number,date,active_vehicles,trips
B02512,1/1/2015,190,1132
B02765,1/1/2015,225,1765
B02764,1/1/2015,3427,29421
B02682,1/1/2015,945,7679
B02617,1/1/2015,1228,9537
B02598,1/1/2015,870,6903
B02598,1/2/2015,785,4768
B02617,1/2/2015,1137,7065
B02512,1/2/2015,175,875
```

The data is available here too: https://github.com/fivethirtyeight/uber-tlc-foil-response/blob/master/Uber-Jan-Feb-FOIL.csv

HSQL:

```sql
create external table IF NOT EXISTS Uber_Jan_Feb_FOIL (dispatching_base_number string,
  trip_date string,
  active_vehicles int,
  trips int)
  COMMENT 'Uber Jan Feb FOIL Data'
  ROW FORMAT DELIMITED
  FIELDS TERMINATED BY ','
  lines terminated by '\n'
  STORED AS TEXTFILE
  LOCATION '/uber/'
  tblproperties ("skip.header.line.count"="1");
load data LOCAL inpath '/opt/share/kaggle/data/uber/Uber-Jan-Feb-FOIL.csv' into table Uber_Jan_Feb_FOIL;
```

ref:
https://stackoverflow.com/questions/44016835/how-do-we-define-date-format-in-hive-create-statment  
https://stackoverflow.com/questions/47301455/how-to-convert-date-2017-sep-12-to-2017-09-12-in-hive/47301792#47301792  
https://stackoverflow.com/questions/49380873/how-to-create-hive-table-with-date-format-dd-mmm-yyyy  

It seems spark engine doesn't work well:

```
hive> select count(*) from Uber_Jan_Feb_FOIL;
2019-02-08 12:38:11,628 INFO  [6c332f80-068d-4bc3-9458-84d06462f1c6 main] reducesink.VectorReduceSinkEmptyKeyOperator (VectorReduceSinkEmptyKeyOperator.java:<init>(64)) - VectorReduceSinkEmptyKeyOperator constructor vectorReduceSinkInfo org.apache.hadoop.hive.ql.plan.VectorReduceSinkInfo@63218586
Query ID = root_20190208123810_d44a8599-ce3b-4d62-9cdb-c6dc84c3d524
Total jobs = 1
Launching Job 1 out of 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
Failed to execute spark task, with exception 'org.apache.hadoop.hive.ql.metadata.HiveException(Failed to create Spark client for Spark session 0f5cd43e-9a8c-4e6f-9be9-fa4522b00296)'
FAILED: Execution Error, return code 30041 from org.apache.hadoop.hive.ql.exec.spark.SparkTask. Failed to create Spark client for Spark session 0f5cd43e-9a8c-4e6f-9be9-fa4522b00296
hive> 
```

Launch hive in debug mode:
```
$hive -hiveconf hive.root.logger=DEBUG,console
```
I found the issue is `java.lang.ClassNotFoundException: org.apache.spark.SparkConf`.


## debug


```xml
$hive --help
Usage ./hive <parameters> --service serviceName <service parameters>
Service List: beeline cleardanglingscratchdir cli fixacidkeyindex help hiveburninclient hiveserver2 hplsql jar lineage llapdump llap llapstatus metastore metatool orcfiledump rcfilecat schemaTool strictmanagedmigration tokentool version 
Parameters parsed:
  --auxpath : Auxiliary jars 
  --config : Hive configuration directory
  --service : Starts specific service/component. cli is default
Parameters used:
  HADOOP_HOME or HADOOP_PREFIX : Hadoop install directory
  HIVE_OPT : Hive options
For help on a particular service:
  ./hive --service serviceName --help
Debug help:  ./hive --debug --help
```


## Integration with HBase

https://cwiki.apache.org/confluence/display/Hive/HBaseIntegration


## Deepdive

When you run `hive`, actually the following command is running:

```
exec /opt/share/software/jdk1.8.0_191/bin/java 
  -Dproc_jar -Djava.net.preferIPv4Stack=true 
  -Djava.library.path=/home/henry/share/software/HadoopEcosystem/hadoop/lib/native
  -Dproc_hivecli 
  -Dlog4j.configurationFile=hive-log4j2.properties 
  -Djava.util.logging.config.file=/opt/share/software/HadoopEcosystem/hive/conf/parquet-logging.properties 
  -Dyarn.log.dir=/opt/hadoop/log -Dyarn.log.file=hadoop.log 
  -Dyarn.home.dir=/opt/share/software/HadoopEcosystem/hadoop -Dyarn.root.logger=INFO,console -Xmx256m 
  -Dhadoop.log.dir=/opt/hadoop/log -Dhadoop.log.file=hadoop.log 
  -Dhadoop.home.dir=/opt/share/software/HadoopEcosystem/hadoop 
  -Dhadoop.id.str=root 
  -Dhadoop.root.logger=INFO,console 
  -Dhadoop.policy.file=hadoop-policy.xml 
  -Dhadoop.security.logger=INFO,NullAppender
  org.apache.hadoop.util.RunJar
  /opt/share/software/HadoopEcosystem/hive/lib/hive-cli-3.1.1.jar
  org.apache.hadoop.hive.cli.CliDriver
```