# Spark

## Spark

Build from source since I could not find spark for hadoop 3.1.1


For normal build this is fine:
```
./build/mvn -DskipTests clean package
```

I use this one:
```
./build/mvn \
  -Psparkr -Phive\
  -Phive-thriftserver -Pmesos -Pyarn \
  -Pkubernetes \
  -Phadoop-3.1 -Dhadoop.version=3.1.1 \
  -DskipTests clean package
```
hive seems not supporting hadoop 3, so remove it from the build command:
```
./build/mvn \
  -Psparkr \
  -Pmesos -Pyarn \
  -Pkubernetes \
  -Phadoop-3.1 -Dhadoop.version=3.1.1 \
  -DskipTests clean package
```



![](img/build_spark.gif)


Run Spark with Yarn:  
![](img/spark_yarn.gif)

REF: https://spark.apache.org/docs/latest/building-spark.html


```
java.lang.IllegalArgumentException: Unrecognized Hadoop major version number: 3.1.1
  at org.apache.hadoop.hive.shims.ShimLoader.getMajorVersion(ShimLoader.java:174)
  at org.apache.hadoop.hive.shims.ShimLoader.loadShims(ShimLoader.java:139)
  at org.apache.hadoop.hive.shims.ShimLoader.getHadoopShims(ShimLoader.java:100)
  at org.apache.hadoop.hive.conf.HiveConf$ConfVars.<clinit>(HiveConf.java:368)
  at org.apache.hadoop.hive.conf.HiveConf.<clinit>(HiveConf.java:105)
  at java.lang.Class.forName0(Native Method)
  at java.lang.Class.forName(Class.java:348)
  at org.apache.spark.util.Utils$.classForName(Utils.scala:195)
  at org.apache.spark.sql.SparkSession$.hiveClassesArePresent(SparkSession.scala:1116)
  at org.apache.spark.repl.Main$.createSparkSession(Main.scala:102)
  ... 57 elided
<console>:14: error: not found: value spark
       import spark.implicits._
              ^
<console>:14: error: not found: value spark
       import spark.sql
              ^
```

- Run spark

```
✔ /opt/share/git.repo/spark.git [henrywu {origin/henrywu}|✔] 
20:07 # SPARK_LOCAL_IP=192.168.122.1 ./bin/spark-shell --master yarn --deploy-mode client
...
Failed to find Spark jars directory (/home/henry/share/git.repo/spark.git/assembly/target/scala-2.11/jars).
You need to build Spark with the target "package" before running this program.
```
After running build:  
```
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary for Spark Project Parent POM 3.0.0-SNAPSHOT:
[INFO] 
[INFO] Spark Project Parent POM ........................... SUCCESS [  5.922 s]
[INFO] Spark Project Tags ................................. SUCCESS [ 10.150 s]
[INFO] Spark Project Sketch ............................... SUCCESS [  9.611 s]
[INFO] Spark Project Local DB ............................. SUCCESS [  5.227 s]
[INFO] Spark Project Networking ........................... SUCCESS [ 10.297 s]
[INFO] Spark Project Shuffle Streaming Service ............ SUCCESS [ 11.854 s]
[INFO] Spark Project Unsafe ............................... SUCCESS [ 11.983 s]
[INFO] Spark Project Launcher ............................. SUCCESS [ 10.106 s]
[INFO] Spark Project Core ................................. SUCCESS [03:37 min]
[INFO] Spark Project ML Local Library ..................... SUCCESS [  7.181 s]
[INFO] Spark Project GraphX ............................... SUCCESS [ 12.523 s]
[INFO] Spark Project Streaming ............................ SUCCESS [ 31.369 s]
[INFO] Spark Project Catalyst ............................. SUCCESS [01:46 min]
[INFO] Spark Project SQL .................................. SUCCESS [03:21 min]
[INFO] Spark Project ML Library ........................... SUCCESS [01:47 min]
[INFO] Spark Project Tools ................................ SUCCESS [  0.577 s]
[INFO] Spark Project Hive ................................. SUCCESS [ 43.242 s]
[INFO] Spark Project REPL ................................. SUCCESS [  4.809 s]
[INFO] Spark Project YARN Shuffle Service ................. SUCCESS [ 10.514 s]
[INFO] Spark Project YARN ................................. SUCCESS [ 10.361 s]
[INFO] Spark Project Mesos ................................ SUCCESS [  6.854 s]
[INFO] Spark Project Kubernetes ........................... SUCCESS [  8.368 s]
[INFO] Spark Project Assembly ............................. SUCCESS [  3.979 s]
[INFO] Spark Integration for Kafka 0.10 ................... SUCCESS [  7.962 s]
[INFO] Kafka 0.10+ Source for Structured Streaming ........ SUCCESS [ 11.423 s]
[INFO] Spark Project Examples ............................. SUCCESS [ 16.907 s]
[INFO] Spark Integration for Kafka 0.10 Assembly .......... SUCCESS [ 10.350 s]
[INFO] Spark Avro ......................................... SUCCESS [  4.265 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  14:59 min
[INFO] Finished at: 2019-01-15T16:48:36-08:00
[INFO] ------------------------------------------------------------------------
```

