# HBase

## local mode

## cluster mode

Folder setup:
```
# in uu master
mkdir -p /opt/zk
mkdir -p /opt/hadoop/hbase/zk
mkdir -p /opt/hadoop/hbase/tmp
mkdir -p /opt/hadoop/hbase/local
mkdir -p /opt/hadoop/hbase/logs
# in region server
for i in `seq 3 6`; do
ansible u$i -a "mkdir -p /opt/zk"; # zookeeper
ansible u$i -a "mkdir -p /opt/hadoop/hbase/zk"; # hbase.zookeeper.property.dataDir
ansible u$i -a "mkdir -p /opt/hadoop/hbase/tmp"; # hbase.tmp.dir
ansible u$i -a "mkdir -p /opt/hadoop/hbase/local"; # hbase.local.dir
ansible u$i -a "mkdir -p /opt/hadoop/hbase/logs"; # hbase.log.dir
done
```

- Start Zookeeper

```
ansible u3 -a "zkServer.sh start"
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
