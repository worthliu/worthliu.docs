## `HashMap`

除局部方法或绝对线程安全的情形外,优先推荐使用`ConcurrentHashMap`.

`HashMap`与其虽然性能相差无几,但是前者解决了高并发下的线程安全问题.

**`HashMap`的死链问题及扩容数据丢失问题时慎用`HashMap`的两个主要原因;**

先介绍一下`HashMap`体系种提到的三个基本存储概念:

名称|说明|
--|--|
`table`|存储所有节点数据的数组|
`slot`|哈希槽.即`table[i]`这个位置|
`bucket`|哈希桶.即`table[i]`上所有元素形成的表或树的集合|

### `HashMap.put()`

让我们看看`HashMap`新增元素过程:

```HashMap.put()
	public V put(K key, V value) {
        return putVal(hash(key), key, value, false, true);
    }
```

```HashMap.putVal()
    // 1.hash : key的hash值
    // 2.onlyIfAbsent : 如果为true,不改变已存在的值
    // 3.evict : 如果为false,数据表表示为创建模式
    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        // 若数据表为null或为空表,初始化数据表
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        // 通过hash值计算数据表位置,并检查是否目标位置是否存在节点
        if ((p = tab[i = (n - 1) & hash]) == null)
            // 不存在,创建新的结点存储
            tab[i] = newNode(hash, key, value, null);
        else {
        	// 存在
            Node<K,V> e; K k;
            // 获取已存在的结点,若hash且equals都相同直接取代
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            else if (p instanceof TreeNode)
                // 若当前结点是TreeNode,执行树结构插入
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
            	// 当前结点存在值时,以链表形式插入新结点
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        // 当链表长度超过TREEIFY_THRESHOLD时,变更结点结构为树结构
                        if (binCount >= TREEIFY_THRESHOLD - 1) 
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }

            // key已存在时,判断是否替换value值
            if (e != null) { 
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        // 
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }
```

```HashMap.resize()
	// 初始化或扩容数据表
    final Node<K,V>[] resize() {
        Node<K,V>[] oldTab = table;
        int oldCap = (oldTab == null) ? 0 : oldTab.length;
        int oldThr = threshold;
        // 新容量,新冲突阈值
        int newCap, newThr = 0;
        //
        if (oldCap > 0) {
        	// 容量已达到最大值不做扩容操作,直接返回
            if (oldCap >= MAXIMUM_CAPACITY) {
                threshold = Integer.MAX_VALUE;
                return oldTab;
            }
            // 新容量在旧容量基础上扩容2倍,只要不超过最大容量值且大于或等于初始容量大小
            else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                     oldCap >= DEFAULT_INITIAL_CAPACITY)
                // 阈值2倍扩容
                newThr = oldThr << 1; 
        }
        else if (oldThr > 0) 
            // 当原容量为空时,且阈值大于0,新容量为阈值
            newCap = oldThr;
        else {            
        	// 容量和阈值都为0时,初次初始化以默认设置进行
            newCap = DEFAULT_INITIAL_CAPACITY;
            newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
        }
        // 未设置新的阈值时,通过新的容量乘于加载因子计算
        if (newThr == 0) {
            float ft = (float)newCap * loadFactor;
            newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                      (int)ft : Integer.MAX_VALUE);
        }
        // 依据新容量,创建新的数据表
        threshold = newThr;
        Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
        table = newTab;
        // 创建新数据表后,重排数据元素位置
        if (oldTab != null) {
            for (int j = 0; j < oldCap; ++j) {
                Node<K,V> e;
                if ((e = oldTab[j]) != null) {
                    // 释放旧数据表元素
                    oldTab[j] = null;
                    // 
                    if (e.next == null)
                        // 结点无后继结点,直接计算新位置迁移即可
                        newTab[e.hash & (newCap - 1)] = e;
                    else if (e instanceof TreeNode)
                        // 当前数据元素结构为Tree Node
                        ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                    else { 
                    	// 当数据元素结构为链表时,由于新的容量以2倍进行扩容;
                        // 因此数据元素在新数据表将以高位低位均匀的分为两部分
                        Node<K,V> loHead = null, loTail = null;
                        Node<K,V> hiHead = null, hiTail = null;
                        Node<K,V> next;
                        // 链表循环,分隔元素位置
                        do {
                            next = e.next;
                            // 低位元素
                            if ((e.hash & oldCap) == 0) {
                                if (loTail == null)
                                    loHead = e;
                                else
                                    loTail.next = e;
                                loTail = e;
                            }
                            else {
                                if (hiTail == null)
                                    hiHead = e;
                                else
                                    hiTail.next = e;
                                hiTail = e;
                            }
                        } while ((e = next) != null);
                        // 低位元素数据位置不变
                        if (loTail != null) {
                            loTail.next = null;
                            newTab[j] = loHead;
                        }
                        // 高位元素数据位置对等递增
                        if (hiTail != null) {
                            hiTail.next = null;
                            newTab[j + oldCap] = hiHead;
                        }
                    }
                }
            }
        }
        return newTab;
    }
```