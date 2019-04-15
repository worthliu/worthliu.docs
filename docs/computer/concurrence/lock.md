## Lock

JDK中除去`synchronized`关键字实现的隐式同步锁外,在1.5后还提供由`Lock接口`实现可重入锁(`ReentrantLock`)显示同步锁;

```
public interface Lock {
    //加锁
    void lock();

    //解锁
    void unlock();

    //可中断获取锁，与lock()不同之处在于可响应中断操作，即在获
    //取锁的过程中可中断，注意synchronized在获取锁时是不可中断的
    void lockInterruptibly() throws InterruptedException;

    //尝试非阻塞获取锁，调用该方法后立即返回结果，如果能够获取则返回true，否则返回false
    boolean tryLock();

    //根据传入的时间段获取锁，在指定时间内没有获取锁则返回false;
    //如果在指定时间内当前线程未被中并断获取到锁则返回true
    boolean tryLock(long time, TimeUnit unit) throws InterruptedException;

    //获取等待通知组件，该组件与当前锁绑定，当前线程只有获得了锁
    //才能调用该组件的wait()方法，而调用后，当前线程将释放锁。
    Condition newCondition();
}
```

### `ReentrantLock`可重入锁

`ReetrantLock`本身也是一种支持重进入的锁，**即该锁可以支持一个线程对资源重复加锁，同时也支持公平锁与非公平锁。**

所谓的公平与非公平指的是在请求先后顺序上，先对锁进行请求的就一定先获取到锁，那么这就是公平锁，反之，如果对于锁的获取并没有时间上的先后顺序，如后请求的线程可能先获取到锁，这就是非公平锁;

>**`ReetrantLock`支持对同一线程重加锁,但是加锁多少次,就必须结束多少次;**

`ReentrantLock`的实现依赖于Java同步器框架`AbstractQueuedSynchronizer`(AQS).AQS使用一个整型的`volatile`变量(命名为`state`)来维护同步状态;

### 并发组件`AbstractQueuedSynchronizer`

`AbstractQueuedSynchronizer`又称为队列同步器(后面简称AQS)，它是用来构建锁或其他同步组件的基础框架，内部通过一个int类型的成员变量`state`来控制同步状态;

>+ 当`state=0`时，则说明没有任何线程占有共享资源的锁;
+ 当`state=1`时，则说明有线程目前正在使用共享变量，其他线程必须加入同步队列进行等待;

`AQS`内部通过内部类`Node`构成`FIFO`的同步队列来完成线程获取锁的排队工作，同时利用内部类`ConditionObject`构建等待队列，当`Condition`调用`wait()`方法后，线程将会加入等待队列中，而当`Condition`调用`signal()`方法后，线程将从等待队列转移动同步队列中进行锁竞争。

**注意这里涉及到两种队列，一种的同步队列，当线程请求锁而等待的后将加入同步队列等待，而另一种则是等待队列(可有多个)，通过`Condition`调用`await()`方法释放锁后，将加入等待队列**


#### AQS中的同步队列模型

```
public abstract class AbstractQueuedSynchronizer
    extends AbstractOwnableSynchronizer{
//指向同步队列队头
private transient volatile Node head;

//指向同步的队尾
private transient volatile Node tail;

//同步状态，0代表锁未被占用，1代表锁已被占用
private volatile int state;

}

```

`head`和`tail`分别是AQS中的变量，其中`head`指向同步队列的头部，注意`head`为空结点，不存储信息。而`tail`则是同步队列的队尾，**同步队列采用的是双向链表的结构这样可方便队列进行结点增删操作。**

+ `state`变量则是代表同步状态，执行当线程调用`lock`方法进行加锁后，如果此时`state`的值为0，则说明当前线程可以获取到锁，同时将`state`设置为1，表示获取成功。
+ 如果`state`已为1，也就是当前锁已被其他线程持有，那么当前执行线程将**被封装为`Node`结点加入同步队列等待**。

