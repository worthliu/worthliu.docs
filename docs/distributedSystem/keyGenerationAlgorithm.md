分布式主键的生成方式分为`中心化`和`去中心化`两大类。

## 中心化生成算法

中心化生成算法经典的方案主要有`基于SEQUENCE区间方案`、`各数据库按特定步长自增`和`基于redis生成自增序列`三种;

### `SEQUENCE`区间方案

淘宝分布式数据层`TDDL`就是采用`SEQUENCE`方案实现了分库分表、`Master/Salve`、动态数据源配置等功能。

大致原理是：所有应用服务器去同一个库获取可使用的`sequence`（乐观锁保证一致性），得到`(sequence，sequence+步长]`个可被这个数据源使用的`id`，当应用服务器插入超过"步长"个数据后，需要再次去争取新的`sequence`区间。

>+ 优势：生成一个`全局唯一的连续数字类型主键，延用单库单表时的主键id`。
+ 劣势：无法保证全局递增
  + 需要开发各种数据库类型id生成器;
  + 扩容历史数据不好迁移;

操作步骤如下：
第一步：创建一张sequence对应的表。记录每一个表的当前最大`sequence`，几张逻辑表需要声明几个`sequence`；
第二步：配置`sequenceDao`，定义步长等信息

### 各数据库按特定步长自增

可以继续采用**数据库生成自增主键的方式，为每个不同的分库设置不同的初始值，并按步长设置为分片的个数即可**，这种方式对分片个数有依赖，一旦再次水平扩展，原有的分布式主键不易迁移。

为了预防后续库表扩容，这边可以采用提前约定最大支持的库表数量，后续`扩容为2的指数倍扩容`。

比如：我们规定最大支持`1024`张分表，数据库增长的步长为`1024`（即使现在的表数量只有`64`）。

>+ 优势：生成一个全局唯一的数字类型主键，延用单库单表时的主键id。
  + 当分表数没有达到约定的`1024`张分表，全局不连续。
+ 劣势：无法保证全局递增，也不保证单机连续。
  + 需要开发各种`数据库类型id生成器`。
  + 需要依赖一个中心库表`sequence`。

### 基于redis的方案

另一种中心化生成分布式主键的方式是**采用Redis在内存中生成自增序列**，通过`redis的原子自增操作(incr接口)`生成一个自增的序列。

>+ 优势：生成一个`全局连续递增`的数字类型主键。
+ 劣势：此种方式新增加了一个外部组件的依赖，一旦`Redis`不可用，则整个数据库将无法在插入，可用性会大大下降，另外`Redis的单点问题`也需要解决，部署复杂度较高。


## 去中心化生成算法

去中心化方式无需额外部署，以jar包方式被加载，可扩展性也很好，因此更推荐使用。

目前主流的去中心化生成算法有：`UUID及其变种`、`Mongo的ObjectId`、`snowflake算法及其变种`;

### `UUID及其变种`
`UUID`是通用唯一识别码（`Universally Unique Identifier`）的缩写，是一种软件建构的标准，亦为开放软件基金会组织在分布式计算环境领域的一部分。

其目的，是让分布式系统中的所有元素，都能有唯一的辨识信息，而不需要通过中央控制端来做辨识信息的指定。

**`UUID`有很多变种实现，目前最广泛应用的`UUID`，是微软公司的全局唯一标识符（GUID）。**

>**`UUID`是一个由`4个连字号(-)`将`32个字节长的字符串`分隔后生成的字符串，总共36个字节长。**

算法的核心思想是结合机器的网卡、当地时间、一个随即数来生成`GUID`。

**从理论上讲，如果一台机器每秒产生`10000000个GUID`，则可以保证（概率意义上）`3240`年不重复。**

>+ 优势：全局唯一，各种语言都有`UUID`现成实现，Mysql也有`UUID`实现。
+ 劣势：`36`个字符组成;
  + 按照目前Mysql最常用的编码`Utf-8`，每一个字符对应的索引成本是3字节，也就是一个`UUID`需要108个字节的索引存储成本，是最大数字类型（8字节）的`13.5`倍的存储成本。

## `mongodb的ObjectId`

**objectid有12个字节，包含时间信息（4字节、秒为单位）、机器标识（3字节）、进程id（2字节）、计数器（3字节，初始值随机）。**

其中，**时间位精度（秒或者毫秒）与序列位数**，二者决定了单位时间内，对于同一个进程最多可产生多少唯一的ObjectId，在MongoDB中，那每秒就是`2^24（16777216）`。

**但是机器标识与进程id一定要保证是不重复的，否则极大概率上会产生重复的ObjectId。**

由于`ObjectId`生成`12个字节的16进制`表示，无法用现有基础类型存储，只能转化为字符串存储，对应`24个字符`。

objectid的组成结构如下:

