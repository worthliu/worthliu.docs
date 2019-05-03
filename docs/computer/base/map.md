## Map类集合

在数据元素的存储,查找,修改和遍历中,Java中的`Map`类集合都与`Collection`类集合存在很大不同.它是与`Collection`类平级的一个接口,在集合框架图上,它有一条微弱的依赖线与`Collection`类产生关联,那是因为部分方法返回`Collection`视图,比如`values()`方法返回的所有`Values`的列表;

`Map`类集合中的存储单位是`KV`键值对,`Map`类就是使用一定的哈希算法形成一组比较均匀的哈希值作为`Key`,`Value`值挂在`Key`上;

>+ `Map`类取代了旧的抽象类`Dictionary`,拥有更好的性能;
+ 没有重复的`Key`,可以有多个重复的`Value`;
+ `Value`可以是`List`,`Map`,`Set`类对象;
+ `KV`是否允许为`null`,以实现类约束为准;

```HashMap
    // 返回Map类对象中的Key的Set视图
	public Set<K> keySet() {
        Set<K> ks = keySet;
        if (ks == null) {
            ks = new KeySet();
            keySet = ks;
        }
        return ks;
    }
    // 返回Map类对象中的所有Value集合的Collection视图
    // 返回的集合实现类为 Values extends Abstract Collection<V>
    public Collection<V> values() {
        Collection<V> vs = values;
        if (vs == null) {
            vs = new Values();
            values = vs;
        }
        return vs;
    }
    // 返回Map类对象中的Key-Value对的Set视图
    public Set<Map.Entry<K,V>> entrySet() {
        Set<Map.Entry<K,V>> es;
        return (es = entrySet) == null ? (entrySet = new EntrySet()) : es;
    }
```

**这些返回的视图是支持清除操作的,但是修改和增加元素会抛出异常,因为`AbstractCollection`没有实现`add()`操作,但是实现了`remove`,`clear`等相关操作;**


`Map`集合类|`Key`|`Value`|`Super`|`JDK`|说明|
--|--|--|--|--|--|
`Hashtable`|不允许为`null`|不允许为`null`|`Dictionary`|1.0|线程安全(过时)|
`ConcurrentHashMap`|不允许为`null`|不允许为`null`|`AbstractMap`|1.5|锁分段技术或`CAS`(JDK8及以上)|
`TreeMap`|不允许为`null`|允许为`null`|`AbstractMap`|1.2|线程不安全(有序)|
`HashMap`|允许为`null`|允许为`null`|`AbstractMap`|1.2|线程不安全(`resize`死链问题)|
