
## tomcat连接器模式

Tomcat共有三种连接器模式，BIO/NIO/APR，其中NIO是异步IO模式的简称。

>在默认的配置下，NIO的模式的实现模型如下：
+ `Acceptor线程`：全局唯一，负责接受请求，并将请求放入Poller线程的事件队列。Accetpr线程在分发事件的时候，采用的Round Robin的方式来分发的
+ `Poller线程`：官方的建议是每个处理器配一个，但不要超过两个，由于现在几乎都是多核处理器，所以一般来说都是两个。每个Poller线程各自维护一个事件队列（无上限），它的职责是从事件队列里面拿出socket，往自己的selector上注册，然后等待selector选择读写事件，并交给SocketProcessor线程去实际处理请求。
+ `SocketProcessor线程`：`Ali-tomcat`的默认配置是`250`(参见`server.xml`里面的`maxThreads`)，它是实际的工作线程，用于处理请求。
一个典型的请求处理过程

![tomcatSelector.png](/images/tomcatSelector.png)

如图所示，是一个典型的请求处理过程。其中绿色代表线程，蓝色代表数据。
>1. `Acceptor线程`接受请求，从`socketCache`里面拿出`socket对象`（没有的话会创建，缓存的目的是避免对象创建的开销），
2. `Acceptor线程`标记好`Poller对象`，组装成`PollerEvent`，放入该`Poller对象`的`PollerEvent`队列
3. `Poller线程`从事件队列里面拿出`PollerEven`t，将其中的`socket`注册到自身的`selector`上，
4. `Poller线程`等到有读写事件发生时，分发给`SocketProcessor`线程去实际处理请求
5. `SocketProcessor线程`处理完请求，`socket对象`被回收，放入`socketCache`

## BIO、NIO、APR

**Tomcat支持三种接收请求的处理方式：`BIO`、`NIO`、`APR`**

1. `BIO模式`：阻塞式`I/O`操作，表示Tomcat使用的是传统`Java I/O`操作(即`Java.io包及其子包`)。
   + Tomcat7以下版本默认情况下是以bio模式运行的，由于每个请求都要创建一个线程来处理，线程开销较大，不能处理高并发的场景，在三种模式中性能也最低。

启动tomcat看到如下日志，表示使用的是`BIO模式`： 
![bio.png](/images/bio.png)

2. `NIO模式`：是java SE 1.4及后续版本提供的一种新的I/O操作方式(即java.nio包及其子包)。
  + 是一个基于缓冲区、并能提供非阻塞I/O操作的Java API，它拥有比传统I/O操作(bio)更好的并发运行性能。
  + 在tomcat 8之前要让`Tomcat`以`nio模式`来运行比较简单，只需要在`Tomcat`安装目录`/conf/server.xml`文件中将如下配置：

```
<Connector port="8080" protocol="HTTP/1.1" connectionTimeout="20000" redirectPort="8443" />
```
修改成

```
<Connector port="8080"  protocol="org.apache.coyote.http11.Http11NioProtocol" 
connectionTimeout="20000"  redirectPort="8443" />
```
Tomcat8以上版本，默认使用的就是`NIO模式`，不需要额外修改 

3. `APR模式`：简单理解，就是从操作系统级别解决`异步IO`问题，大幅度的提高服务器的处理和响应性能， 也是Tomcat运行高并发应用的首选模式。

启用这种模式稍微麻烦一些，需要安装一些依赖库，下面以在CentOS7 mini版环境下Tomcat-8.0.35为例，介绍安装步聚：

```
+ APR 1.2+ development headers (libapr1-dev package)
+ OpenSSL 0.9.7+ development headers (libssl-dev package)
+ JNI headers from Java compatible JDK 1.4+
+ GNU development environment (gcc, make)
```

## Netty线程模型

回顾下目前一般的NIO服务器端的大致实现，借鉴Netty系列之中的一张图 ：

![nettyThread.png](/images/nettyThread.png)

