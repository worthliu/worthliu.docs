## 线程池

线程使应用能够更加充分合理地协调利用CPU,内存,网络,IO等系统资源.线程的创建需要开辟虚拟机栈,本地方法栈,程序计数器等线程私有的内存空间.在线程销毁时需要回收这些系统资源.频繁地创建和销毁线程会浪费大量的系统资源,增加并发编程风险;

>所以需要通过线程池协调多个线程,并实现类似主次线程隔离,定时执行,周期执行等任务;线程池的作用包括:
+ 利用线程池管理并复用线程,控制最大并发数等;
+ 实现任务线程队列缓存策略和拒绝机制;
+ 实现某些与时间相关的功能,如定时执行,周期执行等;
+ 隔离线程环境; 

![executor](/images/executor.png)

从JDK实现看,线程池通过`Executor`、`ExecutorService`两个接口定义线程池基础;

```Executor
public interface Executor {
    void execute(Runnable command);
}
```

```ExecutorService
public interface ExecutorService extends Executor {

    void shutdown();

    List<Runnable> shutdownNow();

    boolean isShutdown();

    boolean isTerminated();

    boolean awaitTermination(long timeout, TimeUnit unit)
        throws InterruptedException;

    <T> Future<T> submit(Callable<T> task);

    <T> Future<T> submit(Runnable task, T result);

    Future<?> submit(Runnable task);

    <T> List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks)
        throws InterruptedException;

    <T> List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks,
                                  long timeout, TimeUnit unit)
        throws InterruptedException;

    <T> T invokeAny(Collection<? extends Callable<T>> tasks)
        throws InterruptedException, ExecutionException;

    <T> T invokeAny(Collection<? extends Callable<T>> tasks,
                    long timeout, TimeUnit unit)
        throws InterruptedException, ExecutionException, TimeoutException;
}

```

### `AbstractExecutorService`

`AbstractExecutorService`是线程池抽象实现类，提供线程池底层接口方法的最底层实现；

```AbstractExecutorService
    // 
    protected <T> RunnableFuture<T> newTaskFor(Runnable runnable, T value) {
        return new FutureTask<T>(runnable, value);
    }	  
    // 执行任务提交
    public <T> Future<T> submit(Callable<T> task) {
        if (task == null) throw new NullPointerException();
        RunnableFuture<T> ftask = newTaskFor(task);
        execute(ftask);
        return ftask;
    }  
```

#### `FutureTask`

`FutureTask`，是线程池最后转换的执行单元入口参数（其实最终执行还是`Runnable`）

```RunnableFuture
public interface RunnableFuture<V> extends Runnable, Future<V>
```
```FutureTask
public class FutureTask<V> implements RunnableFuture<V>
```
```FutureTask
public FutureTask(Callable<V> callable) {
        if (callable == null)
            throw new NullPointerException();
        this.callable = callable;
        this.state = NEW;       // ensure visibility of callable
}

public FutureTask(Runnable runnable, V result) {
        this.callable = Executors.callable(runnable, result);
        this.state = NEW;       // ensure visibility of callable
}

public void run() {
        if (state != NEW ||
            !UNSAFE.compareAndSwapObject(this, runnerOffset,
                                         null, Thread.currentThread()))
            return;
        try {
            Callable<V> c = callable;
            if (c != null && state == NEW) {
                V result;
                boolean ran;
                try {
                    result = c.call();
                    ran = true;
                } catch (Throwable ex) {
                    result = null;
                    ran = false;
                    setException(ex);
                }
                if (ran)
                    set(result);
            }
        } finally {
            runner = null;
            int s = state;
            if (s >= INTERRUPTING)
                handlePossibleCancellationInterrupt(s);
        }
    }
```

## ThreadPoolExecutor

`ThreadPoolExecutor`是线程池的真正实现，它的构造方法提供了一系列参数来配置线程池;

