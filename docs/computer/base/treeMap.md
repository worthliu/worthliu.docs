## `TreeMap`

了解<a href="#/algorithm/redBlackTree" title="红黑树">`红黑树结构性质`</a>之后,`JDK`为我们提供了`TreeMap`的实现;

`TreeMap`是按照Key的排序结构来组织内部结构的`Map`类集合,它改变了`Map`类散乱无序的形象.

虽然`TreeMap`没有`ConcurrentHashMap`和`HashMap`普及(毕竟插入和删除的效率远没有后两者高),但是在key有排序要求的场景下,使用`TreeMap`可以事半功倍;

![MapClass.png](/images/MapClass.png)

在`TreeMap`的接口继承树中,有两个与众不同的接口:`SortMap`和`NavigableMap`.
+ `SortMap`接口表示它的`Key`是有序不可重复的,支持获取头尾`Key-Value`元素,或者根据`Key`指定范围获取子集等;
  + 插入的`Key`必须实现`Comparable`或者提供额外的比较器`Comparator`;
  + `Key`不允许为null,但是`Value`可以为null;
+ `NavigableMap`继承了`SortMap`接口,根据指定的搜索条件返回最匹配的`Key-Value`元素;

>**`HashMap`是使用`hashCode`和`equals`实现去重的.而`TreeMap`依靠`Comparable`或者`Comparator`来实现`Key`去重;**

```TreeMap
public class TreeMap<K,V>
    extends AbstractMap<K,V>
    implements NavigableMap<K,V>, Cloneable, java.io.Serializable
{
	// 内部比较器用于Key去重,且Key不能为null
    private final Comparator<? super K> comparator;

    private transient Entry<K,V> root;

    private static final boolean RED   = false;
    private static final boolean BLACK = true;

    // 红黑树Map内部节点结构
    static final class Entry<K,V> implements Map.Entry<K,V> {
        K key;
        V value;
        Entry<K,V> left;
        Entry<K,V> right;
        Entry<K,V> parent;
        boolean color = BLACK;
    }
}
```

`TreeMap`通过`put()`和`deleteEntry()`实现红黑树的增加和删除节点操作:

在插入节点之前,需要明确三个前提条件:

+ 需要调整的新节点总是红色;
+ 如果插入新节点的父节点是黑色,无需调整;
+ 如果插入新节点的父节点是红色的,因为红黑树规定不能出现相邻的两个红色节点,所以进入循环判断,或重新着色,或左右旋,最终达到红黑树的五个约束条件;
  + 其退出条件: `while (x != null && x != root && x.parent.color == RED) `
    + 如果是根节点,则直接退出,设置为黑色即可;
    + 如果不是根节点,并且父节点为红色,会一直进行调整,直到退出循环;

### `TreeMap.put()`