>+ 一个或多个`Acceptor`线程，每个线程都有自己的`Selector`，`Acceptor`只负责`accept`新的连接，一旦连接建立之后就将连接注册到其他`Worker`线程中。 
+ 多个`Worker`线程，有时候也叫`IO`线程，就是专门负责`IO`读写的。
  + 一种实现方式就是像`Netty`一样，每个`Worker`线程都有自己的`Selector`，可以负责多个连接的IO读写事件，每个连接归属于某个线程。
  + 另一种方式实现方式就是有专门的线程负责`IO`事件监听，这些线程有自己的`Selector`，一旦监听到有`IO`读写事件，并不是像第一种实现方式那样（自己去执行`IO`操作），而是将`IO`操作封装成一个`Runnable`交给`Worker`线程池来执行，这种情况每个连接可能会被多个线程同时操作，相比第一种并发性提高了，但是也可能引来多线程问题，在处理上要更加谨慎些。

(**tomcat的NIO模型就是第二种。**)

这就要详细了解下`tomcat`的`NioEndpoint`实现了。

![tomcatSelector.png](/images/tomcatSelector.png)

这张图勾画出了`NioEndpoint`的大致执行流程图，`worker`线程并没有体现出来，它是作为一个线程池不断的执行IO读写事件即`SocketProcessor（一个Runnable）`，即这里的`Poller`仅仅监听`Socket`的IO事件，然后封装成一个个的`SocketProcessor`交给worker线程池来处理。
下面我们来详细的介绍下`NioEndpoint`中的`Acceptor`、`Poller`、`SocketProcessor`。 

它们处理客户端连接的主要流程如图所示： 

![NioEndpoint.png](/images/NioEndpoint.png)

图中`Acceptor`及`Worker`分别是以线程池形式存在，`Poller`是一个单线程。

（注意，与`BIO`的实现一样，缺省状态下，在`server.xml`中没有配置`<Executor>`，则以`Worker线程池`运行；

如果配置了`<Executor>`，则以基于`java concurrent`系列的`java.util.concurrent.ThreadPoolExecutor`线程池运行。）


1. `Acceptor （线程池）`
  + 接收`socket`线程，这里虽然是基于`NIO`的`connector`，但是在接收`socket`方面还是传统的`serverSocket.accept()`方式，获得`SocketChannel`对象，然后封装在一个tomcat的实现类`org.apache.tomcat.util.net.NioChannel`对象中。
  + 然后将`NioChannel`对象封装在一个`PollerEvent`对象中，并将`PollerEvent`对象压入`events queue`里。

**这里是个典型的生产者-消费者模式，`Acceptor`与`Poller`线程之间通过`queue`通信，`Acceptor`是`events queue`的生产者，`Poller`是`events queue`的消费者。**

2. `Poller （单线程）`
  + `Poller`线程中维护了一个`Selector`对象，`NIO`就是基于`Selector`来完成逻辑的。
  + 在`connector`中并不止一个`Selector`，在`socket`的读写数据时，为了控制`timeout`也有一个`Selector`，在后面的`BlockSelector`中介绍。
  + 可以先把`Poller线程`中维护的这个`Selector`标为`主Selector`。 
  + `Poller`是`NIO`实现的主要线程。
    + 首先作为`events queue`的消费者，从`queue`中取出`PollerEvent`对象，然后将此对象中的`channel`以`OP_READ事件`注册到`主Selector`中，然后`主Selector`执行`select操作`，遍历出可以读数据的`socket`，并从`Worker线程池`中拿到可用的`Worker线程`，然后将`socket`传递给`Worker`。

(**整个过程是典型的NIO实现。**)

