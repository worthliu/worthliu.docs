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

>+ `CANCELLED`：值为`1`，在同步队列中等待的线程等待超时或被中断，需要从同步队列中取消该`Node`的结点，其结点的`waitStatus`为`CANCELLED`，即结束状态，进入该状态后的结点将不会再变化。
+ `SIGNAL`：值为`-1`，被标识为该等待唤醒状态的后继结点，当其前继结点的线程释放了同步锁或被取消，将会通知该后继结点的线程执行。说白了，就是处于唤醒状态，只要前继结点释放锁，就会通知标识为SIGNAL状态的后继结点的线程执行。
+ `CONDITION`：值为`-2`，与 `Condition`相关，该标识的结点处于等待队列中，结点的线程等待在 `Condition`上，当其他线程调用了`Condition`的`signal()`方法后，`CONDITION`状态的结点将从等待队列转移到同步队列中，等待获取同步锁。
+ `ROPAGATE`：值为`-3`，与共享模式相关，在共享模式中，该状态标识结点的线程处于可运行状态。

我们从JDK源码中,可以查看`ReentrantLock`类结构:

![ReentrantLock.AQS](/images/ReentrantLock.AQS.png)

+ `AbstractOwnableSynchronizer`：定义了存储独占当前锁的线程和获取的方法
+ `AbstractQueuedSynchronizer`：抽象类，AQS框架核心类，其内部以虚拟队列的方式管理线程的锁获取与锁释放，其中获取锁(`tryAcquire`方法)和释放锁(`tryRelease`方法)并没有提供默认实现，需要子类重写这两个方法实现具体逻辑;
  + `Node`：`AbstractQueuedSynchronizer`的内部类，用于构建虚拟队列(链表双向链表)，管理需要获取锁的线程。
+ `ReentrantLock`：实现了`Lock`接口的，其内部类有`Sync`、`NonfairSync`、`FairSync`，在创建时可以根据`fair参数`决定创建`NonfairSync`(默认非公平锁)还是`FairSync`。
  + `Sync`：抽象类，是`ReentrantLock`的内部类，继承自`AbstractQueuedSynchronizer`，实现了释放锁的操作(`tryRelease()`方法)，并提供了`lock`抽象方法，由其子类实现。
  + `NonfairSync`：是`ReentrantLock`的内部类，继承自`Sync`，非公平锁的实现类。
  + `FairSync`：是`ReentrantLock`的内部类，继承自`Sync`，公平锁的实现类。


#### `ReetrantLock`,`AQS`独占模式实现

`AQS同步器`的实现依赖于内部的同步队列(FIFO的双向链表对列)完成对同步状态(state)的管理，当前线程获取锁(同步状态)失败时，**AQS会将该线程以及相关等待信息包装成一个节点(Node)并将其加入同步队列，同时会阻塞当前线程**，当同步状态释放时，会将`头结点head`中的线程唤醒，让其尝试获取同步状态。

ReentrantLock分为公平锁和非公平锁:
>* 使用公平锁时,加锁方法`lock()`的方法调用轨迹如下:
  1. `ReentrantLock:lock()`
  2. `FairSync:lock()`
  3. `AbstractQueuedSynchronizer:accquire(int arg)`
  4. `ReentrantLock:tryAcquire(int acquires)`
```
    protected final boolean tryAcquire(int acquires) {
        final Thread current = Thread.currentThread();
        //获取锁的开始,首先读取volatile变量state
        int c = getState();
        if (c == 0) {
            // 判断是否已有线程等待获取锁
            // 若无,则CAS操作替换state值为1
            if (!hasQueuedPredecessors() &&
                compareAndSetState(0, acquires)) {
                // 获取锁成功,设置独占线程对象
                setExclusiveOwnerThread(current);
                return true;
            }
        }
        // 请求锁线程是当前已获得锁线程,重入操作,状态值加一
        else if (current == getExclusiveOwnerThread()) {
            int nextc = c + acquires;
            if (nextc < 0)
                throw new Error("Maximum lock count exceeded");
            setState(nextc);
            return true;
        }
        return false;
    }

    //判断内部队列里面是否存在长时间等待获取锁的线程
    public final boolean hasQueuedPredecessors() {
        Node t = tail; // Read fields in reverse initialization order
        Node h = head;
        Node s;
        return h != t &&
            ((s = h.next) == null || s.thread != Thread.currentThread());
    }
```

