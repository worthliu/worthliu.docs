## 单点模式的安装

下面我们就来实际安装zookeeper。

首先我们进行单服务器的zookeeper安装，让zookeeper跑起来。成功后，我们再进行扩展，在多台（三台）服务器上进行zookeeper的安装，并让其作为一个整体，运行起来。

### 准备工作
我们将在的机器上安装zookeeper，您至少需要准备：
>1. `JDK1.7.X`以上版本，根据您自己的实际情况选择32位系统或者64位系统。下载地址为：`http://www.oracle.com/technetwork/java/javase/downloads/index-jsp-138363.html`
2. `zookeeper`，我下载的是`zookeeper-3.4.6`版本，您可以访问`zookeeper`官网，下载稳定版本：`http://www.apache.org/dyn/closer.cgi/zookeeper/`

**JDK的安装这里用几句话描述就行了，但是一定记得设置PATH，classpath，JAVA_HOME环境变量：**
```
tar -zxvf ./jdk-7u71-linux-x64.tar.gz
```

我将设置JDK的路径为：`/usr/jdk1.7.0_71`
```
mv ./jdk1.7.0_71 /usr/jdk1.7.0_71/
```
记得设置环境变量（全局配置文件为：`/etc/profile`）
```
vim /etc/profile
```
粘贴以下脚本到文件：
```
export PATH=/usr/jdk1.7.0_71/bin:$PATH
export classpath=/usr/jdk1.7.0_71/lib
export JAVA_HOME=/usr/jdk1.7.0_71
```
记得保存文件哈。然后重新加载操作系统用户的环境信息：`su - root`

完成准备工作后，运行一下java命令，验证准备工作是正确的（如果出现了一些java的帮助信息，说明java命令运行成功了）。

`zookeeper`的目录我是放置在`/usr/zookeeper-3.4.6/`这个位置，所以：
```
tar -zxvf ./zookeeper-3.4.6.tar.gz

mv ./zookeeper-3.4.6 /usr/zookeeper-3.4.6/
```
同样的，设置全局环境变量：
```
export PATH=/usr/zookeeper-3.4.6/bin:$PATH
```
好的，安装完成了，是不是简单。

### zookeeper的主配置文件。
zookeeper的主配置文件所在的地址是：`${您的zookeeper安装位置}/conf/zoo.cfg`。但是，解压后的zookeeper并没有这个配置文件，有一个名叫`zoo_sample.cfg`，所以，我们复制一个`zoo.cfg`文件：

```
cp /usr/zookeeper-3.4.6/conf/zoo_sample.cfg /usr/zookeeper-3.4.6/conf/zoo.cfg
```
接下来，我们讲解一下这个配置文件中的重要配置项（在单节点模式下，配置信息不需要做任何更改，就可以运行）：

```
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial 
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between 
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just 
# example sakes.
dataDir=/tmp/zookeeper
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
# maxClientCnxns=60
#
# Be sure to read the maintenance section of the 
# administrator guide before turning on autopurge.
#
# The number of snapshots to retain in dataDir
# autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
# autopurge.purgeInterval=1
```

>+ `tickTime`：这个属性我们将在讲解zookeeper的选举机制时进行着重说明。
+ `dataDir`：zookeeper的工作目录，注释写得很清楚，只有测试环境才使用tmp目录，否则都建议进行专门的设置。
+ `clientPort`：客户端的连接端口
+ `maxClientCnxns`：客户端最大连接数

最后，使用`zkServer.sh start`命令，启动zookeeper：

```
[root@vm2 ~]# zkServer.sh start
JMX enabled by default
Using config: /usr/zookeeper-3.4.6/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
```

之后可以使用`zkServer.sh status`查看zookeeper的工作状态：

```
[root@vm2 ~]# zkServer.sh status
JMX enabled by default
Using config: /usr/zookeeper-3.4.6/bin/../conf/zoo.cfg
Mode: standalone
```

使用jps命令也可以查看：

```
[root@vm2 ~]# jps
28172 Jps
14639 QuorumPeerMain
```

`QuorumPeerMain`这个进程就是`zookeeper`的进程。至此，`zookeeper`的单节点安装就成功了。

## 集群模式下的安装

### 准备工作

准备多台机器，最好3台以上（n+1）;

安装JDK，设置环境变量，解压并zookeeper，这些步骤就都不说了，请参见上文中的设置。

>+ 所有节点的JDK安装路径，zookeeper的安装路径和环境变量的设置都完全一样，这样不会配着配着就把自己脑袋配晕（特别是如果您是第一次进行zookeeper的配置）
+ 在正式环境中，我们不会使用root用户进行zookeeper的运行。所以您最好在测试环境的时候创建一个用户，例如名字叫做zookeeper的用户。
+ 正式换进下我们一般也不会关闭防火墙。但是为了保证在测试环境下熟悉相关的配置，我建议您关闭防火墙。（如果开启防火墙的话，请打开2181、2888、3888这几个端口）