```TreeMap
    // 塞入节点
	public V put(K key, V value) {
		// t为当前节点,并将根节点引用赋值给t
        Entry<K,V> t = root;
        // 如果当前节点为null,即是空树,新增key-value形成的节点就是根节点
        if (t == null) {
        	// 校验key是否有可比性
            compare(key, key); // type (and possibly null) check
            // 使用kv构造新的Entry对象,包括父节点
            root = new Entry<>(key, value, null);
            size = 1;
            modCount++;
            return null;
        }
        // key比较结果
        int cmp;
        Entry<K,V> parent;
        // 外部比较器
        Comparator<? super K> cpr = comparator;
        if (cpr != null) {
        	// 循环查找目标key插入的位置
            do {
                parent = t;
                cmp = cpr.compare(key, t.key);
                // 小于,目标位置位于左子节点下
                if (cmp < 0)
                    t = t.left;
                else if (cmp > 0)
                // 大于,目标位置位于右子节点下
                    t = t.right;
                else
                // 相等时,覆盖原来节点的value
                    return t.setValue(value);
            } while (t != null);
        }
        else {
        	// 内部比较器,key不能为null
            if (key == null)
                throw new NullPointerException();
            // 
            Comparable<? super K> k = (Comparable<? super K>) key;
            do {
                parent = t;
                cmp = k.compareTo(t.key);
                if (cmp < 0)
                    t = t.left;
                else if (cmp > 0)
                    t = t.right;
                else
                    return t.setValue(value);
            } while (t != null);
        }
        // 创建Entry对象,并把父节点parent带入
        Entry<K,V> e = new Entry<>(key, value, parent);
        // 依据比较结构,将新增节点置于左右子节点中
        if (cmp < 0)
            parent.left = e;
        else
            parent.right = e;
        // 对新节点进行调整,重新着色和旋转操作,以达到平衡(红黑树5种约束)
        fixAfterInsertion(e);
        // 最终融入其中
        size++;
        modCount++;
        return null;
    }

    // 对新增节点进行平衡调整
    private void fixAfterInsertion(Entry<K,V> x) {
    	// 新增节点颜色一律先赋值为红色
        x.color = RED;
        // 1. 新节点是根节点或者其父节点为黑色时,无须调整
        // 2. 插入红色节点并不会破坏红黑树性质时,无须调整
        // 新增节点x用红色显示,通过不断地向上遍历(或内部调整),直到父节点为黑色或者到达根节点
        while (x != null && x != root && x.parent.color == RED) {

        	// 其父节点是其爷爷节点的左子节点
            if (parentOf(x) == leftOf(parentOf(parentOf(x)))) {
            	// 查看其爷爷节点的右子节点颜色
                Entry<K,V> y = rightOf(parentOf(parentOf(x)));
                // 其右叔叔节点颜色为红色时,局部调整
                if (colorOf(y) == RED) {
                	// 父节点与右叔叔节点都设置为黑色
                    setColor(parentOf(x), BLACK);
                    setColor(y, BLACK);
                    // 爷爷节点设置为红色
                    setColor(parentOf(parentOf(x)), RED);
                    // 爷爷节点成为起点,再次循环
                    x = parentOf(parentOf(x));
                } else {
                	// 若右叔叔节点为黑色,则需要加入旋转操作
                	// 如果x节点是父节点的右子节点,先对父节点做左旋操作
                	// 转化x是父节点的左子节点的情形
                    if (x == rightOf(parentOf(x))) {
                    	// 对父节点做一次左旋操作,红色父节点会沉入其左侧位置
                        x = parentOf(x);
                        // 父节点为起点进行左旋操作
                        rotateLeft(x);
                    }
                    // 父节点设置为黑色
                    setColor(parentOf(x), BLACK);
                    // 爷爷节点设置为红色
                    setColor(parentOf(parentOf(x)), RED);
                    // 爷爷节点为起点进行右旋操作
                    rotateRight(parentOf(parentOf(x)));
                }
            } else { // 如果父节点是其爷爷节点的右子节点
            	// 获取其爷爷节点左子节点
                Entry<K,V> y = leftOf(parentOf(parentOf(x)));
                // 左叔叔节点颜色为红色
                if (colorOf(y) == RED) {
                	// 将父节点和左叔叔节点都设置为黑色
                    setColor(parentOf(x), BLACK);
                    setColor(y, BLACK);
                    // 其爷爷节点设置为红色
                    setColor(parentOf(parentOf(x)), RED);
                    // 其爷爷节点为新起点,继续循环
                    x = parentOf(parentOf(x));
                } else {
                	// 左叔叔节点为黑色
                	// 如果x节点是父节点的左节点,先对父节点做右旋操作
                    if (x == leftOf(parentOf(x))) {
                    	// 对父节点做一次右旋操作,红色父节点会沉入其右侧位置
                        x = parentOf(x);
                        rotateRight(x);
                    }
                    // 重新着色,并对其爷爷节点左旋操作
                    setColor(parentOf(x), BLACK);
                    setColor(parentOf(parentOf(x)), RED);
                    rotateLeft(parentOf(parentOf(x)));
                }
            }
        }
        root.color = BLACK;
    }
```

```TreeMap.rotateLeft
    // 左旋操作
    private void rotateLeft(Entry<K,V> p) {
    	// 节点不为空
        if (p != null) {
        	// 获取p节点的右子节点r
            Entry<K,V> r = p.right;
            // 将r的左子节点设置为p的右子树
            p.right = r.left;

            // 若r的左子节点不为空,则将p设置为r左子节点的父节点 
            if (r.left != null)
                r.left.parent = p;

            // 将p的父节点设置为r的父节点
            r.parent = p.parent;

            //  r取代p的父节点位置
            if (p.parent == null)
                root = r;
            else if (p.parent.left == p)
                p.parent.left = r;
            else
                p.parent.right = r;
            
            // 将p设置为r的左子树,将r设置为p的父节点
            r.left = p;
            p.parent = r;
        }
    }
```

