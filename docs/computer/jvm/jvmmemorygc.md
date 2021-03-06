## Java堆内存??

>+ Java内存运行时内存区域的各个部分，其中**`程序计数器、虚拟机栈、本地方法栈`**三个区域随线程而生，随线程而灭；
+ **栈中的栈帧**随着方法的进入和退出而有条不紊地执行着出栈和入栈操作；
+ 每一个栈帧中分配多少内存基本上是在类结构确定下来时就已知的，因此这几个区域的内存分配和回收都具备确定性，在这几个区域内不需要过多考虑回收的问题，因为方法结束或线程结束时，内存自然就跟随着回收了。

>`Java堆`和`方法区`则不一样:
+ 一个接口中多个实现类需要的内存可能不一样;
+ 一个方法中的多个分支需要的内存也可能不一样;
+ 只有在程序处于运行期间时才能知道会创建那些对象，这部分内存的分配和回收都是动态，**垃圾收集器`GC`**所关注的是这部分内存；

### `GC`是如何判断对象是否可以被回收的呢?

对象内存区域回收，第一个面临的问题是**对象是否可用？**

为了判断对象是否存活,`JVM`引入了`GC Roots`.如果一个对象与`GC Roots`之间没有直接或间接的引用关系,比如某个失去任何引用的对象,或者两个互相环岛状循环引用的对象等;判决这些对象"死缓",是可以被回收的.

在Java中使用根搜索算法（`GC Roots Tracing`）判定对象是否存活的：
>通过一系列的名位`GC Roots`的对象作为起始点，从这些节点开始向下搜索，搜索所走过的路径称为`引用链（Reference Chain）`，当一个对象到`GC Roots`没有任何引用链相连时，则证明此对象是不可用的；

在Java语言里，可作为`GC Roots`的对象包括下面几种：
>1. 虚拟机栈（栈帧中的本地变量表）中的引用的对象；
2. 方法区中的类静态属性引用的对象；
3. 方法区中的常量引用的对象；
4. 本地方法栈中`JNI`（即一般说的`Native`方法）的引用的对象；

### 引用

判定对象是否存活都与“引用”有关；

在`JDK1.2`之前，Java中的引用的定义很传统：如果`reference类型`的数据中国存储的数值代表的是`另外一块内存的起始地址`，就称这块内存代表着一个引用；

在`JDK1.2`之后，Java对引用的概念进行了扩充，将引用分为`强引用（Strong reference）`、`软引用（Soft Reference）`、`弱引用（Weak Reference）`、`虚引用（Phantom Reference）`四种：
>1. 强引用：指在程序代码中普通存在的，类似`Object obj = new Object()`这类的引用，**只要强引用还存在，垃圾收集器永远不会回收掉被引用的对象**；
2. 软引用：用来描述一些还有用，但并非必需的对象。**对于软引用关联着的对象，在系统将要发生内存溢出异常之前，将会把这些对象列进回收范围之中并进行第二次回收。如果此次回收还是没有足够的内存，才会抛出内存溢出异常**。在JDK1.2之后，提供了`SoftReference类来实现软引用`；
3. 弱引用：用来描述非必须对象，强度比软引用更弱一些，**被弱引用关联的对象只能生存到下一次垃圾收集发生之前**；在JDK1.2之后，提供了`WeakReference`类来实现弱引用；
4. 虚引用：称为幽灵引用或者幻影引用，它是最弱的一种引用关系。**一个对象是否有虚引用的存在，完成不会对其生存时间构成影响，也无法通虚引用来取得一个对象实例**。***为一个对象设置虚引用关联的唯一目的就是希望能在这个对象被收集器回收时收到一个系统通知。***在JDK1.2之后，提供了`PhantomReference`类来实现虚引用；

在根搜索算法总不可达的对象，也并非是“非死不可”的，这时候它们暂时处于“缓刑”阶段，要真正宣告一个对象死亡，至少要经历两次标记过程：
>**如果对象在进行根搜索后发现没有与`GC Roots`相连接的引用链，那它将会被第一次标记并且进行一次筛选，筛选的条件是此对象是否有必要执行`finalize()`。当对象没有覆盖`finalize()`方法，或者`finalize()`已经被虚拟机调用过，虚拟机将这两种情况都视为“没有必要执行”**；

>+ 如果这个对象被判定有必要执行`finalize()`，那么这个对象将会被放置在一个名为`F-Queue`的队列之中，并在稍后由一条由虚拟机自动建立的、低优先级的`Finalizer`线程去执行(JVM会触发但不承诺会等待它运行结束)。
+ `finalize()`方法是对象逃脱死亡命运的最后一次机会，`GC`将对`F-Queue`中的对象进行第二次小规模的标记，如果对象要在`finalize()`中成功拯救自己，那在第二次标记时它将被移除出`即将回收`的集合；

