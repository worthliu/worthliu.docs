# hashCode And equals

## hashCode与equals的作用与区别及应当注意的细节

**先来试想一个场景，如果你想查找一个集合中是否包含某个对象，那么程序应该怎么写呢？**
>+ 通常的做法是逐一取出每个元素与要查找的对象一一比较，当发现两者进行`equals`比较结果相等时，则停止查找并返回`true`，否则，返回`false`。
+ 但是这个做法的一个缺点是**当集合中的元素很多时，譬如有一万个元素，那么逐一的比较效率势必下降很快**。
+ 于是有人发明了一种`哈希算法`来提高从该集合中查找元素的效率，这种方式将集合分成若干个存储区域（可以看成一个个桶），每个对象可以计算出一个哈希码，可以根据`哈希码分组`，每组分别对应某个存储区域，这样一个对象根据它的`哈希码`就可以分到不同的`存储区域（不同的桶中）`。

![hash](/images/hash.png)                

实际的使用中，一个对象一般有`key`和`value`，可以根据`key`来计算它的`hashCode`。

假设现在全部的对象都已经根据自己的`hashCode值`存储在不同的`存储区域`中了，那么现在查找某个对象（根据对象的key来查找），不需要遍历整个集合了，现在只需要计算要查找对象的key的`hashCode`，然后找到该`hashCode`对应的存储区域，在该存储区域中来查找就可以了，这样效率也就提升了很多。


>+ `hashCode`是为了**提高在散列结构存储中查找的效率，在线性表中没有作用**。
+ `equals`和`hashCode`需要**同时覆盖**。
+ 若两个对象`equals`返回`true`，则`hashCode`**有必要**也返回相同的`int数`。
+ 若两个对象`equals`返回`false`，则`hashCode`**不一定**返回不同的`int数`,但为**不相等的对象**生成不同`hashCode`值可以提高哈希表的性能。
+ 若两个对象`hashCode`返回**相同**`int数`，则`equals`**不一定**返回`true`。
+ 若两个对象`hashCode`返回**不同**`int数`，则`equals`**一定返回**`false`。
+ 同一对象在执行期间若已经存储在集合中，则不能修改影响`hashCode`值的相关信息，否则**会导致内存泄露问题**。

## hashCode和equals的区别和联系

**首先说明一下`JDK`对`equals(Object obj)`和`hashCode()`这两个方法的定义和规范：**
>在Java中任何一个对象都具备`equals(Object obj)`和`hashCode()`这两个方法，因为他们是在`Object类`中定义的。
  + `equals(Object obj)`方法**用来判断两个对象是否“相同”**，如果“相同”则返回`true`，否则返回`false`。
  + `hashCode()`方法返回**一个`int数`**，在`Object类`中的默认实现是**“将该对象的内部地址转换成一个整数返回”**。 

>`hashCode` 的常规协定是：     
  1. 在 Java 应用程序执行期间，在同一对象上多次调用 `hashCode` 方法时，必须一致地返回相同的整数，前提是对象上 `equals` 比较中所用的信息没有被修改。从某一应用程序的一次执行到同一应用程序的另一次执行，该整数无需保持一致。     
  2. 如果根据 `equals(Object)` 方法，两个对象是相等的，那么在两个对象中的每个对象上调用 `hashCode` 方法都必须生成相同的整数结果。     
  3. **以下情况不是必需的**：如果根据`equals(java.lang.Object)`方法，两个对象不相等，那么在两个对象中的任一对象上调用`hashCode`方法必定会生成不同的整数结果。但是，程序员应该知道，为不相等的对象生成不同整数结果可以提高哈希表的性能。     
  4. 实际上，由 `Object` 类定义的 `hashCode` 方法确实会针对不同的对象返回不同的整数。（这一般是通过将该对象的内部地址转换成一个整数来实现的，但是 `JavaTM` 编程语言不需要这种实现技巧。）   
  5. 当`equals方法`被重写时，通常有必要重写 `hashCode 方法`，以维护 `hashCode方法`的常规协定，该协定声明相等对象必须具有相等的哈希码。

**一般来说涉及到对象之间的比较大小就需要重写`equals方法`，但是为什么第一点说重写了`equals`就需要重写`hashCode`呢？**

