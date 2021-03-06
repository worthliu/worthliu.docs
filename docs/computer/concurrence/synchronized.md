## 锁的`释放-获取`建立的`happens-before`关系

锁是java并发编程中最重要的同步机制，锁除了让临界区互斥执行外，还可以让释放锁的线程向获取同一个锁的线程发送消息；

### 锁释放和获取的内存语义

>* 当线程释放锁时，JMM会把该线程对应的本地内存中的共享变量刷新到主内存中。
* 当线程获取锁时，JMM会把该线程对应的本地内存置为无效。从而使得被监视器保护的临界区必须要从主内存中去读取共享变量。

***（对比锁释放-获取的内存语义与volatile写-读的内存语义，两者具有相同的内存语义）***

### `synchronized`

`synchronized`关键字简洁、清晰、语义明确，其应用层的语义是可以把任何一个非`null`对象作为"锁".

>+ 当`synchronized`作用在`方法`上时，锁住的便是`对象实例（this）`；
+ 当`synchronized`作用在`静态方法`时锁住的便是`对象对应的Class实例`，因为`Class`数据存在于`永久带`(`JDK8`后为元数据区)，因此静态方法锁相当于该类的一个`全局锁`；
+ 当`synchronized`作用于某一个对象实例时，锁住的便是对应的`代码块`;

在`HotSpot JVM`实现中，锁有个专门的名字：`对象监视器`。

#### `synchronized`底层语义

>Java虚拟机中的同步(Synchronization)`基于进入和退出管程(Monitor)对象实现`，无论是显式同步(有明确的`monitorenter` 和 `monitorexit` 指令,即`同步代码块`)还是隐式同步(`ACC_SYNCHRONIZED标志`)都是如此。

>在 Java 语言中，同步用的最多的地方可能是被`synchronized`修饰的同步方法。
+ 同步方法并不是由`monitorenter`和`monitorexit`指令来实现同步的;
+ 而是由方法调用指令读取运行时常量池中方法的`ACC_SYNCHRONIZED`标志来隐式实现的;


#### 理解`Java对象头`与`Monitor`关系

在JVM中，对象在内存中的布局分为三块区域：**对象头、实例数据和对齐填充**

+ `实例变量`：存放类的属性数据信息，包括父类的属性信息，如果是数组的实例部分还包括数组的长度，这部分内存按`4字节`对齐;
+ `填充数据`：由于虚拟机要求对象起始地址必须是8字节的整数倍。填充数据不是必须存在的，仅仅是为了字节对齐，这点了解即可;
+ `Java头对象`:其主要结构是由`Mark Word`和`Class Metadata Address`组成;

**Java头对象，它实现`synchronized`的锁对象的基础，一般而言,`synchronized`使用的锁对象是存储在Java对象头里的，jvm中采用2个字来存储对象头(如果对象是数组则会分配3个字，多出来的1个字记录的是数组长度)**

虚拟机位数|头对象结构|说明|
--|--|--|
`32/64bit`|`Mark Word`|存储对象的hashCode、锁信息或分代年龄或GC标志等信息|
`32/64bit`|`Class Metadata Address`|类型指针指向对象的类元数据，JVM通过这个指针确定该对象是哪个类的实例|

其中`Mark Word`在默认情况下存储着对象的HashCode、分代年龄、锁标记位等以下是32位JVM的`Mark Word`默认存储结构

锁状态|`25bit`|`4bit`|`1bit是否是偏向锁`|`2bit锁标志位`|
--|--|--|--|--|
无锁状态|对象HashCode|对象分代年龄|`0`|`01`|

由于对象头的信息是与对象自身定义的数据没有关系的额外存储成本，因此考虑到JVM的空间效率，`Mark Word `被设计成为一个非固定的数据结构，以便存储更多有效的数据，它会根据对象本身的状态复用自己的存储空间，如32位JVM下，除了上述列出的`Mark Word`默认存储结构外，还有如下可能变化的结构：