```ThreadPoolExecutor
public ThreadPoolExecutor(int corePoolSize,
                              int maximumPoolSize,
                              long keepAliveTime,
                              TimeUnit unit,
                              BlockingQueue<Runnable> workQueue,
                              ThreadFactory threadFactory,
                              RejectedExecutionHandler handler) {
        if (corePoolSize < 0 ||
            // maximumPoolSize必须大于或等于1也要大于或等于corePoolSize
            maximumPoolSize <= 0 ||
            maximumPoolSize < corePoolSize ||
            keepAliveTime < 0)
            throw new IllegalArgumentException();
        if (workQueue == null || threadFactory == null || handler == null)
            throw new NullPointerException();
        this.corePoolSize = corePoolSize;
        this.maximumPoolSize = maximumPoolSize;
        this.workQueue = workQueue;
        this.keepAliveTime = unit.toNanos(keepAliveTime);
        this.threadFactory = threadFactory;
        this.handler = handler;
    }
```

>1. `corePoolSize`：**常驻核心线程数;**
  + 如果等于`0`,则任务执行完之后,没有任何请求进入时销毁线程池的线程;
   + 如果`ThreadPoolExecutor`的`allowCoreThreadTimeOut`属性设置为true,那么闲置的核心线程在等待新任务到来时会有超时策略，这个时间间隔由`keepAliveTime` 所指定的时长后，核心线程就会被终止。
  + 如果大于`0`,即使本地任务执行完毕,核心线程也不会被销毁.
2. `maximumPoolSize`：线程池所能容纳同时执行的最大线程数，当活动线程达到这个数值后，后续的新任务将被阻塞。
  + 如果待执行的线程数大于此值,需要借助缓存队列,缓存起来;
  + 如果`maximumPoolSize`与`corePoolSize`相等,既是固定大小线程池;
3. `keepAliveTime`：表示线程池中的线程空闲时间,当空闲时间达到`keepAliveTime`值时,线程会被销毁,直到只剩下`corePoolSize`个线程为止,避免浪费内存和句柄资源;
  + 当线程池的线程数大于`corePoolSize`时,`keepAliveTime`才会起作用;
  + 当`ThreadPoolExecutor`的`allowCoreThreadTimeOut`属性设置为true时，核心线程超时后也会被回收。
4. `unit`：`keepAliveTime` 参数的时间单位。
5. `workQueue`：缓存队列。此队列仅保持由 `execute` 方法提交的 `Runnable` 任务。
  + 当请求的线程数大于`corePoolSize`时,线程进入`BlockingQueue`阻塞队列.
6. `threadFactory`：执行程序创建新线程时使用的工厂。
  + 它用来生产一组相同任务的线程.
7. `handler`：执行拒绝策略的对象.
  + 当`workQueue`的任务缓存区到达上限后,并且活动线程数大于`maximumPoolSize`时候,线程池通过该策略处理请求,这是一种简单的限流保护;



>`ThreadPoolExecutor`执行任务时遵循以下规则：
  1. 如果线程池中的线程数量未达到核心线程的数量，那么会直接启动一个核心线程来执行任务； 
  2. 如果线程池中的线程数量已经达到或者超过核心线程的数量，那么任务会被插入到任务队列中排队等待执行； 
  3. 如果步骤2中无法将任务插入到任务队列中，这往往是由于任务队列已满，这个时候如果线程数量未达到线程池规定的最大值，那么会立刻启动一个非核心线程来执行。 
  4. 如果步骤3中线程数量已经达到线程池规定的最大值，那么就拒绝执行此任务，`ThreadPoolExecutor`会调用`RejectedExecutionHandler`的`rejectedExecution`方法来通知调用者。

>调整线程池的大小:**线程池的最佳大小主要取决于系统的可用cpu的数目，以及工作队列中任务的特点;**
* 假如一个具有N个cpu的系统上只有一个工作队列，并且其中全部是**运算性质(不会阻塞)的任务**，那么**当线程池拥有`N或N+1`个工作线程时，一般会获得最大的`cpu使用率`**。
* 如果工作队列中包含会**执行IO操作并经常阻塞的任务**，则要让线程池的大小超过可用 cpu的数量，因为并不是所有的工作线程都一直在工作。选择一个典型的任务，然后估计在执行这个任务的工程中，**等待时间与实际占用cpu进行运算的时间的比例WT/ST。对于一个具有`N个cpu的系统`，需要设置大约N(1+WT/ST)个线程来保证cpu得到充分利用**。
* 当然,cpu利用率不是调整线程池过程中唯一要考虑的事项，随着线程池工作数目的增长，还会碰到内存或者其他资源的限制，如套接字，打开的文件句柄或数据库连接数目等。要保证多线程消耗的系统资源在系统承受的范围之内。	