# Hive

https://cwiki.apache.org/confluence/display/Hive
https://cwiki.apache.org/confluence/display/Hive/Streaming+Data+Ingest


## Setup

```xml
[1:hive-site.xml]*
-MiniBufExplorer-[-] unix  ascii=091 hex=5B [0001,0001](100% of 1)                                                                                                                                                                            
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

## Data

Download data from kaggle and then upload to hdfs:

```bash
[14560][uu][1][bash](08:43:11)[0](root) : /opt/share/kaggle/data
$hdfs dfs -put uber/  /uber
```
