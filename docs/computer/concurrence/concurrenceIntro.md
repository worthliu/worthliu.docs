## 并发与多线程

从并发(Concurrency)与并行(Parallelism)说起:
+ 并发是指在某个时间段内,多任务交替处理的能力;
  + 所谓不患寡而患不均,每个`CPU`不可能只顾着执行某个进行,让其他进程一直处于等待状态;
  + 因此,`CPU`把可执行时间均匀地分成若干份,每个进程执行一段时间后,记录当前的工作状态,释放相关的执行资源并进入等待状态,让其他进程抢占`CPU`资源;
+ 并行是指同时处理多任务的能力.
  + `CPU`在目前已经发展为多核结构,可以同时执行多个互不依赖的指令及执行块;

**并发与并行的目标都是尽可能快地执行完所有任务;**

在并发环境下,由于程序的封闭性被打破,出现了以下特点:
+ 并发程序之间有相互制约的关系;
  + 直接制约:一个程序需要另一个程序计算的结果;
  + 间接制约:为多个程序竞争共享资源,如处理器,缓冲区等;
+ 并发程序的执行过程是断断续续的;
+ 当并发数设置合理并且`CPU`拥有足够的处理能力时,并发会提高程序的运行效率;

### 线程

线程是`CPU`调度和分派的基本单位,为了更充分地利用`CPU`资源,一般都会使用多线程进行处理.

多线程的作用是提高任务的平均执行速度,但是会导致程序可理解性变差,编程难度加大;

线程可以拥有自己的操作栈,程序计数器,局部变量表等资源,它与同一进程内的其他线程共享该进程的所有资源.

>线程在生命周期内存在多种状态:
+ `NEW`(新建状态)
+ `RUNNABLE`(就绪状态)
+ `RUNNING`(运行状态)
+ `BLOCKED`(阻塞状态)
+ `DAED`(终止状态)

1. `NEW`(新建状态),是线程被创建且未启动的状态;
  + 继承自`Thread`类;
  + 实现`Runnable`接口;
  + 实现`Callable`接口;

  ```Runnable
      /**
       * When an object implementing interface <code>Runnable</code> is used
       * to create a thread, starting the thread causes the object's
       * <code>run</code> method to be called in that separately executing
       * thread.
       * <p>
       * The general contract of the method <code>run</code> is that it may
       * take any action whatsoever.
       *
       * @see     java.lang.Thread#run()
       */
      public abstract void run();
  ```

  ```Callable
   	/**
       * 返回结果或抛出异常
       *
       * @return computed result
       * @throws Exception if unable to compute a result
       */
      V call() throws Exception;
  ```
  从上述`Callable`声明中,可知`Callable`和`Runnable`有两点不同:
  + `Callable.call()`可以获得返回值,而`Runnable`无法直接获取执行结果,需要借助共享变量等获取;
  + `Callable.call()`可以抛出异常,而`Runnable`只有通过`Threa.setDefaultUncaughtExceptionHandler()`的方式才能在主线程中捕捉到子线程异常;


2. `RUNNABLE`(就绪状态),是调用`start()`之后运行之前的状态.
  + 线程的`start()`不能被多次调用,否则会抛出`IllegalThreadStateException`异常;

3. `RUNNING`(运行状态),是`run()`正在执行时线程的状态;

4. `BLOCKED`(阻塞状态),进入此状态,有以下种情况:
  + 同步阻塞 : 锁被其他线程占用;
  + 主动阻塞 : 调用`Thread`的某些方法,主动让出CPU执行权,比如`sleep()`,`join()`等;
  + 等待阻塞 : 执行了`wait()`;

5. `DAED`(终止状态),是`run()`执行结束,或因异常退出后状态,此状态不可逆转;

### 线程安全

**线程安全问题只在多线程环境下才出现,单线程串行执行不存在此问题.**

保证高并发场景下的线程安全,可以从以下四个维度考量:

>+ 数据单线程内可见;
  + 单线程总是安全的.通过限制数据仅在单线程内可见,可以避免数据被其它线程篡改;
  + 线程局部变量,它存储在独立虚拟机栈帧的局部变量表中,与其他线程毫无瓜葛;`ThreadLocal`就是采用此种方式;
+ 只读对象.它的特性是允许复制,拒绝写入;
  + 一个对象想要拒绝任何写入,必须要满足以下条件:
    + `final`关键字修饰类,避免被继承;
    + 使用`private final`关键字避免属性被中途修改;
    + 没有任何更新方法;
    + 返回值不能为可变对象;
+ 线程安全类
+ 同步与锁机制


>**线程安全的核心理念:`要么只读,要么加锁`**

### `JDK`并发包

对于线程安全,`JDK`提供并发包,往往能化腐朽为神奇;

并发包主要分为以下几个类族:
>+ 线程同步类:
  + `CountDownLatch`,`Semaphore`,`CycliBarrier`;
+ 并发集合类:
  + `ConcurrentHashMap`,`ConcurrentSkipListMap`,`CopyOnWriteArrayList`,`BlockingQueue`等;
+ 线程管理类:
  + `ThreadLocal`,`Executors`,`ThreadPoolExecutor`,`ScheduledExecutorService`等;
