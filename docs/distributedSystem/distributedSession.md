## 分布式Session

### 粘性session

+ 原理：指将用户锁定到某一个服务器上，比如上面说的例子，用户第一次请求时，负载均衡器将用户的请求转发到了A服务器上，如果负载均衡器设置了粘性`Session`的话，那么用户以后的每次请求都会转发到A服务器上，相当于把用户和A服务器粘到了一块，这就是粘性`Session`机制。
+ 优点：简单，不需要对`session`做任何处理。
+ 缺点：缺乏容错性，如果当前访问的服务器发生故障，用户被转移到第二个服务器上时，他的`session`信息都将失效。
+ 适用场景：发生故障对客户产生的影响较小；服务器发生故障是低概率事件。

实现方式：以`Nginx`为例，在`upstream`模块配置`ip_hash`属性即可实现粘性`Session`。

```
  upstream mycluster{
     #这里添加的是上面启动好的两台Tomcat服务器
     ip_hash; #粘性Session
     server 192.168.22.229:8080 weight=1;
     server 192.168.22.230:8080 weight=1;
  }
```

### 服务器session复制

+ 原理：任何一个服务器上的`session`发生改变（增删改），该节点会把这个 `session`的所有内容序列化，然后广播给所有其它节点，不管其他服务器需不需要`session`，以此来保证`Session`同步。
+ 优点：可容错，各个服务器间`session`能够实时响应。
+ 缺点：会对网络负荷造成一定压力，如果`session`量大的话可能会造成网络堵塞，拖慢服务器性能。


实现方式：

1. 设置`tomcat `，server.xml 开启tomcat集群功能 Address:填写本机ip即可，设置端口号，预防端口冲突。

```
<Engine name="Catalina" defaultHost="localhost">

  <!-- 基于网络广播的策略,一个节点session变化,其他节点同步复制,节点多或数据量大时数据量大时性能低下 -->
  <Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster">
    <Channel className="org.apache.catalina.tribes.group.GroupChannel"
      <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver" 
      address="XXX.XXX.XXX.XXX" port="XXX" />
    </Channel>
  </Cluster>
</Engine>

```

2. 在应用里增加信息：通知应用当前处于集群环境中，支持分布式在`web.xml`中添加选项


### session共享机制

使用分布式缓存方案比如`memcached`、`redis`，但是要求`Memcached`或`Redis`必须是集群。

使用`Session`共享也分两种机制，两种情况如下：

1. 粘性`session`处理方式
  + 原理：**不同的`tomcat`指定访问不同的主`memcached`。多个`Memcached`之间信息是同步的，能主从备份和高可用。**用户访问时首先在`tomcat`中创建`session`，然后将`session`复制一份放到它对应的Memcached上。Memcached只起备份作用，读写都在`tomcat`上。当某一个`tomcat`挂掉后，集群将用户的访问定位到备`tomcat`上，然后根据`cookie`中存储的`SessionId`找`session`，找不到时，再去相应的`Memcached`上去`session`，找到之后将其复制到备`tomcat`上。

2. 非粘性`session`处理方式
  + 原理：`Memcached`做主从复制，写入`session`都往从`Memcached`服务上写，读取都从主`memcached`读取，tomcat本身不存储`session`
  + 优点：可容错，`session`实时响应。
  + 实现方式：用开源的`msm`插件解决`tomcat`之间的`session`共享：`Memcached_Session_Manager（MSM）`
    
a. 复制相关jar包到`tomcat/lib`目录下`JAVA memcached`客户端：`spymemcached.jar`

>msm项目相关的jar包：
1. 核心包，`memcached-session-manager-{version}.jar`
2. Tomcat版本对应的jar包：`memcached-session-manager-tc{tomcat-version}-{version}.jar`

**序列化工具包：可选`kryo`，`javolution`,`xstream`等，不设置时使用`jdk`默认序列化。**

b. 配置`Context.xml` ，加入处理`Session`的`Manager`

粘性模式配置：

```
<Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
  memcachedNodes="n1:XXX.XXX.XXX.XXX:xxxx,n2:XXX.XXX.XXX.XXX:xxxx"
  failoverNodes="n1"
  requestUriIgnorePattern=".*\.(jpg|png|css|js)$"
  memcachedProtocol="binary"
  transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
/>
```

非粘性配置：

```
<Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
  memcachedNodes="n1:XXX.XXX.XXX.XXX:xxxx,n2:XXX.XXX.XXX.XXX:xxxx"
  sticky="false"
  sessionBackupAsync="false"
  lockingMode="auto"
  requestUriIgnorePattern=".*\.(jpg|png|css|js)$"
  memcachedProtocol="binary"
  transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
/>
```


### session持久化到数据库
  + 原理：就不用多说了吧，拿出一个数据库，专门用来存储`session`信息。保证`session`的持久化。
  + 优点：服务器出现问题，`session`不会丢失
  + 缺点：如果网站的访问量很大，把`session`存储到数据库中，会对数据库造成很大压力，还需要增加额外的开销维护数据库。

### `terracotta`实现`session`复制
  + 原理：`Terracotta`的基本原理是对于集群间共享的数据，当在一个节点发生变化的时候，`Terracotta`只把变化的部分发送给`Terracotta`服务器，然后由服务器把它转发给真正需要这个数据的节点。可以看成是对第二种方案的优化。
  + 优点：这样对网络的压力就非常小，各个节点也不必浪费CPU时间和内存进行大量的序列化操作。把这种集群间数据共享的机制应用在session同步上，既避免了对数据库的依赖，又能达到负载均衡和灾难恢复的效果。