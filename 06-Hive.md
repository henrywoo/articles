# Hive

https://cwiki.apache.org/confluence/display/Hive
https://cwiki.apache.org/confluence/display/Hive/Streaming+Data+Ingest

## version

Hive - Version 3.1.1

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