其中`Node`结点是对每一个访问同步代码的线程的封装，其包含了需要同步的线程本身以及线程的状态，如是否被阻塞，是否等待唤醒，是否已经被取消等。

每个`Node`结点内部关联其`前继结点prev`和`后继结点next`，这样可以方便线程释放锁后快速唤醒下一个在等待的线程;

```
static final class Node {
    //共享模式
    static final Node SHARED = new Node();
    //独占模式
    static final Node EXCLUSIVE = null;

    //标识线程已处于结束状态
    static final int CANCELLED =  1;
    //等待被唤醒状态
    static final int SIGNAL    = -1;
    //条件状态，
    static final int CONDITION = -2;
    //在共享模式中使用表示获得的同步状态会被传播
    static final int PROPAGATE = -3;

    //等待状态,存在CANCELLED、SIGNAL、CONDITION、PROPAGATE 4种
    volatile int waitStatus;

    //同步队列中前驱结点
    volatile Node prev;

    //同步队列中后继结点
    volatile Node next;

    //请求锁的线程
    volatile Thread thread;

    //等待队列中的后继结点，这个与Condition有关，稍后会分析
    Node nextWaiter;

    //判断是否为共享模式
    final boolean isShared() {
        return nextWaiter == SHARED;
    }

    //获取前驱结点
    final Node predecessor() throws NullPointerException {
        Node p = prev;
        if (p == null)
            throw new NullPointerException();
        else
            return p;
    }
}
```

其中`SHARED`和`EXCLUSIVE`常量分别代表`共享模式`和`独占模式`;

>+ 所谓共享模式是一个锁允许多条线程同时操作，如信号量`Semaphore`采用的就是基于AQS的共享模式实现的;
+ 而独占模式则是同一个时间段只能有一个线程对共享资源进行操作，多余的请求线程需要排队等待，如`ReentranLock`。

变量`waitStatus`则表示当前被封装成`Node`结点的等待状态，共有4种取值`CANCELLED`、`SIGNAL`、`CONDITION`、`PROPAGATE`。

>+ `CANCELLED`：值为1，在同步队列中等待的线程等待超时或被中断，需要从同步队列中取消该`Node`的结点，其结点的`waitStatus`为`CANCELLED`，即结束状态，进入该状态后的结点将不会再变化。
+ `SIGNAL`：值为-1，被标识为该等待唤醒状态的后继结点，当其前继结点的线程释放了同步锁或被取消，将会通知该后继结点的线程执行。说白了，就是处于唤醒状态，只要前继结点释放锁，就会通知标识为SIGNAL状态的后继结点的线程执行。
+ `CONDITION`：值为-2，与 `Condition`相关，该标识的结点处于等待队列中，结点的线程等待在 `Condition`上，当其他线程调用了`Condition`的`signal()`方法后，`CONDITION`状态的结点将从等待队列转移到同步队列中，等待获取同步锁。
+ `ROPAGATE`：值为-3，与共享模式相关，在共享模式中，该状态标识结点的线程处于可运行状态。
+ `0状态`：值为0，代表初始化状态。

我们从JDK源码中,可以查看`ReentrantLock`类结构:

![ReentrantLock.AQS](/images/ReentrantLock.AQS.png)

ReentrantLock分为公平锁和非公平锁:
>* 使用公平锁时,加锁方法`lock()`的方法调用轨迹如下:
  1. `ReentrantLock:lock()`
  2. `FairSync:lock()`
  3. `AbstractQueuedSynchronizer:accquire(int arg)`
  4. `ReentrantLock:tryAcquire(int acquires)`
![tryAcquire](/images/tryAcquire.png)

>* 使用公平锁时,解锁方法`unlock()`的方法调用轨迹如下:
  1. `ReentrantLock:unlock()`
  2. `AbstractQueuedSychronizer:release(int arg)`
  3. `Sync:tryRelease(int releases)`
![tryRelease](/images/tryRelease.png)

