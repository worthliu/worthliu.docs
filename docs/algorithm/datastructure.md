## 数据结构

在代码的世界里,数据是程序运行的血液,而数据结构是数据承担的基石;

>那么数据结构到底什么呢?

**数据结构是指`逻辑意义`上的`数据组织方式`及其相应的`处理方式`;**

>数据结构分类
+ 线性结构,0至1个直接前继和直接后继;
  + 当线性结构非空时,有唯一的首元素和尾元素;
+ 树结构,0至1个直接前继和0至n个直接后继(n大于或等于2);
+ 图结构,0至n个直接前继和直接后继(n大于或等于2);
+ 哈希结构,没有直接前继和直接后继;

## 集合框架图

Java中的集合是用于与存储对象的工具类容器,它实现了常用的数据结构,提供了一系列公开的方法用于增加,删除,修改,查找和遍历数据,降低了日常开发成本;

![集合类类图](/images/set.png)

**在集合框架图中,红色代表接口,蓝色代表抽象类,绿色代表并发包中的类,灰色代表早期线程安全的类.**

可以看到,从`Collection`衍生出来四种类型,分别是`List`,`Queue`,`Set`,`Map`,它们的之列会映射到数据结构中的表,树,哈希等;

### `List`集合

`List`集合是线性数据结构的主要实现,集合元素通常存在明确的直接前继和直接后继;也存在明确的首元素和尾元素;

`List`集合的遍历结果是稳定的;最常用的是`ArrayList`和`LinkedList`;

>+ `ArrayList`是容量可以改变的非线程安全的集合类;
  + 内部实现的使用**数组进行存储**;
  + 集合扩容时会创建更大的**数组空间**,把原来数据复制到新数组中.
  + `ArrayList`支持对元素的快速随机访问,但是插入与删除时速度通常很慢;

>+ `LinkedList`本质上是双链表;
  + `LinkedList`的插入和删除速度更快,但是随机访问速度则很慢;
  + `LinkedList`还实现了另一个接口`Deque`(`double-ended queue`),这个接口同时具有队列和栈的性质;

### `Queue`集合

`Queue`队列是一种先进先出的数据结构,队列是一种特殊的线性表,它只允许在表的一端进行获取操作,在表的另一端进行插入操作;


### `Map`集合

`Map`集合以`key-value`键值对作为存储元素实现的哈希结构,`key`按某种哈希函数计算后是唯一的,`Value`则是可以重复;

>+ 线程安全`HashTable`,因为性能问题被淘汰;
+ 线程不安全`HashMap`
+ 线程安全`ConcurrentHashMap`,`JDK8`中进行大幅度锁优化,体现出不错的性能;

### `Set`集合

`Set`集合是不允许出现重复元素的集合类型.

`Set`体系最常用的是`HashSet`,`TreeSet`,`LinkedHashSet`三个集合类;

>+ `HashSet`从源码分析是使用`HashMap`来实现的,只是`Value`固定为一个静态对象,使用`Key`保证集合元素的唯一性,但它不保证集合元素的顺序;
+ `TreeSet`也是如此,从源码分析使用`TreeMap`来实现的,底层为树结构,在添加新元素到集合中时,按照某种比较规则将其插入合适的位置,保证插入后的集合仍然是有序;
+ `LinkedHashSet`继承自`HashSet`,具有`HashSet`的优点,内部使用链表维护了元素插入顺序;

## 集合初始化

集合初始化通常进行分配容量,设置特定参数等相关工作;

以`ArrayList`,`HashMap`作为介绍;

### `ArrayList`

```ArrayList
public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable {
    // 默认容量大小
	private static final int DEFAULT_CAPACITY = 10;
	// 空表
	private static final Object[] EMPTY_ELEMENTDATA = {};
	// 默认空表
    private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};
    // 底层数组
    transient Object[] elementData;
    // 元素数量
    private int size;


	public ArrayList(int initialCapacity) {
        if (initialCapacity > 0) {
        	// 初始化大小大于0时,根据构造方法的参数值,创建一个相应容量大小的数组
            this.elementData = new Object[initialCapacity];
        } else if (initialCapacity == 0) {
            this.elementData = EMPTY_ELEMENTDATA;
        } else {
            throw new IllegalArgumentException("Illegal Capacity: "+
                                               initialCapacity);
        }
    }


    public boolean add(E e) {
    	// 确认内部容量充足
        ensureCapacityInternal(size + 1);  // Increments modCount!!
        // 添加元素到相应数组位置
        elementData[size++] = e;
        return true;
    }

    private void ensureCapacityInternal(int minCapacity) {
    	// 判断元素是否为空表
        if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
        	// 获取容量大小
            minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);
        }
        // 获取明确的容量
        ensureExplicitCapacity(minCapacity);
    }

    private void ensureExplicitCapacity(int minCapacity) {
        // 结构性变化计数
        modCount++;

        // 原有容量不足时进行扩容操作
        if (minCapacity - elementData.length > 0)
            grow(minCapacity);
    }


    private void grow(int minCapacity) {
        // 防止扩容1.5倍之后,超过int的表示范围 (第1处)
        int oldCapacity = elementData.length;
        // 以元素数作为容量基数,扩容1.5
        int newCapacity = oldCapacity + (oldCapacity >> 1);
        // 若扩容后容量比真是所需容量小,则以真实容量为准
        if (newCapacity - minCapacity < 0)
            newCapacity = minCapacity;
        // 若扩容后容量比VM最大数组容量大,计算最大容量值
        if (newCapacity - MAX_ARRAY_SIZE > 0)
            newCapacity = hugeCapacity(minCapacity);
        // 复制一个新容量大小数组
        elementData = Arrays.copyOf(elementData, newCapacity);
    }

    private static int hugeCapacity(int minCapacity) {
    	// 所需扩容的真实容量小于0,意味着以元素数作为基数计算后扩容容量数为负数;
    	// 即容量值已经达到溢出边界,直接抛出溢出异常信号
        if (minCapacity < 0) // overflow
            throw new OutOfMemoryError();
        // 获取数组最大容量数
        return (minCapacity > MAX_ARRAY_SIZE) ?
            Integer.MAX_VALUE :
            MAX_ARRAY_SIZE;
    }

}
```

