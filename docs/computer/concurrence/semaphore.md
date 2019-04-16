## `Semaphore`

信号量(`Semaphore`)，在多线程环境下用于协调各个线程, 以保证它们能够正确、合理的使用公共资源。

信号量维护了一个许可集，我们在初始化`Semaphore`时需要为这个许可集传入一个数量值，该数量值代表同一时间能访问共享资源的线程数量。

**线程可以通过`acquire()`方法获取到一个许可，然后对共享资源进行操作，注意如果许可集已分配完了，那么线程将进入等待状态，直到其他线程释放许可才有机会再获取许可，线程释放一个许可通过`release()`方法完成。**


`Semaphore`即可用于实现共享锁又可实现互斥锁,区别在于许可数量;

### `Semaphore`内部原理

在看看`Semaphore`实现前,我们先来看看内部类的结构:

![Semaphore](/images/Semaphore.png)

从上述看到`Semaphore`的类结构与`ReentrantLock`类结构基本一致;同样是在继承自`AQS`的内部类`Sync`以及继承自`Sync`的公平锁(`FairSync`)和非公平锁(`NofairSync`)的实现;


对于内部实现而言,`Sync`基于`AQS`组件实现共享锁提供对外方法应用,具体实现如下:

```
	abstract static class Sync extends AbstractQueuedSynchronizer {
        private static final long serialVersionUID = 1192457210091910933L;

        // 构造函数,设置共享资源数量
        Sync(int permits) {
            setState(permits);
        }
        // 获取共享资源数量
        final int getPermits() {
            return getState();
        }
        // 非公平尝试获取共享资源
        final int nonfairTryAcquireShared(int acquires) {
            for (;;) {
            	// 获取当前共享资源数量
                int available = getState();
                // 计算剩余共享资源数量
                int remaining = available - acquires;
                // 剩余资源非0时,采用CAS刷新当前资源数量
                if (remaining < 0 ||
                    compareAndSetState(available, remaining))
                    return remaining;
            }
        }
        // 尝试释放共享资源
        protected final boolean tryReleaseShared(int releases) {
            for (;;) {
                int current = getState();
                int next = current + releases;
                if (next < current) // overflow
                    throw new Error("Maximum permit count exceeded");
                if (compareAndSetState(current, next))
                    return true;
            }
        }
        // 减少共享资源
        final void reducePermits(int reductions) {
            for (;;) {
                int current = getState();
                int next = current - reductions;
                if (next > current) // underflow
                    throw new Error("Permit count underflow");
                if (compareAndSetState(current, next))
                    return;
            }
        }
        // 清理所有共享资源
        final int drainPermits() {
            for (;;) {
                int current = getState();
                if (current == 0 || compareAndSetState(current, 0))
                    return current;
            }
        }
    }

```

>使用`Semaphore`共享锁调用流程:
+ 使用`Semaphore.acquire()`获取资源
+ 通过`sync.acquireSharedInterruptibly(1)`获取同步资源(`AbstractQueuedSynchronizer.acquireSharedInterruptibly(int arg)`)
+ 通过公平锁或非公平锁获取资源`NonfairSync.tryAcquireShared(int acquires)`或`FairSync.tryAcquireShared(int acquires)`

```Semaphore
	public void acquire() throws InterruptedException {
		// 中断模式下获取共享资源
        sync.acquireSharedInterruptibly(1);
    }
```

```AbstractQueuedSynchronizer
    public final void acquireSharedInterruptibly(int arg)
            throws InterruptedException {
        // 线程是否被中断
        if (Thread.interrupted())
            throw new InterruptedException();
        // 尝试获取共享资源
        if (tryAcquireShared(arg) < 0)
            // 共享资源耗尽,中断获取操作
            doAcquireSharedInterruptibly(arg);
    }
```

```Sync
	final int nonfairTryAcquireShared(int acquires) {
		// 自旋获取共享资源
        for (;;) {
            int available = getState();
            int remaining = available - acquires;
            // 当前还剩余共享资源,调用CAS更新共享资源数量
            if (remaining < 0 ||
                compareAndSetState(available, remaining))
                return remaining;
        }
    }
```

```NonfairSync
	protected int tryAcquireShared(int acquires) {
        return nonfairTryAcquireShared(acquires);
    }

```

```FairSync
	protected int tryAcquireShared(int acquires) {
		// 自旋尝试获取共享资源
        for (;;) {
        	// 队列是否还有前驱结点(既是等待获取共享资源的线程)
            if (hasQueuedPredecessors())
                return -1;
            int available = getState();
            int remaining = available - acquires;
            // 当前还剩余共享资源,调用CAS更新共享资源数量
            if (remaining < 0 ||
                compareAndSetState(available, remaining))
                return remaining;
        }
    }

```