我们先创建几个文件夹，注意文件夹的权限要为您当前的用户打开（如果是root用户，就不需要关心这个问题）。等一下配置过程中，我们会用到这些文件夹。
```
创建zookeeper工作目录：
mkdir -p /usr/zookeeperdata/
mkdir -p /usr/zookeeperdata/data
```
```
创建zookeeper日志目录：
mkdir -p /usr/zookeeperdata/log
```
到此，准备工作结束。
### 正式安装（配置项讲解）
如果您是按照我的建议进行的准备工作，那么到这里，您三台机器的目录结构、环境变量、执行用户都应该是完全一致的。这里您只需要配置其中的一台，然后将配置文件scp到另外两台，就可以完成配置了。
以下是其中一台的配置信息：
```
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial 
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between 
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just 
# example sakes.
dataDir=/usr/zookeeperdata/data
dataLogDir=/usr/zookeeperdata/log
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the 
# administrator guide before turning on autopurge.
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1

server.1=ip1:2888:3888
server.2=ip2:2888:3888
server.3=ip3:2888:3888
```

请注意变化的信息：
我们重新设置了zookeeper的工作目录和日志目录：
``` 
dataDir=/usr/zookeeperdata/data 
dataLogDir=/usr/zookeeperdata/log
```
我们指定了整个zookeeper集群的server编号、地址和端口： 
```
server.2=ip2:2888:3888 
server.3=ip3:2888:3888
```

完成后我们将其中配置文件拷贝到另外两台机器上：
```
scp /usr/zookeeper-3.4.6/conf/zoo.cfg root@IP ADDRESS:/usr/zookeeper-3.4.6/conf/zoo.cfg
scp /usr/zookeeper-3.4.6/conf/zoo.cfg root@IP ADDRESS:/usr/zookeeper-3.4.6/conf/zoo.cfg
```
现在最重要的一个步骤到了。还记得我们在配置文件中给出的server列表都有一个编号吗？

我们需要为这三个节点创建对应的编号文件，在`/usr/zookeeperdata/data/myid`文件中。

如下：
```
server.1=ip1:2888:3888，所以在129这台机器上执行：
echo 1 > /usr/zookeeperdata/data/myid

server.2=ip2:2888:3888，所以在130这台机器上执行：
echo 2 > /usr/zookeeperdata/data/myid

server.3=ip3:2888:3888，所以在131这台机器上执行：
echo 3 > /usr/zookeeperdata/data/myid
```
至此，大功告成，我们准备开始启动了。分别在三台机器上执行（注意，执行部分先后）：
```
zkServer.sh start
```
出现的结果如下（可能您的结果状态和我的会不一样）
```
ip1：
zkServer.sh status
JMX enabled by default
Using config: /usr/zookeeper-3.4.6/bin/../conf/zoo.cfg
Mode: follower

ip2：
zkServer.sh status
JMX enabled by default
Using config: /usr/zookeeper-3.4.6/bin/../conf/zoo.cfg
Mode: leader

ip3：
zkServer.sh status
JMX enabled by default
Using config: /usr/zookeeper-3.4.6/bin/../conf/zoo.cfg
Mode: follower
```
在一个zookeeper集群集群中，始终有一个节点会通过集群所有节点参与的选举被推举为“leader”节点。其他节点就是“follower”节点。

## 简要命令和结构说明
本小结，我们简单说明一下zookeeper的数据存储结构，算是为下一篇文章介绍zookeeper中几个重要的原理打打基础。

### zookeeper的存储结构

zookeeper中的数据是按照“树”结构进行存储的。而且znode节点还分为4中不同的类型。如下：

>+ `PERSISTENT-持久化节点`：创建这个节点的客户端在与zookeeper服务的连接断开后，这个节点也不会被删除（除非您使用API强制删除）。
+ `PERSISTENT_SEQUENTIAL-持久化顺序编号节点`：当客户端请求创建这个节点A后，zookeeper会根据parent-znode的zxid状态，为这个A节点编写一个全目录唯一的编号（这个编号只会一直增长）。当客户端与zookeeper服务的连接断开后，这个节点也不会被删除。
+ `EPHEMERAL-临时znode节点`：创建这个节点的客户端在与zookeeper服务的连接断开后，这个节点就会被删除。
+ `EPHEMERAL_SEQUENTIAL-临时顺序编号znode节点`：当客户端请求创建这个节点A后，zookeeper会根据parent-znode的zxid状态，为这个A节点编写一个全目录唯一的编号（这个编号只会一直增长）。当创建这个节点的客户端与zookeeper服务的连接断开后，这个节点被删除

### 运行zkCli.sh命令
我们可以使用zkCli.sh命令，登录到一个zookeeper节点（不一定是leader节点），并通过命令行操作zookeeper的数据结构。

```
[root@vm2 ~]# zkCli.sh
Connecting to localhost:2181
2015-08-08 08:18:15,181 [myid:] - INFO  [main:Environment@100] - Client environment:zookeeper.version=3.4.6-1569965, built on 02/20/2014 09:09 GMT
2015-08-08 08:18:15,193 [myid:] - INFO  [main:Environment@100] - Client environment:host.name=vm2

[zk: localhost:2181(CONNECTED) 0]
```
通过ls命令，可以查看zookeeper集群当前的数据结构：

```
[zk: localhost:2181(CONNECTED) 1] ls /
[zookeeper]

```
当然，您还可以更多的命令：
```
connect host:port
get path [watch]
ls path [watch]
set path data [version]
rmr path
delquota [-n|-b] path
quit
printwatches on|off
create [-s] [-e] path data acl
stat path [watch]
close
ls2 path [watch]
history
listquota path
setAcl path acl
getAcl path
sync path
redo cmdno
addauth scheme auth
delete path [version]
setquota -n|-b val path
```