## 垃圾收集算法

### 标记-清除算法

`标记-清除（Mark-Sweep）`算法，算法分为`标记`和`清除`两个阶段：

>**首先标记出所有需要回收的对象，在标记完成后统一回收掉所有被标记的对象；**

>其缺陷：
1. `效率问题`，标记和清除过程的效率都不高；
2. `空间问题`，标记清除之后会产生大量不连续的内存碎片；

### 标记-整理算法

该算法类似计算机的磁盘整理,首先会从`GC Roots`出发标记存活的对象,然后将存活对象整理到内存空间的一端,形成连续的已使用空间,最后把已使用空间之外的部分全部清理掉,这样就不会产生空间碎片的问题;

### 标记-复制算法

>**为了能够并行地`标记`和`整理`**;

将空间分为两块,每次只激活其中一块,垃圾回收时只需把存活的对象复制到另一块未激活空间上,将未激活空间标记为已激活,将已激活空间标记为未激活,然后清除原空间中的原对象.


## 垃圾收集器

收集算法是内存回收的方法论,垃圾收集器就是内存回收的具体实现.(**HotSpt虚拟机**)

垃圾回收器(`Garbage Collector`)是实现垃圾回收算法并应用在`JVM`环境中内存管理模块;

![gc](/images/gc.png)

### Serial收集器
Serial收集器一个**单线程的收集器**(`在进行垃圾收集时,必须暂停其他所有的工作线程("Stop The World"),直到它收集结束`);

>简单而高效(与其他收集器的单线程比),对于限定单个CPU的环境来说,Serial收集器由于没有线程交互的开销,专心做垃圾收集自然可以获得最高的单线程收集效率;


### `ParNew`收集器

`ParNew`收集器其实就是`Serial`收集器的多线程版本;

>除了使用多条线程进行垃圾收集之外,其余行为包括`Serial`收集器可用的所有控制参数(`-XX:SurvivorRatio、-XX:PretenureSizeThreshold、-XX:HandlePromtionFailure等`)、收集算法、`Stop The World`、对象分配规则、回收策略等都与`Serial`收集器完全一样。

### Parallel Scavenge收集器

`Parallel Scavenge`收集器也是一个**新生代收集器**，它使用复制算法的收集器，又是并行的多线程收集器。

`Parallel Scavenge`收集器的目标则是**达到一个可控制的吞吐量**。

**吞吐量：CPU用于运行用户代码的时间与CPU总消耗时间的比值，即吞吐量=运行用户代码时间/(运行用户代码时间+垃圾收集时间)**

>+ 停顿时间越短就越适合需要与用户交互的程序，良好的响应速度能提升用户的体验；
+ 而高吞吐量则可以最高效率地利用CPU时间，尽快地完成程序的运算任务，**主要适合在后台运算而不需要太多交互的任务**；

>`Parallel Scavenge`收集器提供了两个参数用于精确控制吞吐量:
+ 分别是控制最大垃圾收集停顿时间的`-XX:MaxGCPauseMillis`参数
+ 直接设置吞吐量大小的`-XX:GCTimeRatio`参数

(`Parallel Scavenge收集器`无法与`CMS收集器`配合工作)

### `Serial Old`收集器

`Serial Old`是Serial收集器的老年代版本，它同样是一个单线程收集器，使用`标记-整理`算法。

### `Parallel Old`收集器

`Parallel Old`是`Parallel Scavenge`收集器的老年代版本，使用多线程和`标记-整理`算法；

### `CMS`收集器

`CMS（concurrent Mark Sweep）`收集器是一种以获取最短回收停顿时间为目标的收集器。其基于`标记-清除`算法实现的：
>其运行过程分为四个阶段:
1. **`初始标记（CMS Inital mark）`**：初始标记仅仅只是标记一下GC Roots能直接关联到的对象，速度很快；
2. **`并发标记（CMS concurrent mark）`**： 并发标记阶段就是进行`GC Roots Tracing`的过程；
3. **`重新标记（CMS remark）`**：重新标记阶段则是为了修正并发标记期间，因用户继续运作而导致标记产生变动的那一部分对象的标记记录；
4. **`并发清除（CMS concurrent sweep）`**

>由于整个过程中耗时最长的`并发标记`和`并发清除`过程中，收集器线程都可以与用户线程一起工作，所以总体来说，**CMS收集器的内存回收过程是与用户线程一起并发地执行的**；