```AbstractQueuedSynchronizer
	private void doAcquireSharedInterruptibly(int arg)
        throws InterruptedException {
        // 封装当前线程为共享模式下的结点,返回的结点为队尾结点
        final Node node = addWaiter(Node.SHARED);
        boolean failed = true;
        try {
        	// 自旋
            for (;;) {
            	// 获取队尾结点的前驱结点
                final Node p = node.predecessor();
                // 队尾前驱结点为头结点,尝试获取共享资源
                if (p == head) {
                    int r = tryAcquireShared(arg);
                    if (r >= 0) {
                    	// 将当前线程结点设置为头结点并传播
                        setHeadAndPropagate(node, r);
                        p.next = null; // help GC
                        failed = false;
                        return;
                    }
                }
                // 调整同步队列中node结点的状态并判断是否应该被挂起,
                // 并判断是否需要中断,如果中断直接抛出异常,当前结点请求也就结束
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                    throw new InterruptedException();
            }
        } finally {
            if (failed)
                // 取消获取
                cancelAcquire(node);
        }
    }

    // 将当前线程封装成共享模式下的队列结点，并加入到队尾中
    private Node addWaiter(Node mode) {
    	// 封装结点
        Node node = new Node(Thread.currentThread(), mode);
        // Try the fast path of enq; backup to full enq on failure
        Node pred = tail;
        // 同步队列不为空,尝试快速插入队尾
        if (pred != null) {
            node.prev = pred;
            if (compareAndSetTail(pred, node)) {
                pred.next = node;
                return node;
            }
        }
        // 直接插入队尾
        enq(node);
        return node;
    }

    private void setHeadAndPropagate(Node node, int propagate) {
        Node h = head; // Record old head for check below
        setHead(node);
        /*
         * Try to signal next queued node if:
         *   Propagation was indicated by caller,
         *     or was recorded (as h.waitStatus either before
         *     or after setHead) by a previous operation
         *     (note: this uses sign-check of waitStatus because
         *      PROPAGATE status may transition to SIGNAL.)
         * and
         *   The next node is waiting in shared mode,
         *     or we don't know, because it appears null
         *
         * The conservatism in both of these checks may cause
         * unnecessary wake-ups, but only when there are multiple
         * racing acquires/releases, so most need signals now or soon
         * anyway.
         */
        if (propagate > 0 || h == null || h.waitStatus < 0 ||
            (h = head) == null || h.waitStatus < 0) {
            Node s = node.next;
            if (s == null || s.isShared())
                doReleaseShared();
        }
    }


    private static boolean shouldParkAfterFailedAcquire(Node pred, Node node) {
    	// 获取当前结点的等待状态
        int ws = pred.waitStatus;
        // 如果为等待唤醒状态则返回true
        if (ws == Node.SIGNAL)
            /*
             * This node has already set status asking a release
             * to signal it, so it can safely park.
             */
            return true;
        if (ws > 0) {
            /*
             * Predecessor was cancelled. Skip over predecessors and
             * indicate retry.
             */
            do {
                node.prev = pred = pred.prev;
            } while (pred.waitStatus > 0);
            pred.next = node;
        } else {
            /*
             * waitStatus must be 0 or PROPAGATE.  Indicate that we
             * need a signal, but don't park yet.  Caller will need to
             * retry to make sure it cannot acquire before parking.
             */
            compareAndSetWaitStatus(pred, ws, Node.SIGNAL);
        }
        return false;
    }

    private final boolean parkAndCheckInterrupt() {
    	// 挂起当前线程
        LockSupport.park(this);
        // 获取线程中断状态
        return Thread.interrupted();
    }

    private void cancelAcquire(Node node) {
        // Ignore if node doesn't exist
        if (node == null)
            return;

        node.thread = null;

        // Skip cancelled predecessors
        Node pred = node.prev;
        while (pred.waitStatus > 0)
            node.prev = pred = pred.prev;

        // predNext is the apparent node to unsplice. CASes below will
        // fail if not, in which case, we lost race vs another cancel
        // or signal, so no further action is necessary.
        Node predNext = pred.next;

        // Can use unconditional write instead of CAS here.
        // After this atomic step, other Nodes can skip past us.
        // Before, we are free of interference from other threads.
        node.waitStatus = Node.CANCELLED;

        // If we are the tail, remove ourselves.
        if (node == tail && compareAndSetTail(node, pred)) {
            compareAndSetNext(pred, predNext, null);
        } else {
            // If successor needs signal, try to set pred's next-link
            // so it will get one. Otherwise wake it up to propagate.
            int ws;
            if (pred != head &&
                ((ws = pred.waitStatus) == Node.SIGNAL ||
                 (ws <= 0 && compareAndSetWaitStatus(pred, ws, Node.SIGNAL))) &&
                pred.thread != null) {
                Node next = node.next;
                if (next != null && next.waitStatus <= 0)
                    compareAndSetNext(pred, predNext, next);
            } else {
                unparkSuccessor(node);
            }

            node.next = node; // help GC
        }
    }
```

而`Semaphore`释放流程与加锁过程相反;

通过对`Semaphore`代码查看，共享锁的实现，即`AQS`中通过`state`值来控制对共享资源访问的线程数，每当线程请求同步状态成功，`state`值将会减1，如果超过限制数量的线程将被封装共享模式的Node结点加入同步队列等待，直到其他执行线程释放同步状态，才有机会获得执行权，而每个线程执行完成任务释放同步状态后，`state`值将会增加1，这就是共享锁的基本实现模型。

至于公平锁与非公平锁的不同之处在于公平锁会在线程请求同步状态前，判断同步队列是否存在Node，如果存在就将请求线程封装成Node结点加入同步队列，从而保证每个线程获取同步状态都是先到先得的顺序执行的。

非公平锁则是通过竞争的方式获取，不管同步队列是否存在Node结点，只有通过竞争获取就可以获取线程执行权。