<table align="center" border="0" cellpadding="0" cellspacing="0" width="550" style="border-collapse:collapse;table-layout:fixed;width:400pt;align-content: center;">
 <colgroup>
  <col width="69" style="mso-width-source:userset;mso-width-alt:2446;width:52pt">
  <col width="64" style="width:48pt">
  <col width="47" style="mso-width-source:userset;mso-width-alt:1678;width:35pt">
  <col width="100" span="2" style="mso-width-source:userset;mso-width-alt:3555;width:75pt">
  <col width="69" style="mso-width-source:userset;mso-width-alt:2446;width:52pt">
 </colgroup>
 <tbody>
  <tr height="19" style="height:14.4pt">
   <td rowspan="2" height="38" class="xl65" width="69" style="height:28.8pt;width:52pt">锁状态</td>
   <td colspan="2" class="xl65" width="111" style="width:83pt">25bit</td>
   <td rowspan="2" class="xl65" width="100" style="width:75pt">4bit</td>
   <td class="xl65" width="100" style="width:75pt">1bit</td>
   <td class="xl65" width="69" style="width:52pt">2bit</td>
  </tr>
  <tr height="19" style="height:14.4pt">
   <td height="19" class="xl65" style="height:14.4pt">23bit</td>
   <td class="xl65">2bit</td>
   <td class="xl65">是否是偏向锁</td>
   <td class="xl65">锁标志位</td>
  </tr>
  <tr height="19" style="height:14.4pt">
   <td height="19" class="xl65" style="height:14.4pt">轻量级锁</td>
   <td colspan="4" class="xl65">指向栈中锁记录的指针</td>
   <td class="xl66">00</td>
  </tr>
  <tr height="19" style="height:14.4pt">
   <td height="19" class="xl65" style="height:14.4pt">重量级锁</td>
   <td colspan="4" class="xl65">指向互斥量(重量级锁)指针</td>
   <td class="xl66">10</td>
  </tr>
  <tr height="19" style="height:14.4pt">
   <td height="19" class="xl65" style="height:14.4pt">GC标记</td>
   <td colspan="4" class="xl65">空</td>
   <td class="xl66">11</td>
  </tr>
  <tr height="19" style="height:14.4pt">
   <td height="19" class="xl65" style="height:14.4pt">偏向锁</td>
   <td class="xl65">线程ID</td>
   <td class="xl65">Epoch</td>
   <td class="xl65">对象分代年龄</td>
   <td class="xl65">1</td>
   <td class="xl66">01</td>
  </tr>
 <!--[if supportMisalignedColumns]-->
 <tr height="0" style="display:none">
  <td width="69" style="width:52pt"></td>
  <td width="64" style="width:48pt"></td>
  <td width="47" style="width:35pt"></td>
  <td width="100" style="width:75pt"></td>
  <td width="100" style="width:75pt"></td>
  <td width="69" style="width:52pt"></td>
 </tr>
 <!--[endif]-->
</tbody>
</table>

其中轻量级锁和偏向锁是`Java 6`对`synchronized`锁进行优化后新增加的;

重量级锁也就是通常说`synchronized`的对象锁，锁标识位为`10`，其中指针指向的是`monitor`对象（也称为管程或监视器锁）的起始地址。每个对象都存在着一个`monitor`与之关联，对象与其`monitor`之间的关系有存在多种实现方式，如monitor可以与对象一起创建销毁或当线程试图获取对象锁时自动生成，但当一个`monitor`被某个线程持有后，它便处于锁定状态。

在Java虚拟机(HotSpot)中，`monitor`是由`ObjectMonitor`实现的，其主要数据结构如下（位于HotSpot虚拟机源码`ObjectMonitor.hpp`文件，C++实现的）

```
ObjectMonitor() {
    _header       = NULL;
    _count        = 0; //记录个数
    _waiters      = 0,
    _recursions   = 0;
    _object       = NULL;
    _owner        = NULL;
    _WaitSet      = NULL; //处于wait状态的线程，会被加入到该队列
    _WaitSetLock  = 0 ;
    _Responsible  = NULL ;
    _succ         = NULL ;
    _cxq          = NULL ;
    FreeNext      = NULL ;
    _EntryList    = NULL ; //处于等待锁block状态的线程，会被加入到该队列(阻塞状态)
    _SpinFreq     = 0 ;
    _SpinClock    = 0 ;
    OwnerIsThread = 0 ;
  }
```

>+ `ObjectMonitor`中有两个队列，`_WaitSet`和`_EntryList`，用来保存`ObjectWaiter`对象列表(每个等待锁的线程都会被封装成`ObjectWaiter`对象);
+ **`_owner`指向持有`ObjectMonitor`对象的线程;**


>当多个线程同时访问一段同步代码时:
+ 首先会进入`_EntryList`集合;
+ 当线程获取到对象的`monitor`后,进入`_Owner`区域并把`monitor`中的`owner`变量设置为当前线程,同时`monitor`中的`计数器count`加1;
+ 若线程调用`wait()` 方法，将释放当前持有的`monitor`，`owner`变量恢复为`null`，`count`自减1，同时该线程进入`WaitSet`集合中等待被唤醒。
+ 若当前线程执行完毕也将释放`monitor(锁)`并复位变量的值，以便其他线程进入获取`monitor(锁)`。


