## 基于`ZooKeeper`的`Dubbo`服务注册中心的原理

### `ZooKeeper`中的节点
`ZooKeeper`是一个树形结构的目录服务，支持变更推送，因此非常适合作为Dubbo服务的注册中心。

注：在`ZooKeeper`中，节点分为两类;
+ 第一类是指构成集群的机器，我们称之为机器节点；
+ 第二类是指数据模型中的数据单元，称之为数据节点ZNode。

**`ZooKeeper`将所有数据存储在内存中，数据模型是一棵树(`ZNode Tree`)，由斜杠（`/`）进行分割的路径，就是一个`ZNode`，例如`/foo/path1`。每个`ZNode`上都会保存自己的数据内容，同时还会保存一系列属性信息。**

在`ZooKeeper`中，`Znode`可分为持久节点和临时节点两类，所谓持久节点是指一旦这个`ZNode`被创建了，除非主动进行`ZNode`的移除操作，否则这个`ZNode`将一直保存在`ZooKeeper`上。

而临时节点就不一样了，它的生命周期和客户端会话绑定，一旦客户端会话失效，那么这个客户端创建的所有临时节点都会被移除。

基于`ZooKeeper`实现的注册中心节点结构示意图:

![zookeeper.png](/images/zookeeper.png)

>+ `/dubbo`：这是`dubbo`在`ZooKeeper`上创建的根节点；
+ `/dubbo/com.foo.BarService`：这是服务节点，代表了`Dubbo`的一个服务；
+ `/dubbo/com.foo.BarService/providers`：这是服务提供者的根节点，其子节点代表了每一个服务真正的提供者；
+ `/dubbo/com.foo.BarService/consumers`：这是服务消费者的根节点，其子节点代表每一个服务真正的消费者；

### 注册中心的工作流程
接下来以上述的`BarService`为例，说明注册中心的工作流程。
1. **`服务提供方启动`**
  + 服务提供者在启动的时候，会在`ZooKeeper`上注册服务。
  + 所谓注册服务，其实就是在`ZooKeeper`的`/dubbo/com.foo.BarService/providers`节点下创建一个子节点，并写入自己的`URL`地址，这就代表了`com.foo.BarService`这个服务的一个提供者。
2. **`服务消费者启动`**
  + 服务消费者在启动的时候，会向`ZooKeeper`注册中心订阅自己的服务。
  + 其实，就是读取并订阅`ZooKeeper`上`/dubbo/com.foo.BarService/providers`节点下的所有子节点，并解析出所有提供者的`URL`地址来作为该服务地址列表。
  + 同时，服务消费者还会在`ZooKeeper`的`/dubbo/com.foo.BarService/consumers`节点下创建一个临时节点，并写入自己的`URL`地址，这就代表了`com.foo.BarService`这个服务的一个消费者。
3. **`消费者远程调用提供者`**
  + 服务消费者，从提供者地址列表中，基于软负载均衡算法，选一个提供者进行调用，如果调用失败，再选另一个提供者调用。
4. **`增加服务提供者`**
  + 增加提供者，也就是在`providers`下面新建子节点。一旦服务提供方有变动，`zookeeper`就会把最新的服务列表推送给消费者。
5. **`减少服务提供者`**
  + 所有提供者在`ZooKeeper`上创建的节点都是临时节点，利用的是临时节点的生命周期和客户端会话相关的特性，因此一旦提供者所在的机器出现故障导致该提供者无法对外提供服务时，该临时节点就会自动从`ZooKeeper`上删除，同样，`zookeeper`会把最新的服务列表推送给消费者。
6. **`ZooKeeper宕机之后`**
  + 消费者每次调用服务提供方是不经过`ZooKeeper`的，消费者只是从`zookeeper`那里获取服务提供方地址列表。
  + 所以当`zookeeper`宕机之后，不会影响消费者调用服务提供者，影响的是`zookeeper`宕机之后如果提供者有变动，增加或者减少，无法把最新的服务提供者地址列表推送给消费者，所以消费者感知不到。

## ZooKeeper使用场景
**zookeeper是一个基于观察者的模式的分布式服务管理框架，负责存储和管理大家都关心的数据，并且接受观察者的注册，一旦发生变化，zookeeper就将通知到这些观察者做相应的变化。**

### 核心场景：解决分布式系统中的一致性问题

核心特性: **zookeeper会维护一个目录结点树，每个节点znode可以被监控，包括监控某个目录中存储的数据变化，子目录节点的变化，一旦变化可以通知设置监控的客户端。**

术语：**客户端有二种，一种是client连接zookeeper的客户端，另一种是follower做为客户端与leader连接。**

