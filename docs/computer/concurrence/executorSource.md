## 线程池源码详解

```ThreadPoolExecutor
    // Integer共有32位,最右边29位表示工作线程数,最左边3位表示线程池状态
    // 注:简单说,3个二进制位可以表示从0至7的8个不同的数值
    private static final int COUNT_BITS = Integer.SIZE - 3;

    // 000-1111 1111 1111 1111 1111 1111 1111 1,类似于子网掩码,用于位的与运算
    private static final int CAPACITY   = (1 << COUNT_BITS) - 1;

    // 用左边高3位,存储线程池5状态
    // 运行状态,此状态表示线程池能接受新任务
    // 111-00000000000000000000000000000
    private static final int RUNNING    = -1 << COUNT_BITS;
    // 关机状态,此状态不再接受任务,但可以继续执行队列中的任务
    // 000-00000000000000000000000000000
    private static final int SHUTDOWN   =  0 << COUNT_BITS;
    // 停机状态,此状态全面拒绝,并中断正在处理的任务
    // 001-00000000000000000000000000000
    private static final int STOP       =  1 << COUNT_BITS;
    // 整理状态,此状态表示所有任务已经被终止
    // 010-00000000000000000000000000000
    private static final int TIDYING    =  2 << COUNT_BITS;
    // 终止状态,此状态表示已清理完现场
    // 011-00000000000000000000000000000
    private static final int TERMINATED =  3 << COUNT_BITS;

    // 与运算,掩码取反得到左边3位,获得线程池状态
    private static int runStateOf(int c)     { return c & ~CAPACITY; }
    // 与运算,掩码取与得到右边29位,获得工作线程数
    private static int workerCountOf(int c)  { return c & CAPACITY; }
    // 把左边3位与右边29位按或运算,合并成一个值
    private static int ctlOf(int rs, int wc) { return rs | wc; }
```

```ThreadPoolExecutor.tool
	public boolean remove(Runnable task) {
        boolean removed = workQueue.remove(task);
        tryTerminate(); // In case SHUTDOWN and now empty
        return removed;
    }

    // 判断线程池是否运行
    private static boolean isRunning(int c) {
        return c < SHUTDOWN;
    }

    private boolean compareAndIncrementWorkerCount(int expect) {
        return ctl.compareAndSet(expect, expect + 1);
    }
```

```ThreadPoolExecutor.execute
	public void execute(Runnable command) {
        if (command == null)
            throw new NullPointerException();

        // 返回包含线程数及线程池状态的Integer类型数值
        int c = ctl.get();

        // 如果工作线程小于核心线程数,则创建线程任务并执行
        if (workerCountOf(c) < corePoolSize) {
        	// 
            if (addWorker(command, true))
                return;
            // 如果创建失败,防止外部已经在线程池中加入新任务,重新获取一下
            c = ctl.get();
        }

        // 只有线程池处于RUNNING状态,才执行后半句:置入队列
        if (isRunning(c) && workQueue.offer(command)) {
            int recheck = ctl.get();
            // 如果线程池不是RUNNING状态,则将刚加入队列的任务移除(进入这里,意味着任务已经放入缓存队列中)
            if (! isRunning(recheck) && remove(command))
                reject(command);
            // 如果之前的线程已被消费完,新建一个线程
            else if (workerCountOf(recheck) == 0)
                addWorker(null, false);
        }// 核心池和队列都已满,尝试创建一个新线程
        else if (!addWorker(command, false))
            // 如果addWorker返回是false,即创建失败,则唤醒拒绝策略
            reject(command);
    }
```

