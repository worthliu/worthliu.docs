## 红黑树

### 树

树是一种常用的数据结构,它是一个由有限节点组成的一个具有层次关系的集合,数据就存在树的这些节点中.

>树结构特点:
+ 一个节点,即只有根节点,也可以是一棵树;
+ 其中任何一个节点与下面所有节点构成的树称为子树;
+ 根节点没有父节点,而叶子节点没有子节点;
+ 除根节点外,任何节点有且仅有一个父节点;
+ 任何节点可以有`0~n`个子节点;

### 平衡二叉树

如果以树的复杂结构来实现简单的链表功能,则完成埋没了树的特点.因此需要进行某种条件的约束,让链表一样的树变得更有层次结构,平衡二叉树就呼之欲出;

>平衡二叉树的性质:
+ 树的左右高度差不能超过1;
+ 任何往下递归的左子树与右子树,必须符合第一条性质;
+ 没有任何节点的空树或只有根节点的树也是平衡二叉树;

### 二叉查找树

二叉查找树又称二叉搜索树,即`Binary Search Tree`,其中`Search`也可以替换为`Sort`,所以也称为二叉排序树;

二叉查找树,对于任意节点来说,它左子树所有节点的值都小于它,而它的右子树上所有节点的值都大于它;

**查找过程从树的根节点开始,沿着简单的判断向下走,小于节点值的往左边走,大于节点值的往右边走,直到找到目标数据或者到达叶子节点还未找到;**

遍历所有节点的常用方式有三种:`前序遍历`,`中序遍历`,`后序遍历`:
+ 在任何递归子树中,左节点一定在右节点之前先遍历;
+ `前序`,`中序`,`后序`,仅指根节点在遍历时的位置顺序;

### AVL树

>AVL树是一种平衡二叉查找树,增加和删除节点后通过树形旋转重新达到平衡;
+ 右旋是以某个节点为中心,将它沉入当前右子节点的位置,而让当前的左子节点作为新树的根节点,也称为顺时针旋转;
+ 左旋是以某个节点为中心,将它沉入当前左子节点的位置,而让当前右子节点作为新树的根节点,也称为逆时针旋转;

### 红黑树

红黑树,它主要特征是在每个节点上增加一个属性来表示节点的颜色,可以是红色,也可以是黑色;

与AVL树相比,红黑树并不追求所有递归子树的高度差不超过`1`,而是保证从根节点到叶尾的最长路径不超过最短路径的2倍,所以它的最坏运行时间也是`O(logn)`;

>红黑树特性:
+ 节点只能是红色或黑色
+ 根节点必须是黑色
+ 所有`NIL(Nothing In Leaf)`节点都是黑色
+ 一条路径上不能出现相邻的两个红色节点
+ 在任何递归子树内,根节点到叶子节点的所有路径上包含相同数目的黑色节点;

**`NIL`是红黑树中特殊的存在,即在叶子节点上不存在的两个虚拟节点;**

简单而言,即"有红必有黑,红红不相连",以上述5个特性保证了红黑树的新增,删除,查找的最坏时间复杂度均为`O(logn)`.

如果一个树的左子节点或右子节点不存在,则均认定为黑色.

**红黑树的任何旋转在3次之内均可完成;**

#### 红黑树与AVL树的比较

复杂度而言,**任意节点的黑深度(Black Depth)是指当前节点到`NIL`(树尾端)途径的黑色节点个数.**

根据特性,对于任意高度的节点,它的黑深度都满足:`Black Depth >= height / 2`.也就是锁,对于任意包含`n`个节点的红黑树而言,它的根节点高度`h<=2log2(n+1)`.

**常规BST操作比如查找,插入,删除等,时间复杂度为`O(h)`,即取决于树的高度h.当树失衡时,时间复杂度将有可能恶化到`O(h)`,即`h=n`;所以,当我们能保证树的高度始终保持在`O(logn)`时,便能保证所有操作的时间复杂度都能保持在`O(logn)`以内;**

>+ 由于红黑树只追求大致上的平衡,因此红黑树能在至多上次旋转内恢复平衡;
+ 而追求绝对平衡的AVL树,则至多需要`O(logn)`次旋转.

**AVL树在插入与删除时,将向上回溯确定是否需要旋转,这个回溯的时间成本最差可能为`O(logn)`；**

**而红黑树每次向上回溯的步长为2,回溯成本降低.因此,面对频繁的插入和删除**

#### `TreeMap`

`TreeMap`是按照Key的排序结构来组织内部结构的`Map`类集合,它改变了`Map`类散乱无序的形象.虽然`TreeMap`没有`ConcurrentHashMap`和`HashMap`普及(毕竟插入和删除的效率远没有后两者高),但是在key有排序要求的场景下,使用`TreeMap`可以事半功倍;

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
        	// 其父节点是其爷爷节点的左子节点时
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
                	// 如果x节点时父节点的右子节点,先对父节点做左旋操作
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
            } else {
            	// 
                Entry<K,V> y = leftOf(parentOf(parentOf(x)));
                if (colorOf(y) == RED) {
                    setColor(parentOf(x), BLACK);
                    setColor(y, BLACK);
                    setColor(parentOf(parentOf(x)), RED);
                    x = parentOf(parentOf(x));
                } else {
                    if (x == leftOf(parentOf(x))) {
                        x = parentOf(x);
                        rotateRight(x);
                    }
                    setColor(parentOf(x), BLACK);
                    setColor(parentOf(parentOf(x)), RED);
                    rotateLeft(parentOf(parentOf(x)));
                }
            }
        }
        root.color = BLACK;
    }


    // 左旋操作
    private void rotateLeft(Entry<K,V> p) {
    	// 节点不为空
        if (p != null) {
        	// 
            Entry<K,V> r = p.right;
            p.right = r.left;
            if (r.left != null)
                r.left.parent = p;
            r.parent = p.parent;
            if (p.parent == null)
                root = r;
            else if (p.parent.left == p)
                p.parent.left = r;
            else
                p.parent.right = r;
            r.left = p;
            p.parent = r;
        }
    }

    // 右旋操作
    private void rotateRight(Entry<K,V> p) {
        if (p != null) {
            Entry<K,V> l = p.left;
            p.left = l.right;
            if (l.right != null) l.right.parent = p;
            l.parent = p.parent;
            if (p.parent == null)
                root = l;
            else if (p.parent.right == p)
                p.parent.right = l;
            else p.parent.left = l;
            l.right = p;
            p.parent = l;
        }
    }

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