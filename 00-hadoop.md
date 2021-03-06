# Hadoop


## Hadoop

```
13:09 # ll /opt/share/software/HadoopEcosystem/hadoop/
total 212
drwxr-xr-x 10 libvirt-qemu henry   4096 Jan  9 16:14 ./
drwxrwxr-x 14 libvirt-qemu henry   4096 Jan 15 04:28 ../
drwxr-xr-x  2 libvirt-qemu henry   4096 Aug  1 22:05 bin/
drwxr-xr-x  3 libvirt-qemu henry   4096 Aug  1 21:28 etc/
drwxr-xr-x  2 libvirt-qemu henry   4096 Aug  1 22:05 include/
drwxr-xr-x  3 libvirt-qemu henry   4096 Aug  1 22:05 lib/
drwxr-xr-x  4 libvirt-qemu henry   4096 Aug  1 22:05 libexec/
-rw-r--r--  1 libvirt-qemu henry 147144 Jul 28 16:13 LICENSE.txt
drwxrwxr-x  3 libvirt-qemu henry   4096 Jan  9 16:38 logs/
-rw-r--r--  1 libvirt-qemu henry  21867 Jul 28 16:13 NOTICE.txt
-rw-r--r--  1 libvirt-qemu henry   1366 Jul 28 13:41 README.txt
drwxr-xr-x  3 libvirt-qemu henry   4096 Aug  1 21:28 sbin/
drwxr-xr-x  4 libvirt-qemu henry   4096 Aug  1 22:17 share/
```

name node: u3  
data node: u4,u5,u6

### prepare for hadoop folders

```
for i in `seq 3 6`; do
ansible u$i -a "rm -fr /opt/hadoop";
done

for i in `seq 3 6`; do
ansible u$i -a "mkdir -p /opt/hadoop/data";
ansible u$i -a "mkdir -p /opt/hadoop/log";
ansible u$i -a "mkdir -p /opt/hadoop/tmp";
ansible u$i -a "mkdir -p /opt/hadoop/mr-history/tmp";
ansible u$i -a "mkdir -p /opt/hadoop/mr-history/done";
done

ansible u3 -a "mkdir -p /opt/hadoop/name";
```

### init namenode

```
ssh u3
$hdfs namenode -format
```

### start or stop hadoop cluster
Start:   

```bash
for i in `seq 3 6`; do virsh start u$i; done
sleep 60 # wait for 60 secs for servers to boot up
ansible u3 -a "start-all.sh";
ansible u3 -a "mapred --daemon start historyserver";
```

Stop:  
```bash
ansible u3 -a "mapred --daemon stop historyserver";
ansible u3 -a "stop-all.sh";
for i in `seq 3 6`; do virsh shutdown u$i; done
```

