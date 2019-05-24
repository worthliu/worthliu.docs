## 简单动态字符串(SDS)

`Redis`没有直接使用C语言传统得字符串表示(以空字符串结尾得字符数组),而是自己构建了一种名为简单动态字符串(`simple dynamic string, SDS`)的抽象类型,并将`SDS`用作`Redis`的默认字符串表示;

**`在Redis中,C语言的字符串只会作为字符串字面量用在一些无须对字符串值进行修改的地方;`**

### `SDS`的定义

每个`sds.h/sdshdr`结构表示一个`SDS`值:

```sdshdr
struct sdshdr{
	// 记录buf数组中已使用子节的数量
	// 等于SDS所保存字符串的长度
	int len;

	// 记录buf数组中未使用子节的数量
	int free;

	// 子节数组,用于保存字符串
	char buf[];
}sdshdr;
```

**`SDS`遵循C字符串以空字符结尾的惯例,保存空字符的1子节空间不计算在`SDS`的`len`属性里面,并且为空字符分配额外的1子节空间,以及添加空字符到字符串末尾等操作,都是由`SDS`函数自动完成的,所以这个空字符对于`SDS`的使用者来说是完全透明的;**

>遵循空字符结尾,`SDS`可以直接重用一部分C字符串函数库里面的函数;

### C字符串

C语言使用长度为`N+1`的字符数组来表示长度为`N`的字符串,并且字符数组的最后一个元素总是空字符`'\0'`;


### `Redis`自定义字符串结构优势

+ 常数复杂度获取字符串长度:
  + `SDS`在`len`属性中记录了`SDS`本身的长度,获取长度复杂度仅为`O(1)`
  + 设置和更新`SDS`长度的工作是由`SDS`的`API`在执行时自动完成的,无须进行任何手动修改长度的工作; 
+ 杜绝缓冲区溢出
  + 当`SDS API`需要对`SDS`进行修改时,`API`会先检查`SDS`空间是否满足修改所需的要求,如果不满足的话,`API`会自动将`SDS`的空间扩展至执行修改所需的大小,然后才执行实际的修改操作;
+ 减少修改字符串时带来的内存重分配次数
  + `SDS`通过**未使用空间**解除了字符串长度和底层数组长度之间的关联;
  + 在`SDS`中,`buf`数组的长度不一定就是字符数量加一,数组里面可以包含未使用的子节,而这些子节的数量就由`SDS`的`free`属性记录;
    + `空间预分配`,**用于优化`SDS`的字符串增长操作;**
      + `SDS`修改时,其长度小于`1MB`,分配和`len`属性同样大小的未使用空间;
      + `SDS`修改时,其长度大于等于`1MB`,分配`1MB`的未使用空间;
	+ `惰性空间释放`,**用于优化`SDS`的字符串缩短操作;**
	  + 当`SDS`的`API`需要缩短`SDS`保存的字符串时,程序并不立即使用内存重分配来回收缩短后多出来的子节,而是使用`free`属性将这些子节的数量记录起来,并等待将来使用;
+ 二进制安全
  + 由于C语言字符串的末尾是以空字符做为结尾,限制了C字符串只能保存文本数据,而不能保存像图片,音频,视频,压缩文件等二进制数据;
  + `SDS API`都会以处理二进制的方式来处理`SDS`存放在buf数组里的数据,不会对其中数据做任何限制,过滤或者假设;
    + `Redis`的`SDS`的`buf`属性,其保存一系列二进制数据;
+ 兼容部分C字符串函数


## 链表

对于`Redis`而言,链表也是自己构建实现的;

**每个链表节点使用一个`adlist.h/listNode`结构来表示:**

```listNode
typedef struct  listNode{
	// 前置节点
	struct listNode *prev;

	// 后置节点
	struct listNode *next;

	// 节点的值
	void *vlaue;
}listNode;
```

多个`listNode`可以通过`prev`和`next`指针组成双端链表;

使用`adlist.h/list`来持有链表的话.操作起来更加方便:

```list
typedef struct list {
	// 表头节点
    listNode *head;
    // 表尾节点
    listNode *tail;
    // 节点值复制函数
    void *(*dup)(void *ptr);
    // 节点值释放函数
    void (*free)(void *ptr);
    // 节点值对比函数
    int (*match)(void *ptr, void *key);
    // 链表所包含的节点数量
    unsigned long len;
} list;
```

`list`结构为链表提供了表头指针`head`,表尾指针`tail`,以及链表长度计数器`len`,而`dup`,`free`,`match`成员则是用于实现多态链表所需的类型特定函数;
+ `dup`函数用于复制链表节点所保存的值
+ `free`函数用于释放链表节点所保存的值
+ `match`函数用于对比链表节点所保存的值和另一个输入值是否相等