### Troubleshooting

```
2019-01-15 22:49:05,733 INFO org.apache.hadoop.yarn.server.resourcemanager.RMAppManager$ApplicationSummary: appId=application_1547609798272_0001,name=Spark shell,user=root,queue=default,state=FINISHED,trackingUrl=http://u3:8088/proxy/application_1547609798272_0001/,appMasterHost=192.168.122.105,submitTime=1547610447422,startTime=1547610448573,finishTime=1547610545418,finalStatus=UNDEFINED,memorySeconds=96574,vcoreSeconds=94,preemptedMemorySeconds=0,preemptedVcoreSeconds=0,preemptedAMContainers=0,preemptedNonAMContainers=0,preemptedResources=<memory:0\, vCores:0>,applicationType=SPARK,resourceSeconds=96574 MB-seconds\, 94 vcore-seconds,preemptedResourceSeconds=0 MB-seconds\, 0 vcore-seconds
```

Found this in data node log:

```
2019-01-15 23:10:35,348 WARN org.apache.hadoop.yarn.server.nodemanager.containermanager.monitor.ContainersMonitorImpl: Container [pid=2313,containerID=container_1547609798272_0002_01_000001] is running 15301120B beyond the 'VIRTUAL' memory limit. Current usage: 151.0 MB of 1 GB physical memory used; 2.1 GB of 2.1 GB virtual memory used. Killing container.
Dump of the process-tree for container_1547609798272_0002_01_000001 :
>.|- PID PPID PGRPID SESSID CMD_NAME USER_MODE_TIME(MILLIS) SYSTEM_TIME(MILLIS) VMEM_USAGE(BYTES) RSSMEM_USAGE(PAGES) FULL_CMD_LINE
>.|- 2313 2311 2313 2313 (bash) 0 1 21856256 874 /bin/bash -c /opt/share/software/jdk1.8.0_191/bin/java -server -Xmx512m -Djava.io.tmpdir=/opt/hadoop/tmp/nm-local-dir/usercache/root/appcache/application_1547609798272_0002/container_1547609798272_0002_01_000001/tmp -Dspark.yarn.app.container.log.dir=/opt/hadoop/log/userlogs/application_1547609798272_0002/container_1547609798272_0002_01_000001 org.apache.spark.deploy.yarn.ExecutorLauncher --arg '192.168.122.1:33869' --properties-file /opt/hadoop/tmp/nm-local-dir/usercache/root/appcache/application_1547609798272_0002/container_1547609798272_0002_01_000001/__spark_conf__/__spark_conf__.properties --dist-cache-conf /opt/hadoop/tmp/nm-local-dir/usercache/root/appcache/application_1547609798272_0002/container_1547609798272_0002_01_000001/__spark_conf__/__spark_dist_cache__.properties 1> /opt/hadoop/log/userlogs/application_1547609798272_0002/container_1547609798272_0002_01_000001/stdout 2> /opt/hadoop/log/userlogs/application_1547609798272_0002/container_1547609798272_0002_01_000001/stderr.
>.|- 2322 2313 2313 2313 (java) 652 405 2248302592 37786 /opt/share/software/jdk1.8.0_191/bin/java -server -Xmx512m -Djava.io.tmpdir=/opt/hadoop/tmp/nm-local-dir/usercache/root/appcache/application_1547609798272_0002/container_1547609798272_0002_01_000001/tmp -Dspark.yarn.app.container.log.dir=/opt/hadoop/log/userlogs/application_1547609798272_0002/container_1547609798272_0002_01_000001 org.apache.spark.deploy.yarn.ExecutorLauncher --arg 192.168.122.1:33869 --properties-file /opt/hadoop/tmp/nm-local-dir/usercache/root/appcache/application_1547609798272_0002/container_1547609798272_0002_01_000001/__spark_conf__/__spark_conf__.properties --dist-cache-conf /opt/hadoop/tmp/nm-local-dir/usercache/root/appcache/application_1547609798272_0002/container_1547609798272_0002_01_000001/__spark_conf__/__spark_dist_cache__.properties.
```