>* 使用公平锁时,解锁方法`unlock()`的方法调用轨迹如下:
  1. `ReentrantLock:unlock()`
  2. `AbstractQueuedSychronizer:release(int arg)`
```
    public final boolean release(int arg) {
        // 释放锁
        if (tryRelease(arg)) {
            Node h = head;
            if (h != null && h.waitStatus != 0)
                unparkSuccessor(h);
            return true;
        }
        return false;
    }
```
  3. `Sync:tryRelease(int releases)`
```
    protected final boolean tryRelease(int releases) {
        // 获得释放锁后的状态值
        int c = getState() - releases;
        // 判断线程对象是否独占锁线程;
        if (Thread.currentThread() != getExclusiveOwnerThread())
            throw new IllegalMonitorStateException();
        boolean free = false;
        // 状态值为0,释放独占线程对象
        if (c == 0) {
            free = true;
            setExclusiveOwnerThread(null);
        }
        // 设置状态值
        setState(c);
        return free;
    }
```

>公平锁在释放锁的最后写`volatile`变量`state`;
 在获取锁时首先读这个`volatile`变量.**根据`volatile`的`happens-before`规则,释放锁的线程在写`volatile`变量之前可见的共享变量,在获取锁的线程读取同一个`volatile`变量后将立即变的对获取锁的线程可见**

>* 使用非公平锁时,加锁方法lock()的方法调用轨迹如下:
  1. `ReentrantLock:lock()`
  2. `NonfairSync:lock()`
```
    final void lock() {
        // 非公平锁,先直接设置状态值和独占线程对象
        if (compareAndSetState(0, 1))
            setExclusiveOwnerThread(Thread.currentThread());
        else
        // 失败再次获取锁操作
            acquire(1);
    }


    public final void acquire(int arg) {
        // 尝试获取锁操作,失败
        if (!tryAcquire(arg) &&
            acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
            selfInterrupt();
    }


    protected final boolean tryAcquire(int acquires) {
        return nonfairTryAcquire(acquires);
    }

    // 获取锁失败,将当前线程包装成Node节点,塞入同步队列中
    private Node addWaiter(Node mode) {
        // 将请求同步状态失败的线程封装成结点
        Node node = new Node(Thread.currentThread(), mode);
        // Try the fast path of enq; backup to full enq on failure
        Node pred = tail;
        // 尝试快速在队列尾部插入
        if (pred != null) {
            node.prev = pred;
            // 使用CAS执行尾部结点替换,尝试在尾部快速添加
            if (compareAndSetTail(pred, node)) {
                pred.next = node;
                return node;
            }
        }
        // 如果第一次加入或者CAS操作没有成功执行enq入队操作
        enq(node);
        return node;
    }

    final boolean nonfairTryAcquire(int acquires) {
        final Thread current = Thread.currentThread();
        int c = getState();
        if (c == 0) {
            if (compareAndSetState(0, acquires)) {
                setExclusiveOwnerThread(current);
                return true;
            }
        }
        else if (current == getExclusiveOwnerThread()) {
            int nextc = c + acquires;
            if (nextc < 0) // overflow
                throw new Error("Maximum lock count exceeded");
            setState(nextc);
            return true;
        }
        return false;
    }

    // 自旋不断获取锁
    final boolean acquireQueued(final Node node, int arg) {
        boolean failed = true;
        try {
            boolean interrupted = false;
            for (;;) {
                // 前驱结点
                final Node p = node.predecessor();
                if (p == head && tryAcquire(arg)) {
                    setHead(node);
                    p.next = null; // help GC
                    failed = false;
                    return interrupted;
                }
                // 如果前驱结点不是head,判断是否挂起线程
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                    interrupted = true;
            }
        } finally {
            if (failed)
               // 若没有获取同步状态,结束该线程的请求
                cancelAcquire(node);
        }
    }
```

### `CAS`原子操作

>* 编译器不会对`volatile`读与`volatile`读后面的任意内存操作重排序;
* 编译器不会对`volatile`写与`volatile`写前面的任意内存操作重排序;

**(为了同时是实现`volatile`读和`volatile`写的内存语义,编译器不能对CAS与CAS前面和后面的任意内存操作重排序)**

