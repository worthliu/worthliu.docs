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
            // 
            // Check if queue empty only if necessary.
            if (rs >= SHUTDOWN &&
                ! (rs == SHUTDOWN &&
                   firstTask == null &&
                   ! workQueue.isEmpty()))
                return false;

            for (;;) {
                int wc = workerCountOf(c);
                if (wc >= CAPACITY ||
                    wc >= (core ? corePoolSize : maximumPoolSize))
                    return false;
                if (compareAndIncrementWorkerCount(c))
                    break retry;
                c = ctl.get();  // Re-read ctl
                if (runStateOf(c) != rs)
                    continue retry;
                // else CAS failed due to workerCount change; retry inner loop
            }
        }

        boolean workerStarted = false;
        boolean workerAdded = false;
        Worker w = null;
        try {
            w = new Worker(firstTask);
            final Thread t = w.thread;
            if (t != null) {
                final ReentrantLock mainLock = this.mainLock;
                mainLock.lock();
                try {
                    // Recheck while holding lock.
                    // Back out on ThreadFactory failure or if
                    // shut down before lock acquired.
                    int rs = runStateOf(ctl.get());

                    if (rs < SHUTDOWN ||
                        (rs == SHUTDOWN && firstTask == null)) {
                        if (t.isAlive()) // precheck that t is startable
                            throw new IllegalThreadStateException();
                        workers.add(w);
                        int s = workers.size();
                        if (s > largestPoolSize)
                            largestPoolSize = s;
                        workerAdded = true;
                    }
                } finally {
                    mainLock.unlock();
                }
                if (workerAdded) {
                    t.start();
                    workerStarted = true;
                }
            }
        } finally {
            if (! workerStarted)
                addWorkerFailed(w);
        }
        return workerStarted;
    }

```