```TreeMap.rotateRight
    // 右旋操作
    private void rotateRight(Entry<K,V> p) {
        if (p != null) {
        	// 获取p的左子节l
            Entry<K,V> l = p.left;
            // 将l的右子树取代p的左子树
            p.left = l.right;

            // 若l的右子节不为空,则将p设置为l右子节点的父节点
            if (l.right != null) l.right.parent = p;

            // 将p的父节点设置为l的父节点
            l.parent = p.parent;

            // 
            if (p.parent == null)
                root = l;
            else if (p.parent.right == p)
                p.parent.right = l;
            else p.parent.left = l;

            // 将p设置为l的右子树,将l设置为p的父节点
            l.right = p;
            p.parent = l;
        }
    }
```
```TreeMap.tool
    // 获取目标节点的父节点
    private static <K,V> Entry<K,V> parentOf(Entry<K,V> p) {
        return (p == null ? null: p.parent);
    }
    // 获取目标节点的左子节点
    private static <K,V> Entry<K,V> leftOf(Entry<K,V> p) {
        return (p == null) ? null: p.left;
    }
    // 获取目标节点的右子节点
    private static <K,V> Entry<K,V> rightOf(Entry<K,V> p) {
        return (p == null) ? null: p.right;
    }
    // 获取目标节点的颜色,若为null,默认为黑色
    private static <K,V> boolean colorOf(Entry<K,V> p) {
        return (p == null ? BLACK : p.color);
    }
```

### `TreeMap.deleteEntry()`


```TreeMap.remove()
    // 删除节点
    public V remove(Object key) {
        // 获取节点
        Entry<K,V> p = getEntry(key);
        if (p == null)
            return null;

        V oldValue = p.value;
        // 删除目标节点
        deleteEntry(p);
        return oldValue;
    }
```

```TreeMap.getEntry()
    final Entry<K,V> getEntry(Object key) {
        // 出于性能考虑，卸载基于外部比较器的版本
        if (comparator != null)
            return getEntryUsingComparator(key);

        // key不允许为null
        if (key == null)
            throw new NullPointerException();

        // 内部比较器, 从根节点出发,依据比较结果向左右节点查找目标key节点
        Comparable<? super K> k = (Comparable<? super K>) key;
        Entry<K,V> p = root;
        while (p != null) {
            int cmp = k.compareTo(p.key);
            if (cmp < 0)
                p = p.left;
            else if (cmp > 0)
                p = p.right;
            else
                return p;
        }
        return null;
    }

    // 基于外部比较器获取节点对象
    final Entry<K,V> getEntryUsingComparator(Object key) {
        K k = (K) key;
        Comparator<? super K> cpr = comparator;
        if (cpr != null) {
            // 从根节点出发,依据比较结果向左右节点查找目标key节点
            Entry<K,V> p = root;
            while (p != null) {
                int cmp = cpr.compare(k, p.key);
                if (cmp < 0)
                    p = p.left;
                else if (cmp > 0)
                    p = p.right;
                else
                    return p;
            }
        }
        return null;
    }
```