```ThreadPoolExecutor.addWorker
    // 根据当前线程池状态,检查是否可以添加新的任务线程,如果可以则创建并启动任务;
    // 如果一切正常则返回true,返回false的可能性如下:
    // 1. 线程池没有处于RUNNING状态
    // 2. 线程工厂创建新的线程任务失败
    // firstTask : 外部启动线程池是需要构造的第一个线程,它是线程的母体
    // core : 新增工作线程时的判断指标:
    //       true 表示新增工作线程时,需要判断当前RUNNING状态的线程是否小于corePoolSize
    //       false 表示新增工作线程时,需要判断当前RUNNING状态的线程是否小于maximunPoolSize
	private boolean addWorker(Runnable firstTask, boolean core) {
		// goto跳转标签
        retry:
        for (;;) {
            int c = ctl.get();
            int rs = runStateOf(c);
            // 如果RUNNING状态,则条件为假,不执行后面的判断
            // 如果是SHUTDOWN状态,且firstTask初始线程不为空,或者队列为空
            // 都会直接返回创建失败
            if (rs >= SHUTDOWN &&
                ! (rs == SHUTDOWN &&
                   firstTask == null &&
                   ! workQueue.isEmpty()))
                return false;
            // 
            for (;;) {
                int wc = workerCountOf(c);
                // 如果超过最大允许线程数则不能再添加新的线程
                // 不能超过最大线程数2^29,否则影响左边3位的线程池状态值
                if (wc >= CAPACITY ||
                    wc >= (core ? corePoolSize : maximumPoolSize))
                    return false;
               
                // 将当前活动线程数加1
                if (compareAndIncrementWorkerCount(c))
                    break retry;
               
                // 线程池状态和工作线程数是可变化的,需要经常提取这个最新值
                c = ctl.get();  // Re-read ctl

                // 来到这步,rs的状态必然是RUNNING,若当前获取线程池状态不是RUNNING,再跳转到retry进行循环
                if (runStateOf(c) != rs)
                    continue retry;
                // else CAS failed due to workerCount change; retry inner loop
            }
        }

        //开始创建工作线程
        boolean workerStarted = false;
        boolean workerAdded = false;
        Worker w = null;
        try {
        	// 利用Worker构造方法中的线程池工厂(采用默认线程池工厂类)创建线程,并封装成工作线程Worker对象
            w = new Worker(firstTask);
            // 注意这是Worker中的属性对象thread
            final Thread t = w.thread;
            if (t != null) {
            	// 在进行ThreadPoolExecutor的敏感操作时
            	// 都需要持有主锁,避免在添加和启动线程时被干扰
                final ReentrantLock mainLock = this.mainLock;
                mainLock.lock();
                try {
                    // 再次获取当前线程池状态
                    int rs = runStateOf(ctl.get());
                    // 当线程池状态为RUNNING或SHUTDOWN且firstTask初始化线程为空时
                    if (rs < SHUTDOWN ||
                        (rs == SHUTDOWN && firstTask == null)) {
                        if (t.isAlive()) // precheck that t is startable
                            throw new IllegalThreadStateException();
                        workers.add(w);
                        int s = workers.size();
                        // 整个线程池在运行期间的最大并发任务个数
                        if (s > largestPoolSize)
                            largestPoolSize = s;
                        workerAdded = true;
                    }
                } finally {
                    mainLock.unlock();
                }
                // 增加工作线程成功时,执行线程
                if (workerAdded) {
                    t.start();
                    workerStarted = true;
                }
            }
        } finally {
        	// 线程启动失败,把刚才上述代码加上的工作线程计数再减回去
            if (! workerStarted)
                addWorkerFailed(w);
        }
        return workerStarted;
    }

```

```ThreadPoolExecutor.addWorkerFailed
	private void addWorkerFailed(Worker w) {
        final ReentrantLock mainLock = this.mainLock;
        mainLock.lock();
        try {
            if (w != null)
                workers.remove(w);
            decrementWorkerCount();
            tryTerminate();
        } finally {
            mainLock.unlock();
        }
    }
```