+ 锁相关类:
  + `ReentrantLock`

### 什么是锁

计算机的锁从开始的悲观锁,发展到后来的乐观锁,偏向锁,分段锁等.

锁主要提供了两种特性:`互斥性`和`不可见性`;

Java种常用锁实现的方式有两种:

+ 用并发包中锁类
  
  并发包的类族中,`Lock`是JUC包的顶层接口,它的实现逻辑并未用到`synchronized`,而是利用了`volatile`的可见性;

  以`ReentrantLock`为例,`ReentrantLock`对于`Lock`接口的实现主要依赖了`Sync`,而`Sync`继承了`AbstractQueuedSynchronizer(AQS)`,它是JUC包实现同步的基础工具;

  >在`AQS`中,定义了一个`volatile int state`变量作为共享资源,如果线程获取资源失败,则进入同步`FIFO`队列中等待;

  **如果成功获取资源就执行临界区代码.执行完释放资源,会通知同步队列中的等待线程来获取资源后出队并执行;**

  **`AQS`是抽象类,内置自旋锁实现的同步队列,封装入队和出队的操作,提供独占,共享,中断等特性方法;`AQS`的子类可以定义不同的资源实现不同性质的方法;**
  + 可重入锁`ReentrantLock`,定义`state`为`0`时可以获取资源并置为1.若以获得资源,`state`不断加`1`,在释放资源时`state`减`1`,直至为`0`;
  + `CountDownLatch`初始时定义了资源总量`state=count`,`countDown()`不断将`state`减`1`,当`state=0`时才能获得锁,释放后`state`就一直为`0`.所有线程调用`await()`都不会等待,所以`CountDownLatch`时一次性,用完后如果再想用就只能重新创建一个;
  + `CyclicBarrier`是可重复使用得资源;
  + `Semaphore`同样定义了资源总量`state=permits`,当`state>0`时就能获得锁,并将`state`减`1`,当`state=0`时只能等待其他线程释放锁,当释放锁时`state`加`1`,其他等待线程又能获得这个锁.当`Semaphore`的`permits`定义为`1`时,就是互斥锁,当`permits>1`就是共享锁;

  查看详细的<a href="#/computer/concurrence/lock" title="Lock">`Lock`</a>介绍,可以点击这里;
+ 利用同步代码块
  + 同步代码块一般使用`Java`的`synchronized`关键字来实现
    + 在方法签名处加`synchronized`关键字
    + 使用`synchronized`对象或锁进行同步;
  JVM底层时通过监视锁来实现`synchronized`同步的.监视锁`monitor`,是每个对象与生俱来的一个隐藏字段.使用`synchronized`的当前使用环境,找到对应对象的`monitor`,再根据`monitor`的状态进行加锁解锁的判断;

  方法元信息中会使用`ACC_SYNCHRONIZED`标识该方法是一个同步方法.同步代码块中会使用`monitorenter`及`monitorexit`两个字节码指令获取和释放`monitor`;

  + 如果使用`monitorenter`进入时`monitor`为`0`,表示该线程可以持有`monitor`后续代码,并将`monitor`加`1`;
  + 如果当前线程已经持有了`monitor`,那么`monitor`继续加`1`;
  + 如果`monitor`非`0`,其他线程就会进入阻塞状态;

  查看详细的<a href="#/computer/concurrence/synchronized" title="synchronized">`synchronized`</a>介绍,可以点击这里;

### 线程同步

资源共享的两个原因是资源紧缺和共建需求.
+ 线程共享`CPU`,是从资源紧缺的维度来考虑的;
+ 多线程共享同一变量,是从共建需求维度来考虑的;

**在多个线程对同一变量进行写操作时,如果操作没有原子性,就可能产生脏数据.**

>**计算机的线程同步,就是线程之间按某种机制协调先后次序执行,当有一个线程在对内存进行操作时,其他线程都不可以对这个内存地址进行操作,直到该线程完成操作.**

实现线程同步的方式有很多:`同步方法`,`锁`,`阻塞队列`等;

#### `volatile`

`happen before`是时钟顺序的先后,并不能保证线程交互的可见性;

>什么是可见性?
+ 可见性是指某线程修改共享变量的指令对其他线程来说都是可见的,它反映的是指令执行的实时透明度;

每个线程都有独占的内存区域,如果操作栈,本地变量表等.线程本地内存保存呢引用变量在堆内存中的副本,线程对变量的所有操作都在本地内存区域中进行,执行结束后再同步到堆内存中去.这里必然有一个时间差,在这个时间差内,该线程对副本的操作,对于其他线程都是不可见的;

>`volatile`修饰变量时,意味着任何对此变量的操作都会在内存中进行,不会产生副本,以保证共享变量的可见性,局部阻止了指令重排的发生.**由此可知,在使用单例设计模式时,即使用双检锁也不一定拿到最新的数据;**

锁也可以确保变量的可见性,但是实现方式和`volatile`略有不同.线程在得到锁时读入副本,释放时写回内存,锁的操作尤其要符合`happen before`原则;

`volatile`解决的是多线程共享变量的可见性问题,类似于`synchronized`,但不具备`synchronized`的互斥性.所以对`volatile`变量的操作并非都具有原子性;