`ArrayList`扩容时,由于正数带符号右移的值肯定时正值,所以`oldCapacity + (oldCapacity >> 1)`的结果可能超过`int`可以表示的最大值,反而有可能比参数的`minCapacity`更小,则返回值为`minCapacity(size+1)`;

当`ArrayList`使用无参构造时,默认大小为10,在第一次调用`add()`的时候,分配为10的容量;

后续的每次扩容都会调用`Array.copyof()`方法,创建新数组再复制;

假如需要将1000个元素放置在`ArrayList`中,采用默认构造方法,则需要被动扩容`13次`才可以完成存储.反之,如果在初始化时便指定了容量`new ArrayList(1000)`,那么在初始化`ArrayList`对象的时候就直接分配`1000`个存储空间,从而避免被动扩容和数组复制的额外开销; 

### `HashMap`

>在`HashMap`中有两个比较重要的参数:`Capacity`和`Load Factor`:
+ `Capacity`决定了存储容量的大小,默认为16;
+ `Load Factor`决定了填充比例,一般使用默认的`0.75`;

基于这两个参数的乘积,`HashMap`内部用`threshold`变量表示`HashMap`中能放入的元素个数.


```HashMap
public class HashMap<K,V> extends AbstractMap<K,V>
    implements Map<K,V>, Cloneable, Serializable {

    static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16
    static final float DEFAULT_LOAD_FACTOR = 0.75f;

    public HashMap() {
        this.loadFactor = DEFAULT_LOAD_FACTOR; // all other fields defaulted
    }

    // 存储元素
    public V put(K key, V value) {
        return putVal(hash(key), key, value, false, true);
    }

    /**
    * onlyIfAbsent 若为true时,不改变已存在键值
    * evict 若为false时,底层数据表处于创建模式
    */
    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        // 若数据表为null或为空表,初始化数据表
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        // 通过hash值计算数据表位置,检查是否目标位置是否存在值
        if ((p = tab[i = (n - 1) & hash]) == null)
            // 不存在,创建新的结点存储
            tab[i] = newNode(hash, key, value, null);
        else {
        	// 存在
            Node<K,V> e; K k;
            // 获取已存在的结点
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
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }

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
                    	// 当数据元素结构为链表时,由于新的容量以2倍进行扩容,因此数据元素在新数据表将以高位低位均匀的分为两部分
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


    /**
     * Tree version of putVal.
     */
    final TreeNode<K,V> putTreeVal(HashMap<K,V> map, Node<K,V>[] tab,
                                   int h, K k, V v) {
        Class<?> kc = null;
        boolean searched = false;
        TreeNode<K,V> root = (parent != null) ? root() : this;
        // 
        for (TreeNode<K,V> p = root;;) {
            int dir, ph; K pk;
            if ((ph = p.hash) > h)
                dir = -1;
            else if (ph < h)
                dir = 1;
            else if ((pk = p.key) == k || (k != null && k.equals(pk)))
                return p;
            else if ((kc == null &&
                      (kc = comparableClassFor(k)) == null) ||
                     (dir = compareComparables(kc, k, pk)) == 0) {
                if (!searched) {
                    TreeNode<K,V> q, ch;
                    searched = true;
                    if (((ch = p.left) != null &&
                         (q = ch.find(h, k, kc)) != null) ||
                        ((ch = p.right) != null &&
                         (q = ch.find(h, k, kc)) != null))
                        return q;
                }
                dir = tieBreakOrder(k, pk);
            }
            // 
            TreeNode<K,V> xp = p;
            if ((p = (dir <= 0) ? p.left : p.right) == null) {
                Node<K,V> xpn = xp.next;
                TreeNode<K,V> x = map.newTreeNode(h, k, v, xpn);
                if (dir <= 0)
                    xp.left = x;
                else
                    xp.right = x;
                xp.next = x;
                x.parent = x.prev = xp;
                if (xpn != null)
                    ((TreeNode<K,V>)xpn).prev = x;
                moveRootToFront(tab, balanceInsertion(root, x));
                return null;
            }
        }
    }

    final void treeifyBin(Node<K,V>[] tab, int hash) {
        int n, index; Node<K,V> e;
        // 
        if (tab == null || (n = tab.length) < MIN_TREEIFY_CAPACITY)
            resize();
        else if ((e = tab[index = (n - 1) & hash]) != null) {
            TreeNode<K,V> hd = null, tl = null;
            // 转换数据元素结点为树结点
            do {
                TreeNode<K,V> p = replacementTreeNode(e, null);
                if (tl == null)
                    hd = p;
                else {
                    p.prev = tl;
                    tl.next = p;
                }
                tl = p;
            } while ((e = e.next) != null);
            //
            if ((tab[index] = hd) != null)
                hd.treeify(tab);
        }
    }
}
```