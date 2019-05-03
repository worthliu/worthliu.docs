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