[http://u3:8088/cluster](http://u3:8088/cluster)  
![](img/hadoop.gif)

[http://u3:9870/](http://u3:9870/)  
![](img/Selection_004.png)


### Hadoop streaming

```bash
$find /opt/share/software/HadoopEcosystem/hadoop/ -name hadoop-streaming*.jar
/opt/share/software/HadoopEcosystem/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.2.0.jar
/opt/share/software/HadoopEcosystem/hadoop/share/hadoop/tools/sources/hadoop-streaming-3.2.0-sources.jar
/opt/share/software/HadoopEcosystem/hadoop/share/hadoop/tools/sources/hadoop-streaming-3.2.0-test-sources.jar
```

```bash
hdfs dfs -rm -r wc-mr
export HADOOP_STREAMING_JAR=/opt/share/software/HadoopEcosystem/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.2.0.jar
yarn jar $HADOOP_STREAMING_JAR -mapper 'wc -l' -numReduceTasks 0 -input /henry -output wc-mr
```

Details:

```bash
$yarn jar $HADOOP_STREAMING_JAR -info
Usage: $HADOOP_HOME/bin/hadoop jar hadoop-streaming.jar [options]
Options:
  -input          <path> DFS input file(s) for the Map step.
  -output         <path> DFS output directory for the Reduce step.
  -mapper         <cmd|JavaClassName> Optional. Command to be run as mapper.
  -combiner       <cmd|JavaClassName> Optional. Command to be run as combiner.
  -reducer        <cmd|JavaClassName> Optional. Command to be run as reducer.
  -file           <file> Optional. File/dir to be shipped in the Job jar file.
                  Deprecated. Use generic option "-files" instead.
  -inputformat    <TextInputFormat(default)|SequenceFileAsTextInputFormat|JavaClassName>
                  Optional. The input format class.
  -outputformat   <TextOutputFormat(default)|JavaClassName>
                  Optional. The output format class.
  -partitioner    <JavaClassName>  Optional. The partitioner class.
  -numReduceTasks <num> Optional. Number of reduce tasks.
  -inputreader    <spec> Optional. Input recordreader spec.
  -cmdenv         <n>=<v> Optional. Pass env.var to streaming commands.
  -mapdebug       <cmd> Optional. To run this script when a map task fails.
  -reducedebug    <cmd> Optional. To run this script when a reduce task fails.
  -io             <identifier> Optional. Format to use for input to and output
                  from mapper/reducer commands
  -lazyOutput     Optional. Lazily create Output.
  -background     Optional. Submit the job and don't wait till it completes.
  -verbose        Optional. Print verbose output.
  -info           Optional. Print detailed usage.
  -help           Optional. Print help message.

Generic options supported are:
-conf <configuration file>        specify an application configuration file
-D <property=value>               define a value for a given property
-fs <file:///|hdfs://namenode:port> specify default filesystem URL to use, overrides 'fs.defaultFS' property from configurations.
-jt <local|resourcemanager:port>  specify a ResourceManager
-files <file1,...>                specify a comma-separated list of files to be copied to the map reduce cluster
-libjars <jar1,...>               specify a comma-separated list of jar files to be included in the classpath
-archives <archive1,...>          specify a comma-separated list of archives to be unarchived on the compute machines

The general command line syntax is:
command [genericOptions] [commandOptions]


Usage tips:
In -input: globbing on <path> is supported and can have multiple -input

Default Map input format: a line is a record in UTF-8 the key part ends at first
  TAB, the rest of the line is the value

To pass a Custom input format:
  -inputformat package.MyInputFormat

Similarly, to pass a custom output format:
  -outputformat package.MyOutputFormat

The files with extensions .class and .jar/.zip, specified for the -file
  argument[s], end up in "classes" and "lib" directories respectively inside
  the working directory when the mapper and reducer are run. All other files
  specified for the -file argument[s] end up in the working directory when the
  mapper and reducer are run. The location of this working directory is
  unspecified.

To set the number of reduce tasks (num. of output files) as, say 10:
  Use -numReduceTasks 10
To skip the sort/combine/shuffle/sort/reduce step:
  Use -numReduceTasks 0
  Map output then becomes a 'side-effect output' rather than a reduce input.
  This speeds up processing. This also feels more like "in-place" processing
  because the input filename and the map input order are preserved.
  This is equivalent to -reducer NONE

To speed up the last maps:
  -D mapreduce.map.speculative=true
To speed up the last reduces:
  -D mapreduce.reduce.speculative=true
To name the job (appears in the JobTracker Web UI):
  -D mapreduce.job.name='My Job'
To change the local temp directory:
  -D dfs.data.dir=/tmp/dfs
  -D stream.tmpdir=/tmp/streaming
Additional local temp directories with -jt local:
  -D mapreduce.cluster.local.dir=/tmp/local
  -D mapreduce.jobtracker.system.dir=/tmp/system
  -D mapreduce.cluster.temp.dir=/tmp/temp
To treat tasks with non-zero exit status as SUCCEDED:
  -D stream.non.zero.exit.is.failure=false
Use a custom hadoop streaming build along with standard hadoop install:
  $HADOOP_HOME/bin/hadoop jar /path/my-hadoop-streaming.jar [...]\
    [...] -D stream.shipped.hadoopstreaming=/path/my-hadoop-streaming.jar
For more details about jobconf parameters see:
  http://wiki.apache.org/hadoop/JobConfFile
Truncate the values of the job configuration copiedto the environment at the given length:
   -D stream.jobconf.truncate.limit=-1
To set an environment variable in a streaming command:
   -cmdenv EXAMPLE_DIR=/home/example/dictionaries/

Shortcut:
   setenv HSTREAMING "$HADOOP_HOME/bin/hadoop jar hadoop-streaming.jar"

Example: $HSTREAMING -mapper "/usr/local/bin/perl5 filter.pl"
           -file /local/filter.pl -input "/logs/0604*/*" [...]
  Ships a script, invokes the non-shipped perl interpreter. Shipped files go to
  the working directory so filter.pl is found by perl. Input files are all the
  daily logs for days in month 2006-04
```

- mapreduce.job.output.key.comparator.class

https://hadoop.apache.org/docs/current/hadoop-streaming/HadoopStreaming.html#Hadoop_Comparator_Class



```bash
yarn jar $HADOOP_STREAMING_JAR -mapper 'cat' -reducer cat -input \
    hdfs://u3:9000/henry/compare_test.txt -output /tmp/compare_test
```


```bash
hdfs dfs -rm -r /tmp/compare_test
yarn jar $HADOOP_STREAMING_JAR -mapper 'cat' -reducer cat -input \
    hdfs://u3:9000/henry/compare_test.txt -output /tmp/compare_test \
    -jobconf mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator \
    -jobconf stream.num.map.output.key.fields=4 \
    -jobconf stream.map.output.field.separator=. \
    -jobconf map.output.key.field.separator=. \
    -jobconf mapred.text.key.comparator.options="-k3,3 -k4nr"
hdfs dfs -cat /tmp/compare_test/part-00000

hdfs dfs -rm -r /tmp/compare_test
yarn jar $HADOOP_STREAMING_JAR -mapper 'cat' -reducer cat -input \
    hdfs://u3:9000/henry/compare_test.txt -output /tmp/compare_test \
    -jobconf mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator \
    -jobconf stream.num.map.output.key.fields=4 \
    -jobconf stream.map.output.field.separator=. \
    -jobconf map.output.key.field.separator=. \
    -jobconf mapred.text.key.comparator.options="-k3,3 -k4,4"
hdfs dfs -cat /tmp/compare_test/part-00000

hdfs dfs -rm -r /tmp/compare_test
yarn jar $HADOOP_STREAMING_JAR -mapper 'cat' -reducer cat -input \
    hdfs://u3:9000/henry/compare_test.txt -output /tmp/compare_test \
    -jobconf mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator \
    -jobconf stream.num.map.output.key.fields=4 \
    -jobconf stream.map.output.field.separator=. \
    -jobconf map.output.key.field.separator=. \
    -jobconf mapred.text.key.comparator.options="-k4,4"
hdfs dfs -cat /tmp/compare_test/part-00000

e.5.9.22	
d.1.5.23	
e.5.1.23	
f.8.3.3	
e.5.1.45	
e.9.4.5	
a.7.2.6	

hdfs dfs -rm -r /tmp/compare_test
yarn jar $HADOOP_STREAMING_JAR -mapper 'cat' -reducer cat -input \
    hdfs://u3:9000/henry/compare_test.txt -output /tmp/compare_test \
    -jobconf mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator \
    -jobconf stream.num.map.output.key.fields=4 \
    -jobconf stream.map.output.field.separator=. \
    -jobconf map.output.key.field.separator=. \
    -jobconf mapred.text.key.comparator.options="-k4,4n"
hdfs dfs -cat /tmp/compare_test/part-00000

f.8.3.3	
e.9.4.5	
a.7.2.6	
e.5.9.22	
d.1.5.23	
e.5.1.23	
e.5.1.45	

hdfs dfs -rm -r /tmp/wk_test 
yarn jar $HADOOP_STREAMING_JAR -mapper 'python mapper.py' -reducer "python reducer.py" -input \
    hdfs://u3:9000/henry/wikipedia.txt -output /tmp/wk_test \
    -jobconf mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator \
    -jobconf mapred.text.key.comparator.options="-k2,2nr" > /dev/null
hdfs dfs -cat /tmp/wk_test/part-00000 | head

hdfs dfs -rm -r /tmp/wk_test 
yarn jar $HADOOP_STREAMING_JAR \
  -D mapred.jab.name="Streaming wordCount" \
  -D mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator \
  -D mapred.text.key.comparator.options="-k2,2nr" \
  -files mapper.py,reducer.py \
  -mapper 'python mapper.py' \
  -reducer "python reducer.py" \
  -input hdfs://u3:9000/henry/wikipedia.txt \
  -output /tmp/wk_test > /dev/null

hdfs dfs -rm -r /tmp/wk_test 
yarn jar $HADOOP_STREAMING_JAR \
  -D mapred.jab.name="Streaming wordCount" \
  -D mapreduce.job.output.key.comparator.class=org.apache.hadoop.mapreduce.lib.partition.KeyFieldBasedComparator \
  -D stream.map.output.field.separator=. \
  -D stream.num.map.output.key.fields=2 \
  -D mapreduce.map.output.key.field.separator="\\t" \
  -D mapreduce.partition.keycomparator.options=-k2,2nr \
  -D mapreduce.job.reduces=1 \
  -files mapper.py,reducer.py \
  -mapper 'python mapper.py' \
  -reducer "python reducer.py" \
  -input hdfs://u3:9000/henry/wikipedia.txt \
  -output /tmp/wk_test > /dev/null

hdfs dfs -rm -r /tmp/wk_test 
yarn jar $HADOOP_STREAMING_JAR \
  -D mapred.jab.name="Streaming wordCount" \
  -files mapper.py,reducer.py \
  -mapper 'python mapper.py' \
  -reducer "python reducer.py" \
  -input hdfs://u3:9000/henry/wikipedia.txt \
  -output /tmp/wk_test > /dev/null

```




### upgrade hadoop from 3.1.1 to 3.2.0

download tar ball of hadoop3.2.0 from apache. Setup all config files. and run `start-all.sh`.