>+ **实际上这只是一条规范，如果不这样做程序也可以执行，只不过会隐藏bug。**
+ 一般一个类的对象如果会存储在`HashTable`，`HashSet`,`HashMap`等散列存储结构中，那么重写`equals`后最好也重写`hashCode`，否则会导致存储数据的不唯一性（存储了两个`equals`相等的数据）。
+ 而如果确定不会存储在这些散列结构中，则可以不重写`hashCode`。但是个人觉得还是重写比较好一点，谁能保证后期不会存储在这些结构中呢，况且重写了`hashCode`也不会降低性能，因为在线性结构（如`ArrayList`）中是不会调用`hashCode`，所以重写了也不要紧，也为后期的修改打了补丁。

## equals和hashcode在集合类中用法

来看一张对象放入散列集合的流程图：

![hashandequals](/images/hashandequals.png)

从上面的图中可以清晰地看到在存储一个对象时，先进行`hashCode值`的比较，然后进行`equals`的比较。可能现在你已经对上面的6点归纳有了一些认识。

我们还可以通过`JDK`中得源码来认识一下具体`hashCode`和`equals`在代码中是如何调用的。

**`HashSet.java`**
```
public boolean add(E e) {  
     return map.put(e, PRESENT)==null;  
}
```
**`HashMap.java`**
```
public V put(K key, V value) {  
        if (key == null)  
            return putForNullKey(value);  
        int hash = hash(key.hashCode());  
        int i = indexFor(hash, table.length);  
  for (Entry<K,V> e = table[i]; e != null; e = e.next) {  
            Object k;  
        if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {  
                V oldValue = e.value;  
                 e.value = value;  
                 e.recordAccess(this);  
                 return oldValue;  
             }  
         }  
   
         modCount++;  
         addEntry(hash, key, value, i);  
         return null;  
} 
```

## 问题锦集

### 测试（覆盖`equals(Object obj)`但不覆盖`hashCode()`,导致数据不唯一性）

```
public class HashCodeTest {  
    public static void main(String[] args) {  
        Collection set = new HashSet();  
        Point p1 = new Point(1, 1);  
        Point p2 = new Point(1, 1);  
  
        System.out.println(p1.equals(p2));  
        set.add(p1);   //(1)  
        set.add(p2);   //(2)  
        set.add(p1);   //(3)  
   
         Iterator iterator = set.iterator();  
         while (iterator.hasNext()) {  
             Object object = iterator.next();  
             System.out.println(object);  
         }  
     }  
 }  
   
 class Point {  
     private int x;  
     private int y;  
   
     public Point(int x, int y) {  
         super();  
         this.x = x;  
         this.y = y;  
     }  
   
     @Override  
     public boolean equals(Object obj) {  
         if (this == obj)  
             return true;  
         if (obj == null)  
             return false;  
         if (getClass() != obj.getClass())  
             return false;  
         Point other = (Point) obj;  
         if (x != other.x)  
             return false;  
         if (y != other.y)  
             return false;  
         return true;  
     }  
   
     @Override  
     public String toString() {  
         return "x:" + x + ",y:" + y;  
     }  
   
 }
```
**输出结果：**
```
[java] view plain copy
  1. true  
  2. x:1,y:1  
  3. x:1,y:1  
```
>原因分析：
1. 当执行`set.add(p1)`时`(1)`，集合为空，直接存入集合；
2. 当执行`set.add(p2)`时`(2)`，首先判断该对象`(p2)`的`hashCode值`所在的存储区域是否有相同的`hashCode`，因为没有覆盖`hashCode方法`，所以`jdk`使用默认Object的`hashCode`方法，返回内存地址转换后的整数，因为不同对象的地址值不同，所以这里不存在与p2相同`hashCode`值的对象，因此`jdk`默认不同`hashCode`值，`equals`一定返回`false`，所以直接存入集合。
3. 当执行`set.add(p1)`时	`(3)`，时，因为p1已经存入集合，同一对象返回的`hashCode`值是一样的，继续判断`equals`是否返回`true`，因为是同一对象所以返回`true`。此时jdk认为该对象已经存在于集合中，所以舍弃。


### 测试（覆盖hashCode方法，但不覆盖equals方法，仍然会导致数据的不唯一性）