任何一台leader或者follower都可以做为客户端连接`zookeeper`服务器，主要操作如下：
>1. 创建与`zookeeper`的连接，通过该对象来在`zookeeper`上维护目录树，`ZooKeeper zk = new ZooKeeper...`
2. 在`zookeeper`上创建一个给定路径的`znode....`
3. 基于`znode`做相应的数据存储，子节点增减等操作

>基于核心特性的主要用途：
1. 单`server`单进程内的锁好实现，但是更复杂的跨越多个`server`多进程的分布式锁`zookeeper`可以轻松实现。
2. 统一配置，集群中的每个`server`配置都需要改动，而通过`zookeeper`核心特性，只需要其中的一个配置，就会通过`watch`通知到其它的`server`自动更新。
3. 类似于`jndi`,给使用者返回一个标志资源的名称，只不过`zookeeper`利用了目录的层次结构唯一标志资源（资源应该是`znode`或者对应的`server`）
4. `zookeeper`用来管理集群（感觉应该是`zookeeper`将管理的重任代理给了`leader`，`zookeeper`会通过指定的端口与`leader`交换信息，`zookeeper`还会指定另一个端口用来`election`与服务器通信）
  + `leader-follower`有点类似`master-save`的模式. `zookeeper`可以用来管理由`leader`与`follower`组成的集群。
  + `leader election` 动态选择`master`,避免了传统意义上的单`master`容易出现的单点故障，选择的策略就是找当前序列号最小的`follower`做为`leader`。**这样确保集群的情况下，总是存在一个leader。**`leader`的目的就是管理服务器的状态，是否可用。
  + 一旦follower挂了，follower与leader之间的长连接就会在指定的时间之后断开，`zookeeper`就会将对应的`znode`删除，并通知其它的`follower`.
  + 一旦`leader`挂了，那么`zookeeper`就会从剩下的`followers`对应的`znode`中选择序列号最小的充当`leader`。 
  + `leader election`主要利用了`SEQUENTIAL`类型的`znode`。该`node`会有序列号，`election`总是选最小序列号的`znode`对应的`server`做为`leader`。
5. 同步队列：有点类似于`barrier`，当队列中的所有成员都加入才触发。
6. 先进先出队列，比如`PERSISTENT_SEQUENTIAL`,仍然利用了通过`SEQUENTIAL`生成的序列号。

## zookeeper中的事件机制

### zookeeper中的监听机制
**zookeeper主要是为了统一分布式系统中各个节点的工作状态，在资源冲突的情况下协调提供节点资源抢占，提供给每个节点了解整个集群所处状态的途径。**

这一切的实现都依赖于zookeeper中的事件监听和通知机制

#### zookeeper中的事件和状态

事件和状态构成了zookeeper客户端连接描述的两个维度。zookeeper客户端状态的变化也是要进行监听和通知的

这里我们通过下面的两个表详细介绍zookeeper中的事件和状态：

#### zookeeper客户端与zookeeper server连接的状态

连接状态| 状态含义|
--|--|
`KeeperState.Expired`|客户端和服务器在ticktime的时间周期内，是要发送心跳通知的。这是租约协议的一个实现。客户端发送request，告诉服务|器其上一个租约时间，服务器收到这个请求后，告诉客户端其下一个租约时间是哪个时间点。当客户端时间戳达到最后一个租约时间，而没有收到服务器发来的任何新租约时间，即认为自己下线（此后客户端会废弃这次连接，并试图重新建立连接）。这个过期状态就是Expired状态
`KeeperState.Disconnected`|就像上面那个状态所述，当客户端断开一个连接（可能是租约期满，也可能是客户端主动断开）这是客户端和服务器的|连接就是Disconnected状态
`KeeperState.SyncConnected`|一旦客户端和服务器的某一个节点建立连接（注意，虽然集群有多个节点，但是客户端一次连接到一个节点就行了）|，并完成一次version、zxid的同步，这时的客户端和服务器的连接状态就是SyncConnected
`KeeperState.AuthFailed`|zookeeper客户端进行连接认证失败时，发生该状态|

需要说明的是，这些状态在触发时，所记录的事件类型都是：`EventType.None`

#### zookeeper中的事件。
当zookeeper客户端监听某个znode节点”/node-x”时：

