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
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
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
```