#### `synchronized`代码块底层原理

`synchronized`修饰代码块时,JDK编译字节码时会在代码块前后增加`monitorenter`和`monitorexit`指令:

```
3: monitorenter  //进入同步方法
//..........省略其他  
15: monitorexit   //退出同步方法
16: goto          24
//省略其他.......
21: monitorexit //退出同步方法
```

**从字节码中可知同步语句块的实现使用的是`monitorenter`和`monitorexit`指令;其中`monitorenter`指令指向同步代码块的开始位置，`monitorexit`指令则指明同步代码块的结束位置;**

+ 当执行`monitorenter`指令时，当前线程将试图获取`objectref(即对象锁)`所对应的`monitor`的持有权;
+ 当`objectref`的`monitor`的进入计数器为`0`，那线程可以成功取得`monitor`，并将计数器值设置为`1`，取锁成功。
+ 如果当前线程已经拥有`objectref`的`monitor`的持有权，那它可以重入这个`monitor`，重入时计数器的值也会加`1`。
+ 倘若其他线程已经拥有`objectref`的`monitor`的所有权，那当前线程将被阻塞，直到正在执行线程执行完毕，即`monitorexit`指令被执行，执行线程将释放`monitor(锁)`并设置计数器值为`0` ，其他线程将有机会持有`monitor`。

**值得注意的是编译器将会确保无论方法通过何种方式完成，方法中调用过的每条`monitorenter`指令都有执行其对应`monitorexit`指令，而无论这个方法是正常结束还是异常结束。**

为了保证在方法异常完成时`monitorenter`和`monitorexit`指令依然可以正确配对执行，编译器会自动产生一个异常处理器，这个异常处理器声明可处理所有的异常，它的目的就是用来执行`monitorexit`指令。

从字节码中也可以看出多了一个`monitorexit`指令，它就是异常结束时被执行的释放`monitor`的指令。


#### synchronized方法底层原理

**方法级的同步是隐式，即无需通过字节码指令来控制的，它实现在方法调用和返回操作之中。**

JVM可以从**方法常量池**中的**方法表结构(method_info Structure)**中的`ACC_SYNCHRONIZED`访问标志区分一个方法是否同步方法。

>+ 当方法调用时，调用指令将会检查方法的`ACC_SYNCHRONIZED`访问标志是否被设置;
+ 如果设置了，执行线程将先持有`monitor`（虚拟机规范中用的是管程一词）， 然后再执行方法，最后再方法完成(无论是正常完成还是非正常完成)时释放`monitor`。
+ 在方法执行期间，执行线程持有了`monitor`，其他任何线程都无法再获得同一个`monitor`。
+ 如果一个同步方法执行期间抛 出了异常，并且在方法内部无法处理此异常，那这个同步方法所持有的monitor将在异常抛到同步方法之外时自动释放;

```
//==================syncTask方法======================
  public synchronized void syncTask();
    descriptor: ()V
    //方法标识ACC_PUBLIC代表public修饰，ACC_SYNCHRONIZED指明该方法为同步方法
    flags: ACC_PUBLIC, ACC_SYNCHRONIZED
    Code:
      stack=3, locals=1, args_size=1
         0: aload_0
         1: dup
         2: getfield      #2                  // Field i:I
         5: iconst_1
         6: iadd
         7: putfield      #2                  // Field i:I
        10: return
      LineNumberTable:
        line 12: 0
        line 13: 10
}
```
从字节码中可以看出，`synchronized`修饰的方法并没有`monitorenter`指令和`monitorexit`指令，取得代之的确实是`ACC_SYNCHRONIZED`标识，该标识指明了该方法是一个同步方法，JVM通过该`ACC_SYNCHRONIZED`访问标志来辨别一个方法是否声明为同步方法，从而执行相应的同步调用。


>**在Java早期版本中，`synchronized`属于重量级锁，效率低下，因为监视器锁（`monitor`）是依赖于底层的操作系统的`Mutex Lock`来实现的，而操作系统实现线程之间的切换时需要从用户态转换到核心态，这个状态之间的转换需要相对比较长的时间，时间成本相对较高，这也是为什么早期的`synchronized`效率低的原因。**


### Java虚拟机对`synchronized`的优化

>+ 锁的状态总共有四种，`无锁状态`、`偏向锁`、`轻量级锁`和`重量级锁`。
+ 随着锁的竞争，锁可以从偏向锁升级到轻量级锁，再升级的重量级锁，但是锁的升级是单向的，也就是说只能从低到高升级，不会出现锁的降级;