zookeeper事件|事件含义|
--|--|
`EventType.NodeCreated`|当node-x这个节点被创建时，该事件被触发|
`EventType.NodeChildrenChanged`|当node-x这个节点的直接子节点被创建、被删除、子节点数据发生变更时，该事件被触发。|
`EventType.NodeDataChanged`|当node-x这个节点的数据发生变更时，该事件被触发|
`EventType.NodeDeleted`|当node-x这个节点被删除时，该事件被触发。|
`EventType.None`|当zookeeper客户端的连接状态发生变更时，即`KeeperState.Expired`、`KeeperState.Disconnected`、`KeeperState.SyncConnected`、`KeeperState.AuthFailed`状态切换时，描述的事件类型为`EventType.None`|

#### 获取相应的响应
我们详细描述了zookeeper客户端连接的状态和zookeeper对znode节点监听的事件类型，下面我们来讲解如何建立zookeeper的watcher监听。

在zookeeper中，并没有传统的add****Listener这样的注册监听器的方法。

而是采用`zk.getChildren(path, watch)`、`zk.exists(path, watch)`、`zk.getData(path, watcher, stat)`这样的方式为某个`znode`注册监听。也可以通过`zk.register(watcher)`注册默认监听。

无论哪一种注册监听的方式，都可以对`EventType.None`事件进行监听，如果有多个监听器，这些监听器都会收到`EventType.None`事件。

下表以`node-x`节点为例，说明调用的注册方法和可监听事件间的关系：

注册方式|`NodeCreated`|`NodeChildrenChanged`|`NodeDataChanged`|`EventType.NodeDeleted`|
--|--|--|--|--|
`zk.getChildren(“/node-x”,watcher)`||可监控||可监控|
`zk.exists(“/node-x”,watcher)`|可监控||可监控|可监控|
`zk.getData(“/node-x”,watcher)`|悖论||可监控|可监控|

#### watcher机制
zookeeper中的watcher机制很特别，请注意以下一些关键的经验提醒（这些经验提醒在其他地方找不到）：
>+ 一个节点可以注册多个watcher，但是分成两种情况，当一个watcher实例多次注册时，zkClient也只会通知一次；当多个不同的watcher实例都注册时，zkClient会依次进行通知（并不是很多网贴粗略说的“多次注册一次通知”），后文将会有实验。
+ 监控同一个节点X的一个watcher实例，通过exist、getData等注册方式多次注册的，zkClient也只会通知一次。这个原理在很多网贴上也都有说明，后文我们同样进行实验。
+ 注意，很多网贴都说zk.getData(“/node-x”,watcher)这种注册方式可以监控节点的NodeCreated事件，实际上是不行的（或者说没有意义）。当一个节点还不存在时，zk.getData这样设置的watcher是会抛出KeeperException$NoNodeException异常的，这次注册会失败，watcher也不会起作用；一旦node-x节点存在了，那这个节点的NodeCreated事件又有什么意义呢？
+ zookeeper中并没有“永久监听”这种机制。网上所谓实现了”永久监听”的帖子，只是一种编程技巧。
思路可以归为两类：一种是“在保证所有节点的watcher都被重新注册”的前提下，再进行目录、子目录的更改；
另外一种是“在监听被触发后，被重新注册前，重新取一次节点的信息”确保在“监听真空期”znode没有变化。 有兴趣的读者可自行百度。
下图可以反映zookeeper-watcher的监听真空期：

![zookeeper-watcher.png](/images/zookeeper-watcher.png)