>+ 优点：**并发收集、低停顿**；
+ 缺点：
  + **CMS收集器对CPU资源非常敏感**。虽然不会导致用户线程停顿，但是会因为占用了一部分线程（或者说CPU资源）而导致应用程序变慢，总吞吐量会降低。
  + **CMS收集器无法处理浮动垃圾（Floating Garbage）**，由于CMS并发清理阶段用户线程还在运行着，伴随着程序的运行自然还会有新的垃圾不断产生，这部分垃圾出现在标记过程之后，CMS无法在本次收集中处理掉它们；

>**参数控制**：
  + `-XX:+UseConcMarkSweepGC` ： 使用`CMS`收集器
  + `-XX:+UseCMSCompactAtFullCollection` ：`Full GC`后，进行一次碎片整理；整理过程是独占的，会引起停顿时间变长
  + `-XX:+CMSFullGCsBeforeCompaction` ： 设置进行几次`Full GC`后，进行一次碎片整理
  + `-XX:ParallelCMSThreads` ： 设定`CMS的线程数量`（一般情况约等于可用CPU数量）

![cms](/images/cms.png)

### `G1`(Garbage First)
`G1`收集器：
* 是基于`标记-复制`算法实现的收集器。它不会产生空间碎片；
* 它可以非常精确地控制停顿，即能让使用者明确指定在一个长度为M毫秒的时间片段内，消耗在垃圾收集上的时间不得超过N毫秒，这几乎已经是`实时Java（RTSJ）`的垃圾收集器的特征了；

>和`CMS`相比,`G1`具备压缩功能,能避免碎片问题,`G1`的暂停时间更加可控;

>+ `G1`将`整个Java堆（包括新生代、老年代）`划分为`多个大小固定的独立区域（Region）`:
  + 包括`Eden`,`Survivor`,`Old`,`Humongous`四种类型;(**`Humongous`是特殊的Old类型,专门放置大型对象;**)
+ 并且跟踪这些区域里面的垃圾堆积程度，`在后台维护一个优先列表`，每次根据允许的`收集时间`，**优先回收垃圾最多的区域（Garbage First名称来由）**；

![G1](/images/G1.png)

>**G1的新生代收集跟ParNew类似，当新生代占用达到一定比例的时候，开始出发收集。和`CMS`类似，`G1`收集器收集老年代对象会有短暂停顿。**
1. **标记阶段**，首先初始标记(`Initial-Mark`),这个阶段是停顿的(`Stop the World Event`)，并且会触发一次普通`Minor GC`.
  + 对应`GC log:GC pause (young) (inital-mark)`
2. **Root Region Scanning**，程序运行过程中会回收`survivor`区(存活到老年代)，这一过程必须在`young GC`之前完成。
3. **Concurrent Marking**，在整个堆中进行并发标记(和应用程序并发执行)，此过程可能被`young GC`中断。
  + 在并发标记阶段，**若发现区域对象中的所有对象都是垃圾，那个这个区域会被立即回收(图中打X)**。
  + 同时，**并发标记过程中，会计算每个区域的对象活性(区域中存活对象的比例)**。
![Concurrent_Marking](/images/Concurrent_Marking.png)
4. **Remark, 再标记**：会有短暂停顿(STW)。
  + 再标记阶段是用来收集 并发标记阶段 产生新的垃圾(并发阶段和应用程序一同运行)；
  + **`G1`中采用了比`CMS`更快的初始快照算法:snapshot-at-the-beginning (SATB)**。
5. **Copy/Clean up**：多线程清除失活对象，会有`STW`。
  + **`G1`将回收区域的存活对象拷贝到新区域，清除`Remember Sets`，并发清空回收区域并把它返回到空闲区域链表中**。
![Cleanup](/images/Cleanup.png)
6. **复制/清除过程后**：回收区域的活性对象已经被集中回收到深蓝色和深绿色区域。
![Cleanup_after](/images/Cleanup_after.png)


## 内存分配与回收策略

### 对象优先在`Eden`分配

>大多数情况下，对象在新生代Eden区中分配。当Eden区没有噢足够的空间进行分配时，JVM将发起一次`Minor GC`；
(JVM提供了`-XX:+PrintGCDetails`这个收集器日志参数，告诉JVM在发生垃圾收集行为时打印内存回收日志，并且在进程退出的时候输出当前内存各区域的分配情况。)

### 大对象直接进入老年代

>大对象：需要大量连续内存空间的Java对象，最典型的大对象是那种很长的字符串及数组
（JVM提供了`-XX:PretenureSizeThreshold`参数，令大于这个设置值的对象直接在老年代中分配。
这样做的目的是避免在`Eden区`及两个`Survivor区`之间发生大量的内存Copy）

### 长期存活的对象将进入老年代