```
public final native boolean compareAndSwapInt(Object o, long offset, int expected, int x);
```

可以看到这是个本地方法调用,这个本地方法在openjdk中依次调用的c++代码为:`unsafe.cpp`,`atomic.cpp`,`atomic_windows_x86.inline.hpp`

```
// Adding a lock prefix to an instruction on MP machine
// VC++ doesn't like the lock prefix to be on a single line
// so we can't insert a label after the lock prefix.
// By emitting a lock prefix, we can define a label after it.
#define LOCK_IF_MP(mp) __asm cmp mp, 0  \
                       __asm je L0      \
                       __asm _emit 0xF0 \
                       __asm L0:



inline jint     Atomic::cmpxchg    (jint     exchange_value, volatile jint*     dest, jint     compare_value) {
  // alternative for InterlockedCompareExchange
  int mp = os::is_MP();
  __asm {
    mov edx, dest
    mov ecx, exchange_value
    mov eax, compare_value
    LOCK_IF_MP(mp)
    cmpxchg dword ptr [edx], ecx
  }
}

```

>如源代码所示,程序会根据当前处理器的类型来决定是否为`cmpxchg`指令添加`lock`前缀.如果程序时在多处理器上运行,就为`cmpxchg`指令加上`lock`前缀(`lock cmpxchg`).反之,不需要`lock`前缀提供的内存屏障效果.

>**`Intel`的手册对`lock`前缀的说明:**
1. 确保对内存的读-改-写操作源自执行.在`Pentium`及`Pentium`之前的处理器中,带有lock前缀的指令在执行期间会锁住总线,使得其他处理器暂时无法通过总线访问内存.
  + 从`Pentium 4` ,`Intel Xeon`及`P6`处理器开始,`Intel`在原有总线锁的基础上做了一个很有意义的优化:
    + 如果要访问的内存区域在`lock前缀指令执行期间已经在处理器内部的缓存中被锁定(即包含改内存区域的缓存行当前处于独占或以修改状态),并且该内存被完成包含在单个缓存行中,那么处理器将直接执行该指令.
  + **由于在指令执行期间该缓存行一直被锁定,其他处理器无法读/写该指令要访问的内存区域,因此能保证指令执行的原子性.**
  + 缓存锁定将大大降低lock前缀指令的执行开销,但是当多处理器之间的竞争程度很高或者指令访问的内存地址未对齐时,仍然会锁住总线;
2. 禁止该指令与之前和之后的读和写指令重排序;
3. 把写缓冲区中所有数据刷新到内存中;


>公平锁和非公平锁的内存语义总结:
1. 公平锁和非公平锁释放时,最后都要写一个`volatile`变量state;
2. 公平锁获取是,首先去读这个`volatile`变量;
3. 非公平锁获取时,首先会用CAS更新这个`volatile`变量,这个操作同时具有`volatile`读和`volatile`写的内存语义;

## concurrent包的实现

由于Java的`CAS`同时具有`volatile`读和`volatile`写的内存语义,因此Java线程之间的通信现在有了下面四种方式:
>1. A线程写`volatile`变量,随后B线程读这个`volatile`变量;
2. A线程写`volatile`变量,随后B线程用CAS更新这个`volatile`变量;
3. A线程用CAS更新一个`volatile`变量,随后B线程用CAS更新这个`volatile`变量;
4. A线程用CAS更新一个`volatile`变量,随后B线程读这个`volatile`变量;

***Java的`CAS`会使用现代处理器上提供的高效机器级别原子指令,这些原子指令以原子方式对内存执行读-改-写操作,只是在多处理器中实现同步的关键来说,能够支持原子性读-改-写指令的计算器,是顺序计算图灵机的异步等价机器;***

同时,`volatile`变量的读/写和`CAS`可以实现线程之间的通信.这形成呢整个`concurrent`包得以实现的基石.
>`concurrent`包的源代码实现,会发现一个通用化的实现模式:
1. 首先,声明共享变量为`volatile`;
2. 然后,使用CAS的原子条件更新来实现线程之间的同步;
3. 同时配合以`volatile`的读/写和CAS所具有的`volatile`读和写的内存语义来实现线程之间的通信;

>`AQS`,非阻塞数据结构和原子变量类(`java.util.concurrent.atomic`包中的类)

![cas](/images/cas.png)