#### 偏向锁
偏向锁是Java 6之后加入的新锁，它是一种针对加锁操作的优化手段;

经过研究发现，在大多数情况下，锁不仅不存在多线程竞争，而且总是由同一线程多次获得，因此为了减少同一线程获取锁(会涉及到一些CAS操作,耗时)的代价而引入偏向锁。

>偏向锁的核心思想是，如果一个线程获得了锁，那么锁就进入偏向模式，此时`Mark Word`的结构也变为偏向锁结构，当这个线程再次请求锁时，无需再做任何同步操作，即获取锁的过程，这样就省去了大量有关锁申请的操作，从而也就提供程序的性能。

**对于没有锁竞争的场合**，偏向锁有很好的优化效果，毕竟极有可能连续多次是同一个线程申请相同的锁。但是对于**锁竞争比较激烈的场合**，偏向锁就失效了，因为这样场合极有可能每次申请锁的线程都是不相同的，因此这种场合下不应该使用偏向锁;

#### 轻量级锁

倘若偏向锁失败，虚拟机将偏向锁升级为轻量锁,此时`Mark Word`的结构也变为轻量级锁的结构。

轻量级锁能够提升程序性能的依据是**`“对绝大部分的锁，在整个同步周期内都不存在竞争”`，来源于经验数据**。

>**轻量级锁所适应的场景是`线程交替执行同步块的场合`;**
>**如果存在同一时间访问同一锁的场合，就会导致轻量级锁膨胀为重量级锁。**

#### 自旋锁
轻量级锁失败后，**虚拟机为了避免线程真实地在操作系统层面挂起**，锁将升级为自旋锁。

>**这是基于在大多数情况下，线程持有锁的时间都不会太长，如果直接挂起操作系统层面的线程可能会得不偿失，毕竟操作系统实现线程之间的切换时需要从用户态转换到核心态，这个状态之间的转换需要相对比较长的时间，时间成本相对较高;**

因此`自旋锁`会假设在不久将来，当前的线程可以获得锁，因此虚拟机会让当前想要获取锁的线程做几个空循环(这也是称为自旋的原因)，一般不会太久，可能是50个循环或100循环，在经过若干次循环后，如果得到锁，就顺利进入临界区。

**如果还不能获得锁，那就会将线程在操作系统层面挂起，这就是自旋锁的优化方式;**

#### 锁消除
`锁消除`是虚拟机另外一种锁的优化，Java虚拟机在`JIT`编译时(可以简单理解为当某段代码即将第一次被执行时进行编译，又称即时编译)，通过对运行上下文的扫描，去除不可能存在共享资源竞争的锁，通过这种方式消除没有必要的锁，可以节省毫无意义的请求锁时间;

#### `synchronized`锁升级过程

程序执行时对于同步代码块或同步方法锁进行优化操作:
>1. 编译时通过上下文的扫描,判断是否需要锁操作,不需要则进行`锁消除`优化;
2. 线程在不存在竞争情况下,初次获得锁,同步锁结构变成`偏向锁`;
3. 当出现锁竞争情况下,`偏向锁`失效,同步锁结构变成`轻量锁`,同步期间不存在竞争保持,若出现,`轻量锁`失效;
4. 线程在竞争同步锁过程中,若没有获取到锁时,不会马上挂起线程,而是进行`自旋`操作,在经过若干次循环后，如果得到锁，就顺利进入临界区;
5. `轻量级锁`失效后,同步锁在竞争激烈情况下,变成`重量级锁`;


###  `synchronized`的可重入性
从互斥锁的设计上来说，当一个线程试图操作一个由其他线程持有的对象锁的临界资源时，将会处于阻塞状态，但当一个线程再次请求自己持有对象锁的临界资源时，这种情况属于重入锁，请求将会成功;

在java中 `synchronized`是基于原子性的内部锁机制，是可重入的，因此在一个线程调用 `synchronized`方法的同时在其方法体内部调用该对象另一个 `synchronized`方法，也就是说一个线程得到一个对象锁后再次请求该对象锁，是允许的，这就是 `synchronized`的可重入性。


**偏向锁获取流程**

![biasedLock.png](/images/biasedLock.png)

**偏向锁发生冲突流程**

![biasedLockConflict.png](/images/biasedLockConflict.png)

**轻量级锁获取流程**

![LightweightLock.png](/images/LightweightLock.png)

**锁变化过程中Java对象头标签变化**

![lockStatusChange.png](/images/lockStatusChange.png)