```TreeMap.deleteEntry()
    private void deleteEntry(Entry<K,V> p) {
        modCount++;
        size--;

        // 目标节点左右子节点都不为空时
        // 将其后继节点复制到p,然后让p指向后继节点
        // point to successor.
        if (p.left != null && p.right != null) {
            Entry<K,V> s = successor(p);
            p.key = s.key;
            p.value = s.value;
            p = s;
        } // p has 2 children

        // 获取取代p节点位置replace节点(先左后右)
        Entry<K,V> replacement = (p.left != null ? p.left : p.right);

        if (replacement != null) {
            // 先提升replace节点父节点位置, 取代p位置
            replacement.parent = p.parent;
            
            // 顶级节点即根节点,p节点原位置在哪里,取代节点也在哪里
            if (p.parent == null)
                root = replacement;
            else if (p == p.parent.left)
                p.parent.left  = replacement;
            else
                p.parent.right = replacement;

            // 清除p节点链接
            p.left = p.right = p.parent = null;

            // p节点为黑色时,直接进行调整取代节点
            if (p.color == BLACK)
                fixAfterDeletion(replacement);
        } else if (p.parent == null) { 
            
            // 红黑树只有一个节点时,删除节点后只余空树
            root = null;
        } else { // 没有下级关联节点时
            
            // p节点为黑色时,直接调整红黑树结构
            if (p.color == BLACK)
                fixAfterDeletion(p);

            // p父节点存在时,剔除p节点位置
            if (p.parent != null) {
                if (p == p.parent.left)
                    p.parent.left = null;
                else if (p == p.parent.right)
                    p.parent.right = null;
                p.parent = null;
            }
        }
    }
```

```TreeMap.fixAfterDeletion()
    // 删除后进行红黑树调整
    private void fixAfterDeletion(Entry<K,V> x) {
        // 1.根节点,无须调整
        // 2.红色节点,无须调整,只需重新着色即可
        while (x != root && colorOf(x) == BLACK) {
            // x节点为左节点时
            if (x == leftOf(parentOf(x))) {
                // 获取x的右节点sib
                Entry<K,V> sib = rightOf(parentOf(x));

                // 右节点sib若为红色节点时,
                if (colorOf(sib) == RED) {
                    // 变为黑色节点
                    setColor(sib, BLACK);
                    // 父节点变成红色并下沉为左节点
                    setColor(parentOf(x), RED);
                    rotateLeft(parentOf(x));

                    sib = rightOf(parentOf(x));
                }
                // 左右节点都为黑色,向上调整父节点
                if (colorOf(leftOf(sib))  == BLACK &&
                    colorOf(rightOf(sib)) == BLACK) {
                    setColor(sib, RED);
                    x = parentOf(x);
                } else {
                    if (colorOf(rightOf(sib)) == BLACK) {
                        setColor(leftOf(sib), BLACK);
                        setColor(sib, RED);
                        rotateRight(sib);
                        sib = rightOf(parentOf(x));
                    }
                    setColor(sib, colorOf(parentOf(x)));
                    setColor(parentOf(x), BLACK);
                    setColor(rightOf(sib), BLACK);
                    rotateLeft(parentOf(x));
                    x = root;
                }
            } else { // 对称操作
                Entry<K,V> sib = leftOf(parentOf(x));

                if (colorOf(sib) == RED) {
                    setColor(sib, BLACK);
                    setColor(parentOf(x), RED);
                    rotateRight(parentOf(x));
                    sib = leftOf(parentOf(x));
                }

                if (colorOf(rightOf(sib)) == BLACK &&
                    colorOf(leftOf(sib)) == BLACK) {
                    setColor(sib, RED);
                    x = parentOf(x);
                } else {
                    if (colorOf(leftOf(sib)) == BLACK) {
                        setColor(rightOf(sib), BLACK);
                        setColor(sib, RED);
                        rotateLeft(sib);
                        sib = leftOf(parentOf(x));
                    }
                    setColor(sib, colorOf(parentOf(x)));
                    setColor(parentOf(x), BLACK);
                    setColor(leftOf(sib), BLACK);
                    rotateRight(parentOf(x));
                    x = root;
                }
            }
        }

        setColor(x, BLACK);
    }
```

```TreeMap.successor()
    // 获取目标节点后继节点
    static <K,V> TreeMap.Entry<K,V> successor(Entry<K,V> t) {
        
        if (t == null) // 目标节点为null,直接返回null
            return null;
        else if (t.right != null) { // 右子节不为null时
            // 取得其右子节点
            Entry<K,V> p = t.right;
            // 取到t节点的右子节p的左叶子节点
            while (p.left != null)
                p = p.left;
            return p;
        } else { // 右子节为null
            // 获取t节点的父节点p
            Entry<K,V> p = t.parent;
            Entry<K,V> ch = t;
            // 取得根节点或次级根节点??
            while (p != null && ch == p.right) {
                ch = p;
                p = p.parent;
            }
            return p;
        }
    }
```