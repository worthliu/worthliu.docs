## `Semaphore`

信号量(`Semaphore`)，在多线程环境下用于协调各个线程, 以保证它们能够正确、合理的使用公共资源。

信号量维护了一个许可集，我们在初始化`Semaphore`时需要为这个许可集传入一个数量值，该数量值代表同一时间能访问共享资源的线程数量。

**线程可以通过`acquire()`方法获取到一个许可，然后对共享资源进行操作，注意如果许可集已分配完了，那么线程将进入等待状态，直到其他线程释放许可才有机会再获取许可，线程释放一个许可通过`release()`方法完成。**


`Semaphore`即可用于实现共享锁又可实现互斥锁,区别在于许可数量;

### `Semaphore`内部原理

在看看`Semaphore`实现前,我们先来看看内部类的结构:

![Semaphore](/images/Semaphore.png)

从上述看到`Semaphore`的类结构与`ReentrantLock`类结构基本一致;同样是在继承自`AQS`的内部类`Sync`以及继承自`Sync`的公平锁(`FairSync`)和非公平锁(`NofairSync`)的实现;

就`Semaphore`而言,一般使用示例如下:

```
	class RunnableDemo implements Runnable{

        private Semaphore sp;

        public RunnableDemo(Semaphore sp) {
            this.sp = sp;
        }

        @Override
        public void run() {
            try{
            	// 获取共享资源
                sp.acquire();
                System.out.println(String.format("[Thread-%s]任务id|已获取得到共享资源,剩余共享资源数量:[%d]",Thread.currentThread().getId(), sp.availablePermits()));
                Thread.sleep(300);
            }catch (Exception e){
                e.printStackTrace();
            }finally {
            	// 释放共享资源
                sp.release();
                System.out.println(String.format("[Thread-%s]任务id|释放共享资源数量,当前共享资源数量:[%d]",Thread.currentThread().getId(), sp.availablePermits()));
            }
        }
    }
```

>从上述实例代码中,使用`Semaphore`共享锁调用流程如下:
+ 使用`Semaphore.acquire()`获取资源
+ 通过`sync.acquireSharedInterruptibly(1)`获取同步资源(`AbstractQueuedSynchronizer.acquireSharedInterruptibly(int arg)`)
+ 通过公平锁或非公平锁获取资源`NonfairSync.tryAcquireShared(int acquires)`或`FairSync.tryAcquireShared(int acquires)`

对于内部实现而言,`Sync`基于`AQS`组件实现共享锁提供对外方法应用,具体实现如下:

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

而`Semaphore`释放流程与加锁过程相反:

>从上述实例代码中,使用`Semaphore`共享锁释放调用流程如下:
+ 使用`Semaphore.release()`释放资源
+ 通过`sync.releaseShared(1)`获取同步资源(`AbstractQueuedSynchronizer.releaseShared(int arg)`)
+ 通过公平锁或非公平锁获取资源`NonfairSync.tryAcquireShared(int acquires)`或`FairSync.tryAcquireShared(int acquires)`

```Semaphore
	public void release() {
		// 释放共享资源
        sync.releaseShared(1);
    }
```

```Sync
	protected final boolean tryReleaseShared(int releases) {
		// 自旋
        for (;;) {
        	// 获取当前资源同步状态
            int current = getState();
            // 计算释放后同步状态值
            int next = current + releases;
            if (next < current) // overflow
                throw new Error("Maximum permit count exceeded");
            // 采用CAS更新当前共享状态值
            if (compareAndSetState(current, next))
                return true;
        }
    }
```

```AbstractQueuedSynchronizer
	public final boolean releaseShared(int arg) {
		// 尝试释放资源同步状态
        if (tryReleaseShared(arg)) {
        	// 同步状态释放成功,进行资源释放
            doReleaseShared();
            return true;
        }
        return false;
    }

    // 
    private void doReleaseShared() {
        /*
         * 确保释放操作传播出去,即使当前没有正在执行的请求/释放动作;
         * 如果头结点后续结点需要唤醒信号,那么就执行唤醒操作;
         * 如果不需要,将status设置为PROPAGATE确保后续释放,继续传播;
         * 此外,我们必须循环操作,防止有新的结点加入队列在我们执行操作的时候;
         * 而且,不同于其他使用unparkSuccessor操作,我们需要知道CAS重置状态是否失败,是否重新检查;
         */

        // 自旋操作
        for (;;) {
        	// 获取头结点
            Node h = head;
            // 同步队列存在其他结点
            if (h != null && h != tail) {
            	// 获取头结点等待状态
                int ws = h.waitStatus;
                // 若头结点等待状态为SIGNAL状态
                if (ws == Node.SIGNAL) {
                	// 设置头结点线程状态为0,循环处理直至成功
                    if (!compareAndSetWaitStatus(h, Node.SIGNAL, 0))
                        continue;            // loop to recheck cases
                    // 唤醒头结点的后续结点所对应的线程
                    unparkSuccessor(h);
                }
                else if (ws == 0 &&
                         !compareAndSetWaitStatus(h, 0, Node.PROPAGATE))
                    continue;                // loop on failed CAS
            }
            // 如果头结点发生变化,则继续循环
            if (h == head)                   // loop if head changed
                break;
        }
    }

    private static final boolean compareAndSetWaitStatus(Node node,
                                                         int expect,
                                                         int update) {
        return unsafe.compareAndSwapInt(node, waitStatusOffset,
                                        expect, update);
    }

    // 唤醒传入结点的后续结点对应线程
    private void unparkSuccessor(Node node) {
        // 如果状态为负值,尝试清除预期信号. 
        // 如果状态设置失败或者状态已被其他线程更改,则无需理会;
        int ws = node.waitStatus;
        if (ws < 0)
            compareAndSetWaitStatus(node, ws, 0);

        // 唤醒传入结点后继结点.但是如果后继结点为取消状态或为空;
        // 从同步队列队尾往前找寻未被取消的后继结点; 
        Node s = node.next;
        if (s == null || s.waitStatus > 0) {
            s = null;
            for (Node t = tail; t != null && t != node; t = t.prev)
                if (t.waitStatus <= 0)
                    s = t;
        }
        // 唤醒线程
        if (s != null)
            LockSupport.unpark(s.thread);
    }
```


通过对`Semaphore`代码查看，共享锁的实现，即`AQS`中通过`state`值来控制对共享资源访问的线程数，每当线程请求同步状态成功，`state`值将会减1，如果超过限制数量的线程将被封装共享模式的Node结点加入同步队列等待，直到其他执行线程释放同步状态，才有机会获得执行权，而每个线程执行完成任务释放同步状态后，`state`值将会增加1，这就是共享锁的基本实现模型。

至于公平锁与非公平锁的不同之处在于公平锁会在线程请求同步状态前，判断同步队列是否存在`Node`，如果存在就将请求线程封装成Node结点加入同步队列，从而保证每个线程获取同步状态都是先到先得的顺序执行的。

非公平锁则是通过竞争的方式获取，不管同步队列是否存在`Node`结点，只有通过竞争获取就可以获取线程执行权。