```ThreadPoolExecutor.Worker
// 它实现Runnable接口,并把本对象作为参数输入给run()方法中的runWorker(this),
// 所以内部属性线程thread在start的时候,即会调用runWorker方法
private final class Worker
        extends AbstractQueuedSynchronizer
        implements Runnable
    {
	Worker(Runnable firstTask) {
		// 它是AbstractQueuedSynchronizer的方法
		// 在runWorker方法执行之前禁止线程被中断
        setState(-1); // inhibit interrupts until runWorker
        this.firstTask = firstTask;
        this.thread = getThreadFactory().newThread(this);
    }

    // 当thread被start()之后,执行runWorker的方法
    public void run() {
        runWorker(this);
    }

    // 线程真实执行的方法
    final void runWorker(Worker w) {
        Thread wt = Thread.currentThread();
        Runnable task = w.firstTask;
        w.firstTask = null;
        w.unlock(); // allow interrupts
        boolean completedAbruptly = true;
        try {
            while (task != null || (task = getTask()) != null) {
                w.lock();
                // 如果线程池停止状态,中断线程
                // 如果线程池状态正常,确保工作线程不被中断
                if ((runStateAtLeast(ctl.get(), STOP) ||
                     (Thread.interrupted() &&
                      runStateAtLeast(ctl.get(), STOP))) &&
                    !wt.isInterrupted())
                    wt.interrupt();

                // 执行线程run()
                try {
                    beforeExecute(wt, task);
                    Throwable thrown = null;
                    try {
                        task.run();
                    } catch (RuntimeException x) {
                        thrown = x; throw x;
                    } catch (Error x) {
                        thrown = x; throw x;
                    } catch (Throwable x) {
                        thrown = x; throw new Error(x);
                    } finally {
                        afterExecute(task, thrown);
                    }
                } finally {
                    task = null;
                    w.completedTasks++;
                    w.unlock();
                }
            }
            completedAbruptly = false;
        } finally {
            processWorkerExit(w, completedAbruptly);
        }
    }
}
```

```ThreadPoolExecutor.getTask
	private Runnable getTask() {
        boolean timedOut = false; // Did the last poll() time out?

        for (;;) {
            int c = ctl.get();
            int rs = runStateOf(c);

            // Check if queue empty only if necessary.
            if (rs >= SHUTDOWN && (rs >= STOP || workQueue.isEmpty())) {
                decrementWorkerCount();
                return null;
            }

            int wc = workerCountOf(c);

            // Are workers subject to culling?
            boolean timed = allowCoreThreadTimeOut || wc > corePoolSize;

            if ((wc > maximumPoolSize || (timed && timedOut))
                && (wc > 1 || workQueue.isEmpty())) {
                if (compareAndDecrementWorkerCount(c))
                    return null;
                continue;
            }

            try {
                Runnable r = timed ?
                    workQueue.poll(keepAliveTime, TimeUnit.NANOSECONDS) :
                    workQueue.take();
                if (r != null)
                    return r;
                timedOut = true;
            } catch (InterruptedException retry) {
                timedOut = false;
            }
        }
    }
```

```ThreadPoolExecutor.processWorkerExit
	private void processWorkerExit(Worker w, boolean completedAbruptly) {
        if (completedAbruptly) // If abrupt, then workerCount wasn't adjusted
            decrementWorkerCount();

        final ReentrantLock mainLock = this.mainLock;
        mainLock.lock();
        try {
            completedTaskCount += w.completedTasks;
            workers.remove(w);
        } finally {
            mainLock.unlock();
        }

        tryTerminate();

        int c = ctl.get();
        if (runStateLessThan(c, STOP)) {
            if (!completedAbruptly) {
                int min = allowCoreThreadTimeOut ? 0 : corePoolSize;
                if (min == 0 && ! workQueue.isEmpty())
                    min = 1;
                if (workerCountOf(c) >= min)
                    return; // replacement not needed
            }
            addWorker(null, false);
        }
    }
```

```Executors.DefaultThreadFactory 线程产生默认线程工厂
	static class DefaultThreadFactory implements ThreadFactory {
        private static final AtomicInteger poolNumber = new AtomicInteger(1);
        private final ThreadGroup group;
        private final AtomicInteger threadNumber = new AtomicInteger(1);
        private final String namePrefix;

        DefaultThreadFactory() {
            SecurityManager s = System.getSecurityManager();
            group = (s != null) ? s.getThreadGroup() :
                                  Thread.currentThread().getThreadGroup();
            namePrefix = "pool-" +
                          poolNumber.getAndIncrement() +
                         "-thread-";
        }

        public Thread newThread(Runnable r) {
            Thread t = new Thread(group, r,
                                  namePrefix + threadNumber.getAndIncrement(),
                                  0);
            if (t.isDaemon())
                t.setDaemon(false);
            if (t.getPriority() != Thread.NORM_PRIORITY)
                t.setPriority(Thread.NORM_PRIORITY);
            return t;
        }
    }
```