JVM采用了分代收集的思想来管理内存,那内存回收时就必须能识别那些对象应当放在新生代,那些对象应放在新生代,那些对象应放在老年代中;

>JVM给每个对象定义了一个对象年龄计数器.如果对象在`Eden`出生并经过第一次`Minor GC`后仍然存活,并且能被`Survivor`容纳的话,将被移动到`Survivor`空间中,并将对象年龄设为1;对象在`Survivor`区中每熬过一次`Minor GC`,年龄就增加1岁,当它的年龄增加加到一定程度(`默认为15岁`)时,就会被晋升到`老年代`中;

**(对象晋升老年代的年龄阈值,可以通过参数`-XX:MaxTenuringThreshold`)**

## 虚拟机性能监控与故障处理工具

>**工作中需要监控运行于`JDK1.5`的虚拟机之上的程序，在程序启动时需要添加`-Dcom.sun.management.jmxremote`开启JMX管理功能；**

### Sun JDK监控和故障处理工具

名称|主要作用|
--|--|
`jps`|JVM Process Status Tool，显示指定系统内所有的HotSpot虚拟机进程|
`jstat`|JVM Statistics Monitoring Tool，用于收集HotSpot虚拟机各方面的运行数据|
`jinfo`|Configuration Info for Java，显示虚拟机配置信息|
`jmap`|Memory Map for Java，生成虚拟机的内存转储快照（`heapdump`文件）|
`jhat`|JVM Heap Dump Browser，用于分析heapdump文件，它会建立一个HTTP/HTML服务器，让用户可以在浏览器上查看分析结果|
`jstack`|Stack Trace for Java，显式虚拟机的线程快照|


>**jps：可以列出正在运行的虚拟机进程，并显示虚拟机执行主类函数所在的名称，以及这些进行本地虚拟机的唯一ID**。
>1. `-q` 只输出LVMID，省略主类名称
2. `-m` 输出虚拟机进程启动时传递给主类main()函数的参数
3. `-l` 输出主类的全名，如果进程执行的是Jar包，输出Jar路径
4. `-v` 输出虚拟机进程启动时JVM参数

>**jstat：用于监视虚拟机各种运行状态信息的命令行工具，可以显示本地或远程虚拟机进程中类装载、内存、垃圾收集、JIT编译等运行数据；**
  >1. `-class` 监视类装载、卸载数量、总空间及类装载所耗费的时间；
   2. `-gc` 监视Java堆状况，包括Eden区，2个Survivor区、老年代、永久代等的容量、已用空间、GC时间合计等信息；
   3. ......

>**jinfo：实时地查看和调整虚拟机的各项参数**
  >1. -flag

>**jmap：用于生成堆转储快照文件**
  >-dump:[live,]format=b,file=<filename> 生成Java堆转储快照

>**jhat：虚拟机堆转储快照分析工具**

>**jstack：用于生成虚拟机当前时刻的线程快照，线程快照就是当前虚拟机内存每一条线程正在执行的方法堆栈的集合；**

### GC优化的目的

>+ 将转移到老年代的对象数量降低到最小；
+ 减少full GC的执行时间；

>为了达到上面的目的，一般地，你需要做的事情有：
+ 减少使用全局变量和大对象；
+ 调整新生代的大小到最合适；
+ 设置老年代的大小为最合适；
+ 选择合适的GC收集器；

## 问题

**“你能不能谈谈，java GC是在什么时候，对什么东西，做了什么事情？”**

>在什么时候：
1. 新生代有一个`Eden区`和`两个survivor区`，首先将对象放入`Eden区`，如果空间不足就向其中的一个`survivor区`上放，如果仍然放不下就会引发一次发生在`新生代的minor GC`，将存活的对象放入另一个`survivor区`中，然后清空Eden和之前的那个`survivor区`的内存。在某次GC过程中，如果发现仍然又放不下的对象，就将这些对象放入老年代内存里去。
2. 大对象以及长期存活的对象直接进入老年区。
3. 当每次执行`minor GC`的时候应该对要晋升到老年代的对象进行分析，如果这些马上要到老年区的老年对象的大小超过了老年区的剩余大小，那么执行一次Full GC以尽可能地获得老年区的空间。

>对什么东西：
+ 从`GC Roots`搜索不到，而且经过一次标记清理之后仍没有复活的对象。

>做什么：
1. 新生代：复制清理；
2. 老年代：标记-清除和标记-压缩算法；
3. 永久代：存放`Java`中的类和加载类的类加载器本身。


**GC Roots都有哪些：**
>1. 虚拟机栈中的引用的对象
2. 方法区中静态属性引用的对象，常量引用的对象
3. 本地方法栈中`JNI`（即一般说的`Native方法`）引用的对象。