REF:  
https://stackoverflow.com/questions/51237116/understanding-spark-yarn-executor-memoryoverhead  
https://stackoverflow.com/questions/49988475/why-increase-spark-yarn-executor-memoryoverhead  
https://spark.apache.org/docs/latest/configuration.html  


SPARK_LOCAL_IP=192.168.122.1 ./bin/spark-shell --master yarn --deploy-mode client --driver-memory 1G --executor-memory 1G --conf spark.executor.memoryOverhead=348


https://mapr.com/blog/best-practices-yarn-resource-management/  
https://blog.csdn.net/dai451954706/article/details/48828751  
```
    <property>
        <name>yarn.nodemanager.vmem-check-enabled</name>
        <value>false</value>
    </property>   
```

![](img/run_spark.gif)

- upload file failed from webui

found this in namenode log:
```
2019-01-15 23:21:35,253 INFO org.apache.hadoop.ipc.Server: IPC Server handler 2 on 9000, call Call#936 Retry#0 org.apache.hadoop.hdfs.protocol.ClientProtocol.create from 192.168.122.106:56178: org.apache.hadoop.security.AccessControlException: Permission denied: user=dr.who, access=WRITE, inode="/test":root:supergroup:drwxr-xr-x
```


https://blog.cloudera.com/blog/2017/12/hadoop-delegation-tokens-explained/