我本人对真空期的处理，更倾向于，注册监听后主动检查本次节点的znode-version和上次节点的znode-version是否一致，来确定是否真空期有节点变化。
3、代码示例
实践是检验真理的唯一途径
3.1、验证监听
3.1.1、验证对一个znode多次注册watcher
为了简单起见，我们先检验一个最好检验的东西，就是为一个znode注册多个watcher时，watcher的通知机制到底是什么样的。这样依赖，第一次接触zookeeper的读者也可以根据代码，快速上手。我们依据前文建立的zookeeper集群，启动了zookeeper的三个工作节点，并注册watcher（我们只会使用其中的一个）：
然后我们加测，使用getDate方法是否能够检测一个不存在的节点“Y”的创建事件。
```
import java.io.FileNotFoundException;
import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.Watcher.Event.EventType;
import org.apache.zookeeper.Watcher.Event.KeeperState;
import org.apache.zookeeper.ZooDefs.Ids;
import org.apache.zookeeper.ZooKeeper;
import org.springframework.util.Log4jConfigurer;

/**
 * 这个测试类测试多个watcher监控某一个znode节点的效果。<br>
 * @author test
 */
public class TestManyWatcher implements Runnable {
    static {
        try {
            Log4jConfigurer.initLogging("classpath:log4j.properties");
        } catch (FileNotFoundException ex) {
            System.err.println("Cannot Initialize log4j");
            System.exit(-1);
        }
    }

    /**
     * 日志
     */
    private static final Log LOGGER = LogFactory.getLog(TestZookeeperAgainst.class);

    public static void main(String[] args) throws Exception {
        TestManyWatcher testManyWatcher = new TestManyWatcher();
        new Thread(testManyWatcher).start();
    }

    public void run() {
        /*
         * 验证过程如下：
         * 1、验证一个节点X上使用exist方式注册的多个监听器（ManyWatcherOne、ManyWatcherTwo），
         *      在节点X发生create事件时的事件通知情况
         * 2、验证一个节点Y上使用getDate方式注册的多个监听器（ManyWatcherOne、ManyWatcherTwo），
         *      在节点X发生create事件时的事件通知情况
         * */
        //默认监听：注册默认监听是为了让None事件都由默认监听处理，
        //不干扰ManyWatcherOne、ManyWatcherTwo的日志输出
        ManyWatcherDefault watcherDefault = new ManyWatcherDefault();
        ZooKeeper zkClient = null;
        try {
            zkClient = new ZooKeeper("192.168.61.129:2181", 120000, watcherDefault);
        } catch (IOException e) {
            TestManyWatcher.LOGGER.error(e.getMessage(), e);
            return;
        }
        //默认监听也可以使用register方法注册
        //zkClient.register(watcherDefault);

        //1、========================================================
        TestManyWatcher.LOGGER.info("=================以下是第一个实验");
        String path = "/X";
        ManyWatcherOne watcherOneX = new ManyWatcherOne(zkClient , path);
        ManyWatcherTwo watcherTwoX = new ManyWatcherTwo(zkClient , path);
        //注册监听，注意，这里两次exists方法的执行返回都是null，因为“X”节点还不存在
        try {
            zkClient.exists(path, watcherOneX);
            zkClient.exists(path, watcherTwoX);
            //创建"X"节点，为了简单起见，我们忽略权限问题。
            //并且创建一个临时节点，这样重复跑代码的时候，不用去server上手动删除)
            zkClient.create(path, "".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL);
        } catch (Exception e) {
            TestManyWatcher.LOGGER.error(e.getMessage(), e);
            return;
        }
        //TODO 注意观察日志，根据原理我们猜测理想情况下ManyWatcherTwo和ManyWatcherOne都会被通知。

        //2、========================================================
        TestManyWatcher.LOGGER.info("=================以下是第二个实验");
        path = "/Y";
        ManyWatcherOne watcherOneY = new ManyWatcherOne(zkClient , path);
        ManyWatcherTwo watcherTwoY = new ManyWatcherTwo(zkClient , path);
        //注册监听，注意，这里使用两次getData方法注册监听，"Y"节点目前并不存在
        try {
            zkClient.getData(path, watcherOneY, null);
            zkClient.getData(path, watcherTwoY, null);
        } catch (Exception e) {
            TestManyWatcher.LOGGER.error(e.getMessage(), e);
        }
        //TODO 注意观察日志，因为"Y"节点不存在，所以getData就会出现异常。watcherOneY、watcherTwoY的注册都不起任何作用。
        //然后我们在报了异常的情况下，创建"Y"节点，根据原理，不会有任何watcher响应"Y"节点的create事件
        try {
            zkClient.create(path, "".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL);
        } catch (Exception e) {
            TestManyWatcher.LOGGER.error(e.getMessage(), e);
            return;
        }

        //下面这段代码可以忽略，是为了观察zk的原理。让守护线程保持不退出
        synchronized(this) {
            try {
                this.wait();
            } catch (InterruptedException e) {
                TestManyWatcher.LOGGER.error(e.getMessage(), e);
                System.exit(-1);
            }
        }
    }
}

/**
 * 这是默认的watcher实现。
 * @author test
 */
class ManyWatcherDefault implements Watcher {
    /**
     * 日志
     */
    private static Log LOGGER = LogFactory.getLog(ManyWatcherDefault.class);

    public void process(WatchedEvent event) {
        KeeperState keeperState = event.getState();
        EventType eventType = event.getType();
        ManyWatcherDefault.LOGGER.info("=========默认监听到None事件：keeperState = " 
                + keeperState + "  :  eventType = " + eventType);
    }
}

/**
 * 这是第一种watcher
 * @author test
 */
class ManyWatcherOne implements Watcher {
    /**
     * 日志
     */
    private static Log LOGGER = LogFactory.getLog(ManyWatcherOne.class);

    private ZooKeeper zkClient;

    /**
     * 被监控的znode地址
     */
    private String watcherPath;

    public ManyWatcherOne(ZooKeeper zkClient , String watcherPath) {
        this.zkClient = zkClient;
        this.watcherPath = watcherPath;
    }

    public void process(WatchedEvent event) {
        try {
            this.zkClient.exists(this.watcherPath, this);
        } catch (Exception e) {
            ManyWatcherOne.LOGGER.error(e.getMessage(), e);
        }
        KeeperState keeperState = event.getState();
        EventType eventType = event.getType();
        //这个属性是发生事件的path
        String eventPath = event.getPath();

        ManyWatcherOne.LOGGER.info("=========ManyWatcherOne监听到" + eventPath + "地址发生事件："
                + "keeperState = " + keeperState + "  :  eventType = " + eventType);
    }
}

/**
 * 这是第二种watcher
 * @author test
 */
class ManyWatcherTwo implements Watcher {
    /**
     * 日志
     */
    private static Log LOGGER = LogFactory.getLog(ManyWatcherOne.class);

    private ZooKeeper zkClient;

    /**
     * 被监控的znode地址
     */
    private String watcherPath;

    public ManyWatcherTwo(ZooKeeper zkClient, String watcherPath) {
        this.zkClient = zkClient;
        this.watcherPath = watcherPath;
    }

    public void process(WatchedEvent event) {
        try {
            this.zkClient.exists(this.watcherPath, this);
        } catch (Exception e) {
            ManyWatcherTwo.LOGGER.error(e.getMessage(), e);
        }
        KeeperState keeperState = event.getState();
        EventType eventType = event.getType();
        //这个属性是发生事件的path
        String eventPath = event.getPath();

        ManyWatcherTwo.LOGGER.info("=========ManyWatcherTwo监听到" + eventPath + "地址发生事件："
                + "keeperState = " + keeperState + "  :  eventType = " + eventType);
    }
}
```
代码中的注释自我感觉写得比较详细，这里就不再介绍了。以下是执行这段测试代码后，所运行的Log4j的日志信息。
```
[2015-08-18 19:27:37] INFO  Thread-0 Initiating client connection, connectString=192.168.61.129:2181 sessionTimeout=120000 watcher=com.test.test.zookeepertest.test.ManyWatcherDefault@6db38815 (ZooKeeper.java:379)
  [2015-08-18 19:27:37] INFO  Thread-0 =================以下是第一个实验 (TestManyWatcher.java:67)
  [2015-08-18 19:27:37] INFO  Thread-0-SendThread() Opening socket connection to server /192.168.61.129:2181 (ClientCnxn.java:1061)
  [2015-08-18 19:27:37] INFO  Thread-0-SendThread(192.168.61.129:2181) Socket connection established to 192.168.61.129/192.168.61.129:2181, initiating session (ClientCnxn.java:950)
  [2015-08-18 19:27:37] INFO  Thread-0-SendThread(192.168.61.129:2181) Session establishment complete on server 192.168.61.129/192.168.61.129:2181, sessionid = 0x14f40902e2a0000, negotiated timeout = 40000 (ClientCnxn.java:739)
  [2015-08-18 19:27:37] INFO  Thread-0-EventThread =========默认监听到None事件：keeperState = SyncConnected  :  eventType = None (TestManyWatcher.java:130)
  [2015-08-18 19:27:37] INFO  Thread-0 =================以下是第二个实验 (TestManyWatcher.java:85)
  [2015-08-18 19:27:37] INFO  Thread-0-EventThread =========ManyWatcherTwo监听到/X地址发生事件：keeperState = SyncConnected  :  eventType = NodeCreated (TestManyWatcher.java:206)
  [2015-08-18 19:27:37] INFO  Thread-0-EventThread =========ManyWatcherOne监听到/X地址发生事件：keeperState = SyncConnected  :  eventType = NodeCreated (TestManyWatcher.java:168)
  [2015-08-18 19:27:37] ERROR Thread-0 KeeperErrorCode = NoNode for /Y (TestManyWatcher.java:94)
  org.apache.zookeeper.KeeperException$NoNodeException: KeeperErrorCode = NoNode for /Y
    at org.apache.zookeeper.KeeperException.create(KeeperException.java:102)
    at org.apache.zookeeper.KeeperException.create(KeeperException.java:42)
    at org.apache.zookeeper.ZooKeeper.getData(ZooKeeper.java:927)
    at com.test.test.zookeepertest.test.TestManyWatcher.run(TestManyWatcher.java:91)
    at java.lang.Thread.run(Unknown Source)
```
在我们调用getData，抛出异常后，我们试图创建“Y”节点。并且发现没有任何监听日志输出。于是我们肯定了上文中的两个描述：
  ● 针对一个节点发生的事件，zkClient是不是做多次watcher通知，和使用什么方法注册的没有关系，关键在于所注册的watcher实例是否为同一个实例。
  ● 使用getDate注册一个不存在的节点的监听，并试图监听这个节点create event是无法实现的。因为会抛出NoNodeException异常，注册watcher的动作也会变得无效。
