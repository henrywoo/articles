# HBase

https://issues.apache.org/jira/projects/HBASE/issues/HBASE-21843?filter=allopenissues

## local mode

## cluster mode

Folder setup:
```
ansible-playbook hbase.yml
```

- Start hbase

```
start-hbase.sh
```

- Stop hbase

```
stop-hbase.sh
```


![](img/henrywu_016.png)



- troubleshoot

Fix `ClassNotFoundException: org.apache.htrace.SamplerBuilder`:
```
cd /opt/share/software/HadoopEcosystem/hbase/lib
cp client-facing-thirdparty/htrace-core-3.1.0-incubating.jar .
```

```
✘-1 /home/henry/share/software/HadoopEcosystem/hbase-2.1.2/lib/client-facing-thirdparty [master {origin/master}|✚ 1] 
22:17 # mv htrace-core4-4.2.0-incubating.jar htrace-core4-4.2.0-incubating.jar.bk
```


Ref:

http://www.techguru.my/database/hbase/install-hbase-2-x-with-hadoop-3-x/  


- Could not initialize class org.apache.hadoop.hbase.io.asyncfs.FanOutOneBlockAsyncDFSOutputHelper

```
2019-02-05 22:44:37,397 INFO  [RpcServer.priority.FPBQ.Fifo.handler=18,queue=0,port=16020] regionserver.RSRpcServices: Open hbase:meta,,1.1588230740
2019-02-05 22:44:37,411 INFO  [RS_OPEN_META-regionserver/u6:16020-0] wal.AbstractFSWAL: WAL configuration: blocksize=256 MB, rollsize=128 MB, prefix=u6%2C16020%2C1549422852676.meta, suffix=.meta, logDir=hdfs://u3:9000/henryhbase/WALs/u6,16020,1549422852676, archiveDir=hdfs://u3:9000/henryhbase/oldWALs
2019-02-05 22:44:37,416 ERROR [RS_OPEN_META-regionserver/u6:16020-0] handler.OpenRegionHandler: Failed open of region=hbase:meta,,1.1588230740
java.lang.NoClassDefFoundError: Could not initialize class org.apache.hadoop.hbase.io.asyncfs.FanOutOneBlockAsyncDFSOutputHelper
>.at org.apache.hadoop.hbase.io.asyncfs.AsyncFSOutputHelper.createOutput(AsyncFSOutputHelper.java:51)
>.at org.apache.hadoop.hbase.regionserver.wal.AsyncProtobufLogWriter.initOutput(AsyncProtobufLogWriter.java:167)
>.at org.apache.hadoop.hbase.regionserver.wal.AbstractProtobufLogWriter.init(AbstractProtobufLogWriter.java:166)
>.at org.apache.hadoop.hbase.wal.AsyncFSWALProvider.createAsyncWriter(AsyncFSWALProvider.java:113)
>.at org.apache.hadoop.hbase.regionserver.wal.AsyncFSWAL.createWriterInstance(AsyncFSWAL.java:612)
>.at org.apache.hadoop.hbase.regionserver.wal.AsyncFSWAL.createWriterInstance(AsyncFSWAL.java:124)
>.at org.apache.hadoop.hbase.regionserver.wal.AbstractFSWAL.rollWriter(AbstractFSWAL.java:756)
>.at org.apache.hadoop.hbase.regionserver.wal.AbstractFSWAL.rollWriter(AbstractFSWAL.java:486)
>.at org.apache.hadoop.hbase.regionserver.wal.AsyncFSWAL.<init>(AsyncFSWAL.java:251)
>.at org.apache.hadoop.hbase.wal.AsyncFSWALProvider.createWAL(AsyncFSWALProvider.java:73)
>.at org.apache.hadoop.hbase.wal.AsyncFSWALProvider.createWAL(AsyncFSWALProvider.java:48)
>.at org.apache.hadoop.hbase.wal.AbstractFSWALProvider.getWAL(AbstractFSWALProvider.java:152)
>.at org.apache.hadoop.hbase.wal.AbstractFSWALProvider.getWAL(AbstractFSWALProvider.java:60)
>.at org.apache.hadoop.hbase.wal.WALFactory.getWAL(WALFactory.java:284)
>.at org.apache.hadoop.hbase.regionserver.HRegionServer.getWAL(HRegionServer.java:2104)
>.at org.apache.hadoop.hbase.regionserver.handler.OpenRegionHandler.openRegion(OpenRegionHandler.java:284)
>.at org.apache.hadoop.hbase.regionserver.handler.OpenRegionHandler.process(OpenRegionHandler.java:108)
>.at org.apache.hadoop.hbase.executor.EventHandler.run(EventHandler.java:104)
>.at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
>.at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
>.at java.lang.Thread.run(Thread.java:748)
```