```
05:34 # SPARK_LOCAL_IP=192.168.122.1 ./bin/spark-shell --master yarn --deploy-mode client
2019-01-16 05:34:47 WARN  NativeCodeLoader:60 - Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
2019-01-16 05:35:01 WARN  Client:70 - Neither spark.yarn.jars nor spark.yarn.archive is set, falling back to uploading libraries under SPARK_HOME.
2019-01-16 05:35:08 WARN  HBaseDelegationTokenProvider:91 - Fail to invoke HBaseConfiguration
java.lang.ClassNotFoundException: org.apache.hadoop.hbase.HBaseConfiguration
	at scala.reflect.internal.util.AbstractFileClassLoader.findClass(AbstractFileClassLoader.scala:72)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:424)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:357)
	at org.apache.spark.deploy.security.HBaseDelegationTokenProvider.hbaseConf(HBaseDelegationTokenProvider.scala:69)
	at org.apache.spark.deploy.security.HBaseDelegationTokenProvider.delegationTokensRequired(HBaseDelegationTokenProvider.scala:62)
	at org.apache.spark.deploy.security.HadoopDelegationTokenManager.$anonfun$obtainDelegationTokens$1(HadoopDelegationTokenManager.scala:134)
	at scala.collection.TraversableLike.$anonfun$flatMap$1(TraversableLike.scala:244)
	at scala.collection.Iterator.foreach(Iterator.scala:941)
	at scala.collection.Iterator.foreach$(Iterator.scala:941)
	at scala.collection.AbstractIterator.foreach(Iterator.scala:1429)
	at scala.collection.MapLike$DefaultValuesIterable.foreach(MapLike.scala:213)
	at scala.collection.TraversableLike.flatMap(TraversableLike.scala:244)
	at scala.collection.TraversableLike.flatMap$(TraversableLike.scala:241)
	at scala.collection.AbstractTraversable.flatMap(Traversable.scala:108)
	at org.apache.spark.deploy.security.HadoopDelegationTokenManager.obtainDelegationTokens(HadoopDelegationTokenManager.scala:133)
	at org.apache.spark.deploy.yarn.security.YARNHadoopDelegationTokenManager.obtainDelegationTokens(YARNHadoopDelegationTokenManager.scala:59)
	at org.apache.spark.deploy.yarn.Client.setupSecurityToken(Client.scala:305)
	at org.apache.spark.deploy.yarn.Client.createContainerLaunchContext(Client.scala:1014)
	at org.apache.spark.deploy.yarn.Client.submitApplication(Client.scala:181)
	at org.apache.spark.scheduler.cluster.YarnClientSchedulerBackend.start(YarnClientSchedulerBackend.scala:58)
	at org.apache.spark.scheduler.TaskSchedulerImpl.start(TaskSchedulerImpl.scala:184)
	at org.apache.spark.SparkContext.<init>(SparkContext.scala:509)
	at org.apache.spark.SparkContext$.getOrCreate(SparkContext.scala:2466)
	at org.apache.spark.sql.SparkSession$Builder.$anonfun$getOrCreate$5(SparkSession.scala:948)
	at scala.Option.getOrElse(Option.scala:138)
	at org.apache.spark.sql.SparkSession$Builder.getOrCreate(SparkSession.scala:939)
	at org.apache.spark.repl.Main$.createSparkSession(Main.scala:112)
	at $line3.$read$$iw$$iw.<init>(<console>:15)
	at $line3.$read$$iw.<init>(<console>:42)
	at $line3.$read.<init>(<console>:44)
	at $line3.$read$.<init>(<console>:48)
	at $line3.$read$.<clinit>(<console>)
	at $line3.$eval$.$print$lzycompute(<console>:7)
	at $line3.$eval$.$print(<console>:6)
	at $line3.$eval.$print(<console>)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:498)
	at scala.tools.nsc.interpreter.IMain$ReadEvalPrint.call(IMain.scala:742)
	at scala.tools.nsc.interpreter.IMain$Request.loadAndRun(IMain.scala:1018)
	at scala.tools.nsc.interpreter.IMain.$anonfun$interpret$1(IMain.scala:574)
	at scala.reflect.internal.util.ScalaClassLoader.asContext(ScalaClassLoader.scala:41)
	at scala.reflect.internal.util.ScalaClassLoader.asContext$(ScalaClassLoader.scala:37)
	at scala.reflect.internal.util.AbstractFileClassLoader.asContext(AbstractFileClassLoader.scala:41)
	at scala.tools.nsc.interpreter.IMain.loadAndRunReq$1(IMain.scala:573)
	at scala.tools.nsc.interpreter.IMain.interpret(IMain.scala:600)
	at scala.tools.nsc.interpreter.IMain.interpret(IMain.scala:570)
	at scala.tools.nsc.interpreter.IMain.$anonfun$quietRun$1(IMain.scala:224)
	at scala.tools.nsc.interpreter.IMain.beQuietDuring(IMain.scala:214)
	at scala.tools.nsc.interpreter.IMain.quietRun(IMain.scala:224)
	at org.apache.spark.repl.SparkILoop.$anonfun$initializeSpark$2(SparkILoop.scala:109)
	at scala.collection.immutable.List.foreach(List.scala:392)
	at org.apache.spark.repl.SparkILoop.$anonfun$initializeSpark$1(SparkILoop.scala:109)
	at scala.runtime.java8.JFunction0$mcV$sp.apply(JFunction0$mcV$sp.java:23)
	at scala.tools.nsc.interpreter.ILoop.savingReplayStack(ILoop.scala:100)
	at org.apache.spark.repl.SparkILoop.initializeSpark(SparkILoop.scala:109)
	at org.apache.spark.repl.SparkILoop.$anonfun$process$5(SparkILoop.scala:211)
	at scala.runtime.java8.JFunction0$mcV$sp.apply(JFunction0$mcV$sp.java:23)
	at scala.tools.nsc.interpreter.ILoop.$anonfun$mumly$1(ILoop.scala:169)
	at scala.tools.nsc.interpreter.IMain.beQuietDuring(IMain.scala:214)
	at scala.tools.nsc.interpreter.ILoop.mumly(ILoop.scala:166)
	at org.apache.spark.repl.SparkILoop.loopPostInit$1(SparkILoop.scala:199)
	at org.apache.spark.repl.SparkILoop.$anonfun$process$11(SparkILoop.scala:267)
	at org.apache.spark.repl.SparkILoop.withSuppressedSettings$1(SparkILoop.scala:235)
	at org.apache.spark.repl.SparkILoop.startup$1(SparkILoop.scala:247)
	at org.apache.spark.repl.SparkILoop.$anonfun$process$1(SparkILoop.scala:282)
	at org.apache.spark.repl.SparkILoop.runClosure(SparkILoop.scala:164)
	at org.apache.spark.repl.SparkILoop.process(SparkILoop.scala:182)
	at org.apache.spark.repl.Main$.doMain(Main.scala:78)
	at org.apache.spark.repl.Main$.main(Main.scala:58)
	at org.apache.spark.repl.Main.main(Main.scala)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:498)
	at org.apache.spark.deploy.JavaMainApplication.start(SparkApplication.scala:52)
	at org.apache.spark.deploy.SparkSubmit.org$apache$spark$deploy$SparkSubmit$$runMain(SparkSubmit.scala:854)
	at org.apache.spark.deploy.SparkSubmit.doRunMain$1(SparkSubmit.scala:168)
	at org.apache.spark.deploy.SparkSubmit.submit(SparkSubmit.scala:196)
	at org.apache.spark.deploy.SparkSubmit.doSubmit(SparkSubmit.scala:87)
	at org.apache.spark.deploy.SparkSubmit$$anon$2.doSubmit(SparkSubmit.scala:933)
	at org.apache.spark.deploy.SparkSubmit$.main(SparkSubmit.scala:942)
	at org.apache.spark.deploy.SparkSubmit.main(SparkSubmit.scala)
Spark context Web UI available at http://192.168.122.1:4040
Spark context available as 'sc' (master = yarn, app id = application_1547644510496_0002).
Spark session available as 'spark'.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 3.0.0-SNAPSHOT
      /_/
         
Using Scala version 2.12.8 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_191)
Type in expressions to have them evaluated.
Type :help for more information.

scala> :q
```




