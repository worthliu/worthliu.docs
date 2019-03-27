## 前言

在各种数据结构(线性表,树等)中,记录在结构中的相对位置是随机的,和记录的关键字之间不存在确定的关系.因此,在结构中查找记录时候需要进行关键字的比较.这类的查找方法建立在"比较"的基础上.查找的效率依赖于查找过程中所进行的比较次数;

对于不同数据结构中,随着数据量的增长,在均衡的概率下,其查找的效率都将下降.仅仅时有的比较快(时间复杂度为O(n)),有的比较慢(时间复杂度是O(logn))而已;

### 哈希表

在理想的情况下,我们是希望不经过任何比较,一次存取便能得到所查的记录.这就是Hash表;

在Hash表中对不同的关键字可能得到同一哈希地址,这种现象称为冲突.在一般情况下,这种冲突只能尽可能地减少,而不能完全避免.因为Hash函数是从关键字集合到地址集合的映射.通常关键字的集合比较大,它的元素包括所有可能的关键字,而地址集合的元素仅为Hash的地址值;

## 哈希树

>分辨:指连续的整数不可能有完全相同的余数序列;

### 质数分辨定理

>选取任意n个互不相同的质数(`p1<p2<p3<p4<p5.....<pn`),定义:`M=p1*p2*p3*....*pn`,设`m<k1<k2<m+M`,那么对任意的i,`(k1 mod pi) = (k2 mod pi)`不可能总成立;


>**n个不同的质数可以"分辨"的连续整数的个数和他们的乘积相等;**


### 余数分辨定理

>选取任意n个互不相同的自然数:I1<I2<I3<I4....<In,定义LCM(lease common Multiple)为I1,I2,I3,.....,In的最小公倍数;设`m<k1<k2<m+LCM`,那么对于任意的`(ki mod Ii) = (k2 mod Ii)`不可能总成立;

> n个不同的数可以"分辨"的连续整数的个数不超过他们的最小公倍数.超过这个范围就意味着冲突的概率会增加;

### 分辨算法评价标准

>1. 状态和特征
  + 分辨即分辨不同的状态.分辨一般是先定义一组不同的状态,然后将这些状态记录下来形成特征.由这些特征所形成的空间是特征空间.特征空间的维数是特征数列的长度;
2. 分辨能力,也称分辨范围,指分辨算法可以分辨的最大连续空间大小;
  + 在这个范围内,分辨算法可以唯一确定被分辨数.即任何两个在分辨范围内的数,不可能具有完成相同的特征数,这些特征数会以某种形成被记录下来,或者以数据结构的形式体现出来;
3. 冲突概率
  + 当被分辨数之间的距离超出分辨范围的时候,就有可能跟发生冲突;当被分辨的数是随机分布在整个数轴的时候,两个数之间的距离可能会超过分辨范围.
4. 分辨效率
5. 简化度

### Hash树的组织结构

使用不同的分辨算法都可以组织成Hash树.一般来说:每层Hash的节点下的子节点数是和分辨数列一致的.哈希树的最大深度和特征空间纬数是一致的;

为了研究的方便,我们选择质数分辨算法来建立一颗Hash树.选择从2开始的连续质数来建立一个十层的哈希树(因为M10已经超过了计算机中常用整数的表达范围).第一层节点为根节点,根节点下有2个节点;第二层的每个节点下有3个节点;依此类推,即每层节点的子节点数目为连续的质数.到了第十层,每个节点下有29个节点;

同一节点中的子节点,从左到右代表不同的余数结果.例如:第二层节点下有三个节点.那么从左到右分别代表:除3余0,除3余1和除3余2.

对质数的余数决定了处理的路径.例如:某个数来到第二层子节点,那么它要做取余操作,然后再决定从那个子节点向下搜寻.

**如果所有的节点都存在,并容纳数据的话,那么可以容纳的数据项目总数将比M10要大一些:`M(10)=M1*M2*....*M10=6.703028889*10^9`**

如果在建立当初就建立所有的节点,那么所消耗的计算时间和磁盘空间是巨大的.在实际使用当中,只需要初始化根节点就可以开始工作.子节点的建立是在有更多的数据进入到哈希树中的时候建立的.因此可以说Hash树和其他树一样是一个动态结构;