(公平锁在释放锁的最后写`volatile`变量`state`;
 在获取锁时首先读这个volatile变量.**根据volatile的happens-before规则,释放锁的线程在写volatile变量之前可见的共享变量,在获取锁的线程读取同一个volatile变量后将立即变的对获取锁的线程可见**)

>* 使用非公平锁时,加锁方法lock()的方法调用轨迹如下:
  1. `ReentrantLock:lock()`
  2. `NonfairSync:lock()`
  3. `AbstractQueuedSynchronizer:compareAndSetState(int expect, int update)`
![compareAndSwapInt](/images/compareAndSwapInt.png) 

>* 编译器不会对`volatile`读与`volatile`读后面的任意内存操作重排序;
* 编译器不会对`volatile`写与`volatile`写前面的任意内存操作重排序;

**(为了同时是实现`volatile`读和`volatile`写的内存语义,编译器不能对CAS与CAS前面和后面的任意内存操作重排序)**

![casSource](/images/casSource.png)


>如源代码所示,程序会根据当前处理器的类型来决定是否为cmpxchg指令添加lock前缀.如果程序时在多处理器上运行,就为cmpxchg指令加上lock前缀(lock cmpxchg).反之,不需要lock前缀提供的内存屏障效果.

>Intel的手册对lock前缀的说明:
1. 确保对内存的读-改-写操作源自执行.*在Pentium及Pentium之前的处理器中,带有lock前缀的指令在执行期间会锁住总线,使得其他处理器暂时无法通过总线访问内存.
  * 从Pentium 4 ,Intel Xeon及P6处理器开始,Intel在原有总线锁的基础上做了一个很有意义的优化:如果要访问的内存区域在lock前缀指令执行期间已经在处理器内部的缓存中被锁定(即包含改内存区域的缓存行当前处于独占或以修改状态),并且该内存被完成包含在单个缓存行中,那么处理器将直接执行该指令.
  * **由于在指令执行期间该缓存行一直被锁定,其他处理器无法读/写该指令要访问的内存区域,因此能保证指令执行的原子性.**缓存锁定将大大降低lock前缀指令的执行开销,但是当多处理器之间的竞争程度很高或者指令访问的内存地址未对齐时,仍然会锁住总线;
2. 禁止该指令与之前和之后的读和写指令重排序;
3. 把写缓冲区中所有数据刷新到内存中;

---

>公平锁和非公平锁的内存语义总结:
1. 公平锁和非公平锁释放时,最后都要写一个`volatile`变量state;
2. 公平锁获取是,首先去读这个`volatile`变量;
3. 非公平锁获取时,首先会用CAS更新这个`volatile`变量,这个操作同时具有`volatile`读和`volatile`写的内存语义;

## concurrent包的实现

由于Java的CAS同时具有volatile读和volatile写的内存语义,因此Java线程之间的通信现在有了下面四种方式:
>1. A线程写volatile变量,随后B线程读这个volatile变量;
2. A线程写volatile变量,随后B线程用CAS更新这个volatile变量;
3. A线程用CAS更新一个volatile变量,随后B线程用CAS更新这个volatile变量;
4. A线程用CAS更新一个volatile变量,随后B线程读这个volatile变量;

***Java的CAS会使用现代处理器上提供的高效机器级别原子指令,这些原子指令以原子方式对内存执行读-改-写操作,只是在多处理器中实现同步的关键来说,能够支持原子性读-改-写指令的计算器,是顺序计算图灵机的异步等价机器;***

同时,volatile变量的读/写和CAS可以实现线程之间的通信.这形成呢整个concurrent包得以实现的基石.
>concurrent包的源代码实现,会发现一个通用化的实现模式:
1. 首先,声明共享变量为`volatile`;
2. 然后,使用CAS的原子条件更新来实现线程之间的同步;
3. 同时配合以`volatile`的读/写和CAS所具有的`volatile`读和写的内存语义来实现线程之间的通信;

>AQS,非阻塞数据结构和原子变量类(`java.util.concurrent.atomic`包中的类)

![cas](/images/cas.png)