>`Redis`的链表实现的特性:
+ 双端 : 链表节点带有`prev`和`next`指针,获取某个节点的前置节点和后置节点的复杂度都是`O(1)`;
+ 无环 : 表头节点的`prev`指针和表尾节点的`next`指针都指向`NULL`,对链表的访问以`NULL`为终点;
+ 带表头指针和表尾指针 : 通过`list`结构的`head`指针和`tail`指针,程序获取链表的表头节点和表尾节点的复杂度为`O(1)`
+ 多态 : 链表节点使用`void*`指针来保存节点值,并且可以通过`list`结构的`dup`,`free`,`match`三个属性为节点值设置类型特定函数,所以链表可以用于保存各种不同类型的值;


## 字典

字典,又称为`符号表(symbol table)`,`关联数组(associative array)`或`映射(map)`,是一种用于保存`键值对(key-value pair)`的抽象数据结构;

字典在`Redis`中的应用相当广泛,比如`Redis`的数据库就是使用字典来作为底层实现的,对数据库的增删查改操作也是构建在对字典的操作之上的;

字典还是哈希键的底层实现之一,当一个哈希键包含的键值对比较多,又或者键值对中的元素都是比较长的字符串时,`Redis`就会使用字典作为哈希键的底层实现;

### 字典的实现

`Redis`的字典使用哈希表作为底层实现,一个哈希表里面可以有多个哈希表节点,而每个哈希表节点就保存了字典中的一个键值对;

```dict.h
typedef struct dictht {
	// 哈希表数组
    dictEntry **table;
    // 哈希表大小
    unsigned long size;
    // 哈希表大小掩码,用于计算索引值,总是等于size-1
    unsigned long sizemask;
    // 该哈希表已有节点的数量
    unsigned long used;
} dictht;
```

+ `table`属性是一个数组,数组中的每个元素都是一个指向`dict.h/dictEntry`结构的指针,每个`dictEntry`结构保存着一个键值对.
+ `size`属性记录了哈希表的大小,也即是`table`数组的大小;
+ `used`属性则记录了哈希表目前已有节点的数量;
+ `sizemask`属性的值总是等于`size-1`,这个属性和哈希值一起决定一个键应该被放到`table`数组的那个索引上面;

```
typedef struct dictEntry {
	// 键
    void *key;
    // 值
    union {
        void *val;
        uint64_t u64;
        int64_t s64;
        double d;
    } v;

    // 指向下个哈希表节点,形成链表
    struct dictEntry *next;
} dictEntry;
```

+ `key`属性保存着键值对中的键,而`v`属性则保存着键值对中的值,其中键值对的值可以是一个指针,或者是一个`uint64_t`整数,或者是一个`int64_t`整数;
+ `next`属性是指向另一个哈希表节点的指针,这个指针可以将多个哈希值相同的键值对连接在一次,以此来解决冲突的问题;

```
typedef struct dict {
	// 类型特定函数
    dictType *type;
    // 私有数据
    void *privdata;
    // 哈希表
    dictht ht[2];
    // rehash索引,当rehash不进行时,值为-1
    long rehashidx; 
    // 当前迭代器数量
    unsigned long iterators;
} dict;
```

`type`属性和`privdata`属性是针对不同类型的键值对,为创建多态字典而设置的;
+ `type`属性是一个指向`dictType`结构的指针,每个`dictType`结构保存了一簇用于操作特定类型键值对的函数,`Redis`会为用途不同的字典设置不同的类型特定函数;
+ `privdata`属性则保存了需要传给哪些类型特定函数的可选参数;



// TODO 哈希表 计算 ,冲突, 扩容与缩容

## 跳跃表

跳跃表(`skiplist`)是一种有序数据结构,它通过在每个节点中维持多个指向其他节点的指针,从而达到快速访问节点的目的;

跳跃表支持平均`O(logN)`,最坏`O(N)`复杂度的节点查找,还可以通过顺序性操作来批量处理节点;

`Redis`使用跳跃表作为有序集合键的底层实现之一,如果一个有序集合包含的元素数量比较多,又或者有序集合中的元素的成员是比较长的字符串时,`Redis`就会使用跳跃表来作为有序集合键的底层实现;

>`Redis`只在两个地方用到了跳跃表:
+ 实现有序集合键
+ 在集群节点中用作内部数据结构