3.1.2、验证default watcher监听EventType.None事件
这个测试在指定了默认watcher监听和没有指定默认watcher监听的两种情况下。zkClient对Event-NONE事件的响应机制。

```
import java.io.FileNotFoundException;
import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.ZooKeeper;
import org.apache.zookeeper.Watcher.Event.EventType;
import org.apache.zookeeper.Watcher.Event.KeeperState;
import org.apache.zookeeper.ZooDefs.Ids;
import org.springframework.util.Log4jConfigurer;

/**
 * 这个测试类测试在指定了默认watcher，并且有不止一个watcher实例的情况下。zkClient对Event-NONE事件的响应机制。
 * servers：192.168.61.129:2181，192.168.61.130:2181，192.168.61.132:2181<br>
 * 我们选择一个节点进行连接(192.168.61.129)，这样好在主动停止这个zk节点后，观察watcher的响应情况。
 * @author test
 */
public class TestEventNoneWatcher implements Runnable {

    static {
        try {
            Log4jConfigurer.initLogging("classpath:log4j.properties");
        } catch (FileNotFoundException ex) {
            System.err.println("Cannot Initialize log4j");
            System.exit(-1);
        }
    }

    /**
     * 日志
     */
    private static final Log LOGGER = LogFactory.getLog(TestEventNoneWatcher.class);

    private ZooKeeper zkClient = null;

    public static void main(String[] args) throws Exception {
        TestEventNoneWatcher testEventNoneWatcher = new TestEventNoneWatcher();
        new Thread(testEventNoneWatcher).start();
    }

    public void run() {
        /*
         * 验证过程如下：
         * 1、连接zk后，并不进行进行默认的watcher的注册，并且使用exist方法注册一个监听节点"X"的监听器。
         *      （完成后主线程进入等待状态）
         * 2、关闭192.168.61.129:2181这个zk节点，让Disconnected事件发生。
         *      观察到底是哪个watcher响应这些None事件。
         * */
        //1、========================================================
        //注册默认监听
        EventNodeWatcherDefault watcherDefault = new EventNodeWatcherDefault(this);
        try {
            this.zkClient = new ZooKeeper("192.168.61.129:2181", 120000, watcherDefault);
        } catch (IOException e) {
            TestEventNoneWatcher.LOGGER.error(e.getMessage(), e);
            return;
        }

        String path = "/X";
        EventNodeWatcherOne eventNodeWatcherOne = new EventNodeWatcherOne(this.zkClient , path);
        //注册监听，注意，这里两次exists方法的执行返回都是null，因为“X”节点还不存在
        try {
            zkClient.exists(path, eventNodeWatcherOne);
            //创建"X"节点，为了简单起见，我们忽略权限问题。
            //并且创建一个临时节点，这样重复跑代码的时候，不用去server上手动删除)
            zkClient.create(path, "".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL);
        } catch (Exception e) {
            TestEventNoneWatcher.LOGGER.error(e.getMessage(), e);
            return;
        }

        //完成注册后，主线程等待。然后关闭192.168.61.129上的zk节点
        synchronized(this) {
            try {
                this.wait();
            } catch (InterruptedException e) {
                TestEventNoneWatcher.LOGGER.error(e.getMessage(), e);
                System.exit(-1);
            }
        }
    }

    public ZooKeeper getZkClient() {
        return zkClient;
    }
}

/**
 * 这是默认的watcher实现。
 * @author test
 */
class EventNodeWatcherDefault implements Watcher {
    /**
     * 日志
     */
    private static Log LOGGER = LogFactory.getLog(EventNodeWatcherDefault.class);

    private TestEventNoneWatcher eventNoneWatcherThead;

    public EventNodeWatcherDefault(TestEventNoneWatcher eventNoneWatcherThead) {
        this.eventNoneWatcherThead = eventNoneWatcherThead;
    }

    public void process(WatchedEvent event) {
        //重新注册监听
        this.eventNoneWatcherThead.getZkClient().register(this);

        KeeperState keeperState = event.getState();
        EventType eventType = event.getType();
        EventNodeWatcherDefault.LOGGER.info("=========默认EventNodeWatcher监听到None事件：keeperState = " 
                + keeperState + "  :  eventType = " + eventType);
    }
}

/**
 * 这是第一种watcher
 * @author test
 */
class EventNodeWatcherOne implements Watcher {
    /**
     * 日志
     */
    private static Log LOGGER = LogFactory.getLog(EventNodeWatcherOne.class);

    private ZooKeeper zkClient;

    /**
     * 被监控的znode地址
     */
    private String watcherPath;

    public EventNodeWatcherOne(ZooKeeper zkClient , String watcherPath) {
        this.zkClient = zkClient;
        this.watcherPath = watcherPath;
    }

    public void process(WatchedEvent event) {
        try {
            this.zkClient.exists(this.watcherPath, this);
        } catch (Exception e) {
            EventNodeWatcherOne.LOGGER.error(e.getMessage(), e);
        }
        KeeperState keeperState = event.getState();
        EventType eventType = event.getType();

        EventNodeWatcherOne.LOGGER.info("=========EventNodeWatcherOne监听到事件：keeperState = " 
                + keeperState + "  :  eventType = " + eventType);
    }
}
```
我们来执行这段代码。打印的Log4j的信息如下：