>Hash树每个节点有以下基本元素:
+ `节点的关键字`,在整个树中这个数值是唯一的.当节点占据标志位(occupied)为真的时候,关键字才认为是有效的,否则是无效的;
+ `节点是否被占据`,如果节点的关键字(key)有效,那么occupied应该设置位true,否则设置为false;
+ `节点的子节点数组`,用nodes[i]来表示节点的第i个子节点的地址.第10个质数为29,余数不可能大于32.这个数组的固定长度为可以设置为32,即0<=i<=31.当第i个子节点不存在时,nodes[i]=NULL,否则为子节点的地址.
+ `节点的数据对象`,用value来表示节点的数据对象;

#### 插入规则

设需要插入的关键字和数据分别为key和value.用level表示插入操作进行到第几层,level从0开始.Prime表为连续质数表.

>插入过程从根节点开始执行:
1. 如果当前节点没有被占据(`occupied=false`),则设置该节点的key和value,并设置占据标记为true,然后返回;
2. 如果当前节点被占据(`occupied=true`),则计算`index = key mod Prime[level]`.
3. 如果`nodes[index] = NULL`,那么创建子节点,将level加1,并重复第1步操作;
4. 如果`nodes[index]`为一个子节点那么,将level加1,然后重复第1步操作;

```
	public boolean insert(Integer key, Integer value) {
        int level = 0;
        HashNode curNode = this.ROOT;
        while (true){
            int remain = key % PRIME[level];
            if (curNode.next[remain] == null){
                // 当前节点为NULL,赋值操作
                curNode.next[remain] = new HashNode(key, value, level + 1);
                curNode.next[remain].occupied = true;
                break;
            }else if(curNode.next[remain].occupied){
                // 当前节点已被占用,层级往下,继续求余
                if(level >= 10){
                    return false;
                }
                curNode = curNode.next[remain];
                level++;
            }else{
                // 当前节点已被删除,直接占用
                curNode.next[remain].key = key;
                curNode.next[remain].value = value;
                curNode.next[remain].occupied = true;
                break;
            }
        }
        return true;
    }
```

#### 查找操作

哈希树的节点查找过程和节点插入过程类似，就是对关键字用质数序列取余，根据余数确定下一节点的分叉路径，直到找到目标节点。

如上图，最小”哈希树(HashTree)在从4G个对象中找出所匹配的对象，比较次数不超过10次。也就是说：最多属于O(10)。在实际应用中，调整了质数的范围，使得比较次数一般不超过5次。也就是说：最多属于O(5)。因此可以根据自身需要在时间和空间上寻求一个平衡点。

```
	public HashNode search(Integer key){
        int level = 0;
        HashNode targetNode;
        HashNode curNode = this.ROOT;
        while (true){
            int remain = key % PRIME[level];
            targetNode = curNode.next[remain];
            if(targetNode == null || (targetNode.occupied && targetNode.key.equals(key))){
                break;
            }else {
                curNode = curNode.next[remain];
                level++;
            }
        }
        return targetNode;
    }
```

#### 删除操作

哈希树的节点删除过程也很简单，哈希树在删除的时候，并不做任何结构调整。
只是先查到到要删除的节点，然后把此节点的“占位标记”置为false即可（即表示此节点为空节点，但并不进行物理删除）

```
	public boolean delete(Integer key){
        int level = 0;
        HashNode targetNode;
        HashNode curNode = this.ROOT;
        while (true){
            int remain = key % PRIME[level];
            targetNode = curNode.next[remain];
            if(targetNode == null){
                break;
            } else if(targetNode.occupied && targetNode.key.equals(key)){
                targetNode.occupied = false;
                break;
            }else {
                if(level >= 10){
                    return false;
                }
                curNode = curNode.next[remain];
                level++;
            }
        }
        return true;
    }
```

#### 优缺点

##### 优点

1. 结构简单

从哈希树的结构来说，非常的简单。每层节点的子节点个数为连续的质数。子节点可以随时创建。因此哈希树的结构是动态的，也不像某些哈希算法那样需要长时间的初始化过程。哈希树也没有必要为不存在的关键字提前分配空间。
需要注意的是哈希树是一个单向增加的结构，即随着所需要存储的数据量增加而增大。即使数据量减少到原来的数量，但是哈希树的总节点数不会减少。这样做的目的是为了避免结构的调整带来的额外消耗。

