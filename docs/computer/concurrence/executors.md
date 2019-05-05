## `Executors`线程池工具类

Java 类库提供了一个灵活的线程池以及一些有用的默认配置。可以通过调用`Executors`中的静态工厂方法之一来创建一个线程池:

调用方法|说明|
--|--|
`Executors.newWorkStealingPool`|`JDK8`引入,创建持有足够线程的线程池支持给定的并行度,并通过使用多个队列减少竞争,此构造方法中把`CPU`数量设置未默认的并行度;|
`Executors.newScheduledThreadPool`|线程数最大至`Integer.MAX_VALUE`,它是`ScheduledExecutorService`接口家族的实现类,支持定时及周期性任务执行.|
`Executors.newCachedThreadPool`|`maximumPoolSize`最大可以达到`Integer.MAX_VALUE`,是高度可伸缩的线程池,如果达到上限,相信没有任务服务器能够继续工作,肯定会抛出OOM异常;`keepAliveTime`默认为60秒,工作线程处于空闲状态,则回收工作线程.如果任务数增加,再次创建出线程处理任务;|
`Executors.newSingleThreadExecutor`|创建一个单线程的线程池,相当于单线程串行执行所有任务,保证按任务的提交顺序依次执行;|
`Executors.newFixedThreadPool`|输入的参数既是固定线程数,既是核心线程数也是最大线程数,不存在空闲线程,所以`keepAliveTime`等于`0`|

对于`Executors.newFixedThreadPool`,`ExecutorService.newSingleThreadExecutor`,所使用的缓存队列是`new LinkedBlockingQueue<Runnable>()`;由于使用无界队列,如果瞬间请求非常大,会有OOM的风险;
	
而`Executors.newCachedThreadPool`,所使用的缓存队列是`new SynchronousQueue<Runnable>()`;




>1. `newFixedThreadPool`：将创建一个固定长度的线程池，每当提交一个任务时就创建一个线程，直到达到线程池的最大数量。
  * 特点：线程数量固定，线程处于空闲状态时，它们并不会被回收，除非线程池被关闭。
  * 当所有线程都处于活动状态时，新任务都会处于等待状态，直到有线程空闲出来。基本线程数等于最大线程数，没有超时机制，使用无界的队列保存等待执行的任务。
2. `newCachedThreadPool`：将创建一个可缓存的线程池，如果线程池的当前规模超过了处理需求时，那么将回收空闲的线程，而当需求增加时，则可以添加新的线程，线程池的规模不存在任何限制。
  * 特点：基本线程数为0，最大线程数为`Integer.MAX_VALUE`.存活时间60s,采用异步队列`SynchronousQueue`来避免任务排队。
3. `newSingleThreadExecutor`：是一个单线程的`Executor`,它创建单个工作者线程来执行任务，如果这个线程异常结束，会创建另一个线程来替代。它能确保依照任务在对列中的顺序来串行执行（例如FIFO,LIFO,优先级）。
  * 特点：基本线程数和最大线程数都为1，无存活时间，采用无界的`LinkedBlockingQueue`来保存等待执行的任务。
4. `newScheduledThreadPool`：创建一个固定长度的线程池，而且以延迟或定时的方式来执行任务，类似于Timer.