从log4j的日志可以看到，默认的watcher，监听到了zkClient的Event-None事件。而节点”X”的创建事件由EventNodeWatcherOne的实例进行了监听。接下来测试代码进入了等待状态。
然后我们关闭这个zkServer节点，并且观察watcher的响应情况：
```
[root@vm1 ~]# zkServer.sh stop
JMX enabled by default
Using config: /usr/zookeeper-3.4.6/bin/../conf/zoo.cfg
Stopping zookeeper ... STOPPED
```
以下是zk客户端响应的log4j日志信息：

红圈处，我们看到zkServer的节点断开后，EventType.None事件被已经注册的两个watcher分别响应了一次。这里注意两个异常：第一个异常是断开连接后，socket报的错误，从错误中我们可以看到zookeeper客户端的连接使用了sun的nio框架（如果您不知道nio请自行百度，或者关注我后续的博文）；第二个错，是在断开连接后，EventNodeWatcherOne试图重新使用exists方式注册监听，所以报错。
可见EventType.None事件，会由所有的监听器全部响应。所以这里我们的编程建议是：一定要使用默认监听器，并由默认监听器来响应EventType.None事件；其他针对znode节点的接听器，只针对节点事件进行处理，使用if语句进行过滤，如果发现是EventType.None事件，则忽略不作处理。
当然，任何编码过程都是要根据您自己的业务规则来设计。以上的建议只是笔者针对一般业务情况的处理方式。
3.2、协调独享资源的抢占
下面的代码，用来向各位看官演示，zookeeper利用其znode机制，是怎么完成资源抢占的协调过程的。为了简化代码片段，我没有使用默认的watcher监听，所以启动的时候会报一个空指针错误是正常的，原因在org.apache.zookeeper.ClientCnxn的524行（3.4.5版本）：
```
private void processEvent(Object event) {
    try {
     if (event instanceof WatcherSetEventPair) {
         // each watcher will process the event
         WatcherSetEventPair pair = (WatcherSetEventPair) event;
         for (Watcher watcher : pair.watchers) {
             try {
                 watcher.process(pair.event);
             } catch (Throwable t) {
                 LOG.error("Error while calling watcher ", t);
             }
         }
     } else {
         。。。。
```
通过这段代码，读者还可以跟踪出各种事件的响应方式。但这个不是本文中扩散讨论的了，在我后续hadoop系列文章中，我还会介绍zookeeper，那时我们会深入讨论zookeeper客户端重连过程、更深层次的watcher事件机制。
话锋转回，下面的代码是如何使用zookeeper进行独享资源的协调，同样的，代码中注释写得比较清楚，就不在进行文字叙述了（代码是可以运行的，但是不建议拷贝粘贴哈^_^）：
```
import java.io.FileNotFoundException;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.Watcher.Event.EventType;
import org.apache.zookeeper.ZooDefs.Ids;
import org.apache.zookeeper.ZooKeeper;
import org.apache.zookeeper.data.Stat;
import org.springframework.util.Log4jConfigurer;

public class TestZookeeperAgainst implements Runnable {
    static {
        try {
            Log4jConfigurer.initLogging("classpath:log4j.properties");
        } catch (FileNotFoundException ex) {
            System.err.println("Cannot Initialize log4j");
            System.exit(-1);
        }
    }

    /**
     * 日志
     */
    private static final Log LOGGER = LogFactory.getLog(TestZookeeperAgainst.class);

    private ZooKeeper zk;

    /**
     * 代表“我”创建的子节点
     */
    private String myChildNodeName;

    public static void main(String[] args) throws Exception {
        TestZookeeperAgainst testZookeeperAgainst = new TestZookeeperAgainst();
        new Thread(testZookeeperAgainst).start();
    }

    public TestZookeeperAgainst() throws Exception {
        this.zk = new ZooKeeper("192.168.61.129:2181,192.168.61.130:2181,192.168.61.132:2181", 7200000, new DefaultWatcher());

        //创建一个父级节点filesq（如果没有的话）
        Stat pathStat = null;
        try {
            pathStat = this.zk.exists("/filesq", null);
            //2.2如果条件成立，说明节点不存在（只需要判断一个节点的存在性即可）
            if(pathStat == null) {
                this.zk.create("/filesq", "".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
            }
        } catch(Exception e) {
            TestZookeeperAgainst.LOGGER.error(e.getMessage(), e);
            System.exit(-1);
        }
    }

    public void run() {
        /*
         * 当这个线程活动时，我们做以下几个事情：
         * 1、首先注册/filesq，检控/filesq下子节点的变化
         * 2、向/filesq中注册一个临时的，带有唯一编号的子节点，
         * 3、然后等待，直到AgainstWatcher发现已经轮到“自己”执行，并唤醒
         * 4、唤醒后，开始执行具体的业务。
         * 5、执行完成后，主动删除这个子节点， 或者剥离与zk的连接（推荐前者，但怎么操作，还是根据业务来）
         * */

        //1、==============
        String childPath = "/filesq/childnode";
        AgainstWatcher againstWatcher = new AgainstWatcher(this);
        try {
            //建立监听
            this.zk.getChildren("/filesq", againstWatcher);
            //2、==============
            this.myChildNodeName = this.zk.create(childPath, "".getBytes(), 
                    Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL_SEQUENTIAL);
        } catch (Exception e) {
            TestZookeeperAgainst.LOGGER.error(e.getMessage(), e);
            System.exit(-1);
        }
        TestZookeeperAgainst.LOGGER.info("被创建的子节点是：" + this.myChildNodeName);

        //3、==============
        synchronized(this) {
            try {
                this.wait();
            } catch (InterruptedException e) {
                TestZookeeperAgainst.LOGGER.error(e.getMessage(), e);
                System.exit(-1);
            }
        }

        //4、==============
        TestZookeeperAgainst.LOGGER.info("唤醒后，开始执行具体的业务=========");

        //5、==============
        try {
            this.zk.delete(this.myChildNodeName, -1);
        } catch (Exception e) {
            TestZookeeperAgainst.LOGGER.error(e.getMessage(), e);
            System.exit(-1);
        }
        //this.zk.close();

        //下面这段代码完全可以在正式使用时忽略，完全是为了观察zk的原理
        synchronized(this) {
            try {
                this.wait();
            } catch (InterruptedException e) {
                TestZookeeperAgainst.LOGGER.error(e.getMessage(), e);
                System.exit(-1);
            }
        }
    }

    public String getMyChildNodeName() {
        return myChildNodeName;
    }

    public ZooKeeper getZk() {
        return zk;
    }
}

/**
 * 这个watcher专门用来监听子级节点的变化
 * @author test
 */
class AgainstWatcher implements Watcher {

    private static final Log LOGGER = LogFactory.getLog(AgainstWatcher.class);

    private TestZookeeperAgainst parentThread;

    public AgainstWatcher(TestZookeeperAgainst parentThread) {
        this.parentThread = parentThread;
    }

    public void process(WatchedEvent event) {
        /*
         * 作为znode观察者，需要做以下事情：
         * 1、当收到一个监听事件后，要马上重新注册zk，以便保证下次事件监听能被接受
         * 2、比较当前/filesq下最小的一个节点A，如果这个节点A不是自己创建的，
         *      说明还不到自己执行，忽略后续操作
         * 3、如果A是自己创建的，则说明轮到自己占有这个资源了，唤醒parentThread进行业务处理
         * */
        //1、=========================
        ZooKeeper zk = this.parentThread.getZk();
        List<String> childPaths = null;
        try {
            childPaths = zk.getChildren("/filesq", this);
        } catch (Exception e) {
            AgainstWatcher.LOGGER.error(e.getMessage(), e);
            System.exit(-1);
        }
        if(event.getType() != EventType.NodeChildrenChanged || childPaths == null || childPaths.size() == 0) {
            return;
        }

        //2、=========================
        String nowPath = "/filesq/" + childPaths.get(0);
        String myChildNodeName = this.parentThread.getMyChildNodeName();
        if(!StringUtils.equals(nowPath, myChildNodeName)) {
            return;
        }

        //3、=========================
        synchronized(this.parentThread) {
            this.parentThread.notify();
        }
    }
}
```