```
class Point {  
    private int x;  
    private int y;  
  
    public Point(int x, int y) {  
        super();  
        this.x = x;  
        this.y = y;  
    }  
   
     @Override  
     public int hashCode() {  
         final int prime = 31;  
         int result = 1;  
         result = prime * result + x;  
         result = prime * result + y;  
         return result;  
     }  
   
     @Override  
     public String toString() {  
         return "x:" + x + ",y:" + y;  
     }  
   
 } 
```
**出结果：**
```
[java] view plain copy
  1. false  
  2. x:1,y:1
  3. x:1,y:1
```
>原因分析：
1. 当执行`set.add(p1)`时`(1)`，集合为空，直接存入集合；
2. 当执行`set.add(p2)`时`(2)`，首先判断该对象`(p2)`的hashCode值所在的存储区域是否有相同的`hashCode`，这里覆盖了`hashCode`方法，`p1`和`p2`的`hashCode`相等，所以继续判断`equals`是否相等，因为这里没有覆盖`equals`，默认使用`'=='`来判断，所以这里`equals`返回`false`，`jdk`认为是不同的对象，所以将`p2`存入集合。
3. 当执行`set.add(p1)`时`(3)`，时，因为`p1`已经存入集合，同一对象返回的`hashCode`值是一样的，并且`equals`返回`true`。此时`jdk`认为该对象已经存在于集合中，所以舍弃。

**综合上述两个测试，要想保证元素的唯一性，必须同时覆盖hashCode和equals才行。**

**（注意：在`HashSet`中插入同一个元素（`hashCode`和`equals`均相等）时，会被舍弃，而在`HashMap`中插入同一个`Key`（`Value` 不同）时，原来的元素会被覆盖。）**

### 测试（在内存泄露问题）

```
public class HashCodeTest {  
    public static void main(String[] args) {  
        Collection set = new HashSet();  
        Point p1 = new Point(1, 1);  
        Point p2 = new Point(1, 2);  
  
        set.add(p1);  
        set.add(p2);           
        p2.setX(10);  
        p2.setY(10);
        
        set.remove(p2);  
   
         Iterator iterator = set.iterator();  
         while (iterator.hasNext()) {  
             Object object = iterator.next();  
             System.out.println(object);  
         }  
     }  
 }  
   
 class Point {  
     private int x;  
     private int y;  
   
     public Point(int x, int y) {  
         super();  
         this.x = x;  
         this.y = y;  
     }  
   
   
     public int getX() {  
         return x;  
     }  
   
   
     public void setX(int x) {  
         this.x = x;  
     }  
   
   
     public int getY() {  
         return y;  
     }  
   
   
     public void setY(int y) {  
         this.y = y;  
     }  
   
   
     @Override  
     public int hashCode() {  
         final int prime = 31;  
         int result = 1;  
         result = prime * result + x;  
         result = prime * result + y;  
         return result;  
     }  
   
   
     @Override  
     public boolean equals(Object obj) {  
         if (this == obj)  
             return true;  
         if (obj == null)  
             return false;  
         if (getClass() != obj.getClass())  
             return false;  
         Point other = (Point) obj;  
         if (x != other.x)  
             return false;  
         if (y != other.y)  
             return false;  
         return true;  
     }  
   
   
     @Override  
     public String toString() {  
         return "x:" + x + ",y:" + y;  
     }  
   
 }
```
**运行结果：**
```
[java] view plain copy
  1. x:1,y:1  
  2. x:10,y:10 
```
>原因分析：
    **假设`p1`的`hashCode`为`1`，`p2`的`hashCode`为`2`，在存储时`p1`被分配在`1号桶`中，`p2`被分配在`2号桶`中。**
+ 这时修改了`p2`中与计算`hashCode`有关的信息（x和y）,当调用`remove(Object obj)`时，首先会查找该`hashCode`值得对象是否在集合中。
+ 假设修改后的`hashCode`值为`10`（仍存在2号桶中）,这时查找结果空，jdk认为该对象不在集合中，所以不会进行删除操作。
+ 然而用户以为该对象已经被删除，导致该对象长时间不能被释放，造成内存泄露。解决该问题的办法是不要在执行期间修改与`hashCode`值有关的对象信息，如果非要修改，则必须先从集合中删除，更新信息后再加入集合中。