```ObjectId
public class ObjectId implements Comparable<ObjectId> , java.io.Serializable {
	final int _time;
	final int _machine;
	final int _inc;
	boolean _new;

	public ObjectId(){
	        _time = (int) (System.currentTimeMillis() / 1000);
	        _machine = _genmachine;
	        _inc = _nextInc.getAndIncrement();
	        _new = true;
	}
	……
}
```

>+ 优势： 全局唯一 。
+ 劣势：非数字类型，24个字符;
  + 按照目前Mysql最常用的编码`Utf-8`，每一个字符对应的索引成本是3字节，也就是一个ObjectId需要72个字节的索引存储成本，**是最大数字类型（8字节）的9倍的存储成本**。

### `snowflake算法`

`Snowflake`算法产生是为了满足`Twitter`每秒上万条消息的请求，每条消息都必须分配一条唯一的id，这些id还需要一些大致的顺序（方便客户端排序），并且在分布式系统中不同机器产生的id必须不同。

>**Snowflake算法把时间戳，工作机器id，序列号组合在一起。**

生产Id的结构如下：

```
  63	       62-22	               21-12      11-0
1位：2	41位：支持69.7年（单位ms）	10位：1024	12位：4096
```

![snowFlake](/images/snowFlake.png)

默认情况下`41bit`的时间戳可以支持该算法使用到`2082`年，`10bit`的工作机器id可以支持`1023`台机器，序列号支持1毫秒产生`4095`个自增序列id。

**工作机器id可以使用`IP+Path`来区分工作进程。**

如果工作机器比较少，可以使用配置文件来设置这个id是一个不错的选择，如果机器过多配置文件的维护是一个灾难性的事情。

实施现状：工作机器id有10位，根据公司目前已经未来5-10的业务量，同一个服务机器数超过1024台基本上不太可能。

工作机器id推荐使用下面的结构来避免可能的重复。

```
9-8	7-0
用户可指定（默认为0）	机器ip的后8位
```

考虑到公司的业务级别，同一个机房ip的后8位基本上不可能重复。

>后2位让用户指定是由于存在以下场景：
+ 一个虚拟机下面可能存在两个进程号不同的同样服务（我们不建议，后续也希望通过运维来避免类似的部署）。
  + 如果存在这种情况，可以在JVM启动参数中添加`HostId`参数，为这个这台机器的服务指定一个不同于其他服务的`HostId`。
+ 存在前后台服务部署在同一台机器上，都操作同一个库（建议后台服务通过调用前台的服务来操作库表，保证库表的单一操作）。
  + 如果存在这种情况，可以通过为前后台服务指定不同的服务编号`serviceNo`（只支持0，1，2，3）。
+ 不同机房可能存在相同后8位ip尾号。
  + 如果存在这种情况，可以通过在其中一台机器的环境变量中重新指定一下`HostId；b`）不同环境配置不同的服务编号`serviceNo；c`）服务启动JVM参数中为这个这台机器的服务指定一个不同于其他服务的`HostId`

