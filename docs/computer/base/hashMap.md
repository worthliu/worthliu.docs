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
            tab[i] = newNode(hash, key, value, null);// 不安全
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
            	// 当前结点存在值时,以链表形式,在链尾插入新结点
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);// 不安全
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

如上源码中,新添加元素直接放在`slot`槽上,使新添加的元素在下次提取时可以更快地被访问到;如果两个线程同时执行到第1处时,那么一个线程的赋值就会被另一个覆盖掉,这是`对象丢失`的原因之一;

### `HashMap.resize()`

名称|说明|
--|--|
`length`|`table`数组长度|
`size`|成功通过`put`方法添加到`HashMap`中所有的元素|
`hashCode`|`Object.hashCode()`返回的`int`值,尽可能地离散均匀分布|
`hash`|`Object.hashCode()`与当前集合的`table.length`进行位运算的结果,以确定哈希槽的位置|

对于理想的哈希集合对象的存放应该符合:
+ 只要对象不一样,`hashCode`就不一样
+ 只要`hashCode`不一样,得到的`hashCode`与`hashSeed`位运算的`hash`就不一样
+ 只要`hash`不一样,存放在数组上的`slot`就不一样

由于理想与实际的差异,哈希表大小是比较固定,通过不断扩容以满足元素增加需求;那么什么时候才需要进行扩容呢?

**负载因子是用以权衡资源利用率与分配空间的系数.默认的负载因子是`0.75`;当`元素数量 > 容量*负载因子`时会进行扩容;**

在`HashMap`中,每次进行`resize()`操作都会将容量扩充为原来的2倍;

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
            // 新容量在旧容量基础上扩容2倍,只要不超过最大容量值,且大于或等于初始容量大小
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
                    // 释放旧数据表
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
                        // 链表循环,分隔元素位置,逆序迁移元素到新的元素位置中
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

`HashMap`中数组非常大时,进行数据迁移会非常消耗资源.当前线程迁移过程中,其他线程新增的元素有可能落在已经遍历过的哈希槽上;在遍历完成之后,`table`数组引用指向了`newTable`,这时新增元素就会丢失,被无情地垃圾回收;

如果`resize()`过程中,执行了`table = newTab;`,则后续的元素就可以在新表上进行插入操作;

但是如果多个线程同时执行`resize()`,每个线程又都会`(Node<K,V>[])new Node[newCap]`,这是线程内的局部数组对象,线程之间时不可见的.

迁移过程中,不同线程的`resize()`操作,共同赋值给`table`线程共享变量,从而覆盖其他线程的操作,因此在新表中进行插入操作的对象会被无情地丢弃;

>新增对象丢失原因:
+ 并发赋值时被覆盖
+ 已遍历区间新增元素会丢失
+ "新表"被覆盖
+ 迁移丢失