2. 查找迅速

从算法过程我们可以看出，对于整数，哈希树层级最多能增加到10。因此最多只需要十次取余和比较操作，就可以知道这个对象是否存在。这个在算法逻辑上决定了哈希树的优越性。
一般的树状结构，往往随着层次和层次中节点数的增加而导致更多的比较操作。操作次数可以说无法准确确定上限。而哈希树的查找次数和元素个数没有关系。如果元素的连续关键字总个数在计算机的整数（32bit）所能表达的最大范围内，那么比较次数就最多不会超过10次，通常低于这个数值。 

3. 结构不变

从删除算法中可以看出，哈希树在删除的时候，并不做任何结构调整。这个也是它的一个非常好的优点。常规树结构在增加元素和删除元素的时候都要做一定的结构调整，否则他们将可能退化为链表结构，而导致查找效率的降低。哈希树采取的是一种“见缝插针”的算法，从来不用担心退化的问题，也不必为优化结构而采取额外的操作，因此大大节约了操作时间。



##### 缺点

1. 非排序性

哈希树不支持排序，没有顺序特性。如果在此基础上不做任何改进的话并试图通过遍历来实现排序，那么操作效率将远远低于其他类型的数据结构。

#### 应用

哈希树可以广泛应用于那些需要对大容量数据进行快速匹配操作的地方。

例如：数据库索引系统、短信息中的收条匹配、大量号码路由匹配、信息过滤匹配。哈希树不需要额外的平衡和防止退化的操作，效率十分理想。


### 代码集

``` 非线程安全
public class HashTree {

    /**
     * 10连续不相同的质数,定义每层节点数
     */
    private static final int[] PRIME = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29};

    /**
     * hash树根节点
     */
    private final HashNode ROOT = new HashNode(null, null, PRIME[0]);

    /**
     * @param key
     * @param value
     */
    public boolean insert(Integer key, Integer value) {
        int level = 0;
        HashNode curNode = this.ROOT;
        while (true){
            int remain = key % PRIME[level];
            if (curNode.next[remain] == null){
                // 当前节点为NULL,赋值操作
                curNode.next[remain] = new HashNode(key, value, level + 1);
                curNode.next[remain].occupied = true;
                break;
            }else if(curNode.next[remain].occupied){
                // 当前节点已被占用,层级往下,继续求余
                if(level >= 10){
                    return false;
                }
                curNode = curNode.next[remain];
                level++;
            }else{
                // 当前节点已被删除,直接占用
                curNode.next[remain].key = key;
                curNode.next[remain].value = value;
                curNode.next[remain].occupied = true;
                break;
            }
        }
        return true;
    }

    /**
     * @param key
     * @return
     */
    public boolean delete(Integer key){
        int level = 0;
        HashNode targetNode;
        HashNode curNode = this.ROOT;
        while (true){
            int remain = key % PRIME[level];
            targetNode = curNode.next[remain];
            if(targetNode == null){
                break;
            } else if(targetNode.occupied && targetNode.key.equals(key)){
                targetNode.occupied = false;
                break;
            }else {
                if(level >= 10){
                    return false;
                }
                curNode = curNode.next[remain];
                level++;
            }
        }
        return true;
    }

    /**
     * @param key
     * @return
     */
    public HashNode search(Integer key){
        int level = 0;
        HashNode targetNode;
        HashNode curNode = this.ROOT;
        while (true){
            int remain = key % PRIME[level];
            targetNode = curNode.next[remain];
            if(targetNode == null || (targetNode.occupied && targetNode.key.equals(key))){
                break;
            }else {
                curNode = curNode.next[remain];
                level++;
            }
        }
        return targetNode;
    }


    /**
     * Hashing Tree's node
     */
    private class HashNode {
        private Integer key;

        private Integer value;

        private boolean occupied = false;

        /**
         * the level of current nodes
         */
        private int level;

        /**
         * 
         */
        private HashNode[] next;


        public HashNode(Integer key, Integer value, int level) {
            this.key = key;
            this.value = value;
            this.next = new HashNode[level];
        }

        public HashNode(Integer key, Integer value) {
            this.key = key;
            this.value = value;
        }
    }
}
```