```
typedef struct zskiplistNode {
    sds ele;
    double score;
    struct zskiplistNode *backward;
    struct zskiplistLevel {
        struct zskiplistNode *forward;
        unsigned long span;
    } level[];
} zskiplistNode;

typedef struct zskiplist {
    struct zskiplistNode *header, *tail;
    unsigned long length;
    int level;
} zskiplist;
```

>`zskiplist`结构
+ `header` : 指向跳跃表的表头节点
+ `tail` : 指向跳跃表的表尾节点
+ `length` : 记录跳跃表的长度
+ `level` : 记录目前跳跃表内,层数最大的那个节点的层数

>`zskiplistNode`结构:
+ `层(level)` : 节点中用`L1,L2,L3`等字样标记节点的各个层;
  + 每个层都带有两个属性:`前进指针`和`跨度`;
  + `前进指针` : 用于访问位于表尾方向的其他节点;
  + `跨度` : 记录了前进指针所指向的节点和当前节点的距离;
+ `后退指针(backward)` : 指向位于当前节点的前一个节点;
  + 在程序从表尾向表头遍历时使用;
+ `分值` 
+ `成员值(ele)`


## 整数集合

整数集合(`intset`)是集合键的底层实现之一,当一个集合只包含整数值元素,并且这个集合的元素数量不多时,`Redis`就会使用整数集合作为集合键的底层实现;

```
typedef struct intset {
	// 编码方式
    uint32_t encoding;
    // 集合包含的元素数量
    uint32_t length;
    // 保存元素的数组
    int8_t contents[];
} intset;
```

整数集合`intset`是`Redis`用于保存整数值的集合抽象数据结构,它可以保存类型为`int16_t,int32_t,int64_t`的整数值,并且保证集合中不会出现重复元素;

+ `contents`数组是整数集合的底层实现
  + 整数集合的每个元素都是`contents`数组的一个数组项(`item`),各个项在数组中按值得大小从小到大有序地排列,并且数组中不包含任何重复项;
+ `length`属性记录了整数集合包含得元素数量

### 升级

每当我们要将一个新元素添加到整数集合里面,并且新元素得类型比整数集合现有所有元素得类型都要长时,整数集合需要先进行`升级(upgrade)`,然后才能将新元素添加到整数集合里面;

>升级整数集合并添加新元素共分为三步进行:
+ 根据新元素的类型,扩展整数集合底层数组的空间大小,并未新元素分配空间;
+ 将底层数组现有的所有元素都转成与新元素相同的类型,并将类型转换后的元素放置到正确的位上,而且在放置元素的过程中,需要继续维持底层数组的有序性质不变;
+ 将新元素添加到底层数组里面;

**因为每次向整数集合添加新元素都可能会引起升级,而每次升级都需要对底层数组中已有的所有元素进行类型转换,所以向整数集合添加新元素的时间复杂度为`O(N)`;**


+ `提升灵活性` : 可以随意地将不同类型的值放在同一个数据结构里面,通过自动升级底层数组来适应新元素;
+ `节约内存` : 让集合能同时保存三种不同类型的值,又可以确保升级操作只会在有需要的时候进行;
+ `降级` : 一旦升级,编码就会一直保持升级后的状态;


## 压缩列表

压缩列表(`ziplist`)是列表键和哈希键的底层实现之一;

当一个列表键只包含少量列表项,并且每个列表要么就是小整数值,要么就是长度比较短的字符串,那么`Redis`就会使用压缩列表来做列表键的底层实现;

**压缩列表是`Redis`为了节约内存而开发的,是由一系列特殊编码的连续内存块组成的顺序型数据结构.**

一个压缩列表可以包含任意多个节点,每个节点可以保存一个子节数组或者一个整数值;

+ `zlbytes` : `uint32_t`类型,4字节
  + 记录整个压缩列表占用的内存字节数;
  + 在对压缩列表进行内存重分配,或者计算`zlend`的位置时使用; 
+ `zltail` : `uint32_t`类型,4字节
  + 记录压缩列表表尾节点距离压缩列表的起始地址有多少子节;
  + 通过这个偏移量,程序无须遍历整个压缩列表就可以确定表尾节点的地址;
+ `zllen` : `uint16_t`类型,2字节
  + 记录了压缩列表包含的节点数量;
  + 当这个属性的值小于`UINT16_MAX(65535)`时,这个属性的值就是压缩列表包含节点的数量;
  + 当这个值等于`UINT16_MAX`时,节点的真实数量需要遍历整个压缩列表才能计算得出; 
+ `entryX` : 列表节点,长度不定
  + 压缩列表包含的各个节点,节点的长度由节点保存的内容决定;
+ `zlend` : `uint8_t`类型,1字节
  + 特殊值`0xFF(255)`,用于标记压缩列表的末端 