3. `Worker `
  + `Worker`线程拿到`Poller`传过来的`socket`后，将`socket`封装在`SocketProcessor`对象中。然后从`Http11ConnectionHandler`中取出`Http11NioProcessor`对象，从`Http11NioProcessor`中调用`CoyoteAdapter`的逻辑，跟BIO实现一样。
  + 在`Worker`线程中，会完成从`socket`中读取`http request`，解析成`HttpServletRequest`对象，分派到相应的`servlet`并完成逻辑，然后将`response`通过`socket`发回`client`。
  + 在从`socket`中读数据和往`socket`中写数据的过程，并没有像典型的非阻塞的NIO的那样，注册`OP_READ`或`OP_WRITE`事件到`主Selector`，而是直接通过socket完成读写，这时是阻塞完成的，但是在timeout控制上，使用了NIO的`Selector机制`，但是这个`Selector`并不是`Poller线程`维护的`主Selector`，而是`BlockPoller线程`中维护的`Selector`，称之为`辅Selector`。

## tomcat8的并发参数控制
本篇的tomcat版本是tomcat8.5。可以到这里看下tomcat8.5的配置参数

1. acceptCount 
 + 文档描述为：The maximum queue length for incoming connection requests when all possible request processing threads are in use. Any requests received when the queue is full will be refused. The default value is 100. 
 + 这里可以简单理解为：连接在被ServerSocketChannel accept之前就暂存在这个队列中，acceptCount就是这个队列的最大长度。
ServerSocketChannel accept就是从这个队列中不断取出已经建立连接的的请求。所以当ServerSocketChannel accept取出不及时就有可能造成该队列积压，一旦满了连接就被拒绝了;
2. acceptorThreadCount 
 + 文档如下描述 :The number of threads to be used to accept connections. Increase this value on a multi CPU machine, although you would never really need more than 2. Also, with a lot of non keep alive connections, you might want to increase this value as well. Default value is 1. 
 + Acceptor线程只负责从上述队列中取出已经建立连接的请求。在启动的时候使用一个ServerSocketChannel监听一个连接端口如8080，可以有多个Acceptor线程并发不断调用上述ServerSocketChannel的accept方法来获取新的连接。参数acceptorThreadCount其实使用的Acceptor线程的个数。
3. maxConnections 
 + 文档描述如下：The maximum number of connections that the server will accept and process at any given time. When this number has been reached, the server will accept, but not process, one further connection. 
 + This additional connection be blocked until the number of connections being processed falls below maxConnections at which point the server will start accepting and processing new connections again. Note that once the limit has been reached, the operating system may still accept connections based on the acceptCount setting. 
 + The default value varies by connector type. For NIO and NIO2 the default is 10000. For APR/native, the default is 8192. 
 + Note that for APR/native on Windows, the configured value will be reduced to the highest multiple of 1024 that is less than or equal to maxConnections. This is done for performance reasons. If set to a value of -1, the maxConnections feature is disabled and connections are not counted. 
 + 这里就是tomcat对于连接数的一个控制，即最大连接数限制。一旦发现当前连接数已经超过了一定的数量（NIO默认是10000），上述的Acceptor线程就被阻塞了，即不再执行ServerSocketChannel的accept方法从队列中获取已经建立的连接。但是它并不阻止新的连接的建立，新的连接的建立过程不是Acceptor控制的，Acceptor仅仅是从队列中获取新建立的连接。所以当连接数已经超过maxConnections后，仍然是可以建立新的连接的，存放在上述acceptCount大小的队列中，这个队列里面的连接没有被Acceptor获取，就处于连接建立了但是不被处理的状态。当连接数低于maxConnections之后，Acceptor线程就不再阻塞，继续调用ServerSocketChannel的accept方法从acceptCount大小的队列中继续获取新的连接，之后就开始处理这些新的连接的IO事件了。
4. maxThreads 
 + 文档描述如下：The maximum number of request processing threads to be created by this Connector, which therefore determines the maximum number of simultaneous requests that can be handled. If not specified, this attribute is set to 200. If an executor is associated with this connector, this attribute is ignored as the connector will execute tasks using the executor rather than an internal thread pool. 
 + 这个简单理解就算是上述worker的线程数。他们专门用于处理IO事件，默认是200。