```
/** Copyright 2010-2012 Twitter, Inc.*/
package com.twitter.service.snowflake

import com.twitter.ostrich.stats.Stats
import com.twitter.service.snowflake.gen._
import java.util.Random
import com.twitter.logging.Logger

/**
 * An object that generates IDs.
 * This is broken into a separate class in case
 * we ever want to support multiple worker threads
 * per process
 */
class IdWorker(
    val workerId: Long, 
    val datacenterId: Long, 
    private val reporter: Reporter, 
    var sequence: Long = 0L) extends Snowflake.Iface {
    
  private[this] def genCounter(agent: String) = {
    Stats.incr("ids_generated")
    Stats.incr("ids_generated_%s".format(agent))
  }
  private[this] val exceptionCounter = Stats.getCounter("exceptions")
  private[this] val log = Logger.get
  private[this] val rand = new Random

  val twepoch = 1288834974657L

  private[this] val workerIdBits = 5L
  private[this] val datacenterIdBits = 5L
  private[this] val maxWorkerId = -1L ^ (-1L << workerIdBits)
  private[this] val maxDatacenterId = -1L ^ (-1L << datacenterIdBits)
  private[this] val sequenceBits = 12L

  private[this] val workerIdShift = sequenceBits
  private[this] val datacenterIdShift = sequenceBits + workerIdBits
  private[this] val timestampLeftShift = sequenceBits + workerIdBits + datacenterIdBits
  private[this] val sequenceMask = -1L ^ (-1L << sequenceBits)

  private[this] var lastTimestamp = -1L

  // sanity check for workerId
  if (workerId > maxWorkerId || workerId < 0) {
    exceptionCounter.incr(1)
    throw new IllegalArgumentException("worker Id can't be greater than %d or less than 0".format(maxWorkerId))
  }

  if (datacenterId > maxDatacenterId || datacenterId < 0) {
    exceptionCounter.incr(1)
    throw new IllegalArgumentException("datacenter Id can't be greater than %d or less than 0".format(maxDatacenterId))
  }

  log.info("worker starting. timestamp left shift %d, datacenter id bits %d, worker id bits %d, sequence bits %d, workerid %d",
    timestampLeftShift, datacenterIdBits, workerIdBits, sequenceBits, workerId)

  def get_id(useragent: String): Long = {
    if (!validUseragent(useragent)) {
      exceptionCounter.incr(1)
      throw new InvalidUserAgentError
    }

    val id = nextId()
    genCounter(useragent)

    reporter.report(new AuditLogEntry(id, useragent, rand.nextLong))
    id
  }

  def get_worker_id(): Long = workerId
  def get_datacenter_id(): Long = datacenterId
  def get_timestamp() = System.currentTimeMillis

  protected[snowflake] def nextId(): Long = synchronized {
    var timestamp = timeGen()

    if (timestamp < lastTimestamp) {
      exceptionCounter.incr(1)
      log.error("clock is moving backwards.  Rejecting requests until %d.", lastTimestamp);
      throw new InvalidSystemClock("Clock moved backwards.  Refusing to generate id for %d milliseconds".format(
        lastTimestamp - timestamp))
    }

    if (lastTimestamp == timestamp) {
      sequence = (sequence + 1) & sequenceMask
      if (sequence == 0) {
        timestamp = tilNextMillis(lastTimestamp)
      }
    } else {
      sequence = 0
    }

    lastTimestamp = timestamp
    ((timestamp - twepoch) << timestampLeftShift) |
      (datacenterId << datacenterIdShift) |
      (workerId << workerIdShift) | 
      sequence
  }

  protected def tilNextMillis(lastTimestamp: Long): Long = {
    var timestamp = timeGen()
    while (timestamp <= lastTimestamp) {
      timestamp = timeGen()
    }
    timestamp
  }

  protected def timeGen(): Long = System.currentTimeMillis()

  val AgentParser = """([a-zA-Z][a-zA-Z\-0-9]*)""".r

  def validUseragent(useragent: String): Boolean = useragent match {
    case AgentParser(_) => true
    case _ => false
  }
}
```

### 变种`snowflake`算法
变种的snowflake算法。这个算法更加充分利用了ID的位表达，比原生的snowflake算法多出1位使用。

产生的ID结构如下：

```
63-62	61-52	51-20	19-0
2位：4	10位：1024	32位：136年（单位为s）	19位：1048560
保留位	  机器码	      时间戳	                  自增码
```

>+ 时间戳生成： 32位时间戳代表秒的话，可以表示136年，比如我们取2016年11月11日0点0分0秒作为基准，32位时间表示当前时间转换秒数-基准时间转换秒数
+ 自增码：服务数据源,原子自增的long类型变量，最大支持每秒1048560条记录，当一秒产生超过1048560个序号时，再次请求生成序号时，会阻塞等待下一秒到达才生成新的序号。
  + 为了避免自增码都是0开始计数导致数据倾斜，自增码的起始值被设定成一个随机数。
+ 机器码：可以参考上面描述的方案

### 带偏移的`snowflake`算法

什么是带偏移的`snowflake`算法？

指的是某个变量的后多少位和另一个字段的后多少位有相同的二进制，从而这两个变量具有相同的偏移。

也就是一个变量的生成依赖另一个字段，两者具有相同的偏移量。我们也可以用槽位来理解，就是具有相同位偏移，从而保证取模运算之后这两个变量会被分到同一个槽中。

举个栗子，当订单数量非常大时，需要对订单表做分库分表，查询维度分为患者维度（对应买家维度）和医生维度（对应卖家维度）。

患者就诊表以及医生接单表的数量和订单表的数量是一样的。
同理也需要对患者就诊表以及医生接单表进行分库分表。这样就存在3个分库分表。

通过偏移绑定，让订单的生成id的后多少位（比如后10位）和用户id的后多少位（比如后10位）具有相同的偏移。也就是订单生成部分依赖患者id。

这样通过订单id或者患者id进行取模运算（mod 1024）都能定位到同一个分库分表（槽），这样患者就诊表和订单表就是同一个表，从而将3个分库分表减少为2个分库分表。

以最大支撑分库分表数量为1024，这样我们后10位用于偏移。

带偏移的snowflake算法产生的ID结构如下：
```
64-63	62-53	52-24	23-10	9-0
1位：符号位	10位：1024	29位：17年	14位：16384	10位：1024个slot
保留位	机器码	时间戳	自增码	偏移位（槽位）
```

这样生成的id能够支撑17年；最大支持1024台应用机器同时生产数据；最大支持同一个用户每秒产生16384条记录。