`SPARK_LOCAL_IP=192.168.122.1 spark-submit --master yarn --deploy-mode client src/python/WordCount.py`

```
07:24 # cat src/python/WordCount.py 
import sys
from pyspark import SparkContext
if __name__ == "__main__":
    #master = "local"
    master = "yarn"
    print(sys.argv)
    if len(sys.argv) == 2:
        master = sys.argv[1]
    sc = SparkContext(master, "WordCount")
    lines = sc.parallelize(["pandas", "i like pandas"])
    result = lines.flatMap(lambda x: x.split(" ")).countByValue()
    for key, value in result.iteritems():
        print "%s %i" % (key, value)
```



```
[14238][uu][5][bash](14:54:13)[0](root) : ~/articles
$export PYSPARK_DRIVER_PYTHON='ipython'
[14239][uu][5][bash](14:54:37)[0](root) : ~/articles
$SPARK_LOCAL_IP=192.168.122.1 pyspark --master yarn --deploy-mode client
Python 2.7.15rc1 (default, Nov 12 2018, 14:31:15) 
Type "copyright", "credits" or "license" for more information.

IPython 5.5.0 -- An enhanced Interactive Python.
?         -> Introduction and overview of IPython's features.
%quickref -> Quick reference.
help      -> Python's own help system.
object?   -> Details about 'object', use 'object??' for extra details.
2019-02-07 14:54:43 WARN  NativeCodeLoader:60 - Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
2019-02-07 14:54:47 WARN  Client:70 - Neither spark.yarn.jars nor spark.yarn.archive is set, falling back to uploading libraries under SPARK_HOME.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /__ / .__/\_,_/_/ /_/\_\   version 3.0.0-SNAPSHOT
      /_/

Using Python version 2.7.15rc1 (default, Nov 12 2018 14:31:15)
SparkSession available as 'spark'.

In [1]: 
```
