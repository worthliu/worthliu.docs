缓存,是让数据更接近于使用者,目的是让访问速度更快.

**`工作机制是先从缓存中读取数据,如果没有,再从慢速设备上读取实际数据并同步到缓存.`**

+ `缓存命中率` : 从缓存中读取数据的次数与总读取次数的比率,命中率越高越好.
  + `缓存命中率 = 从缓存中读取次数/(总读取次数(从缓存总读取次数 + 从慢速设备上读取次数))`


>缓存回收策略:
+ `基于空间` : 缓存设置了存储空间,当达到存储空间上限时,按照一定策略移除数据;
+ `基于容量` : 缓存设置了最大大小,当缓存的条目超过最大大小时,按照一定策略移除旧数据;
+ `基于时间` : 
  + `TTL(Time To Live)`:存活期,即缓存数据从创建开始直到到期的一个时间段;
  + `TTI(Time To Idle)`:空闲期,即缓存数据多久没被访问后移除缓存的时间;
+ `基于Java对象引用` : 
  + `软引用`:如果一个对象时软引用,那么当`JVM`堆内存不足时,垃圾回收器可以回收这些对象.
  + `弱引用`:当垃圾回收器回收内存时,如果发现弱引用,则将它立即回收.


>回收算法:
+ `FIFO(First In First Out)` : 先进先出算法,即先放入缓存的先被移除;
+ `LRU(Least Recently Used)` : 最近最少使用算法,使用时间距离现在最久的那个被移除;
+ `LFU(Least Frequently Used)` : 最不常用算法,一定时间段内使用次数(频率)最少的那个被移除;

## `Java缓存类型`

+ `堆缓存`:使用`Java堆内存来存储缓存对象`;
  + 不需要序列化/反序列化,时最快的缓存;
  + 当缓存的数据量很大时,GC暂停时间会变长,存储容量受限于堆空间大小;
  + 一般通过软引用/弱引用来存储缓存对象;

+ `堆外缓存`:即缓存数据存储在堆外内存,可以减少GC暂停时间,可以支持更大的缓存空间.
  + 读取数据需要序列化/反序列化;

+ `磁盘缓存` : 即缓存数据存储在磁盘上,在JVM重启时数据还是存在的;

+ `分布式缓存`

**`Gauva Cache, Ehcache, MapDB,`**

## `缓存使用模式实践`

+ `SoR(system-of-record)` : 记录系统或者可以叫做数据源,即实际存储原始数据的系统;
+ `Cache` : 缓存,是`SoR`的快照数据,`Cache`的访问速度比`SoR`要快,放入`Cache`的目的是提升访问速度,减少回源到`SoR`的次数; 
+ `回源` : 即回到数据源头获取数据,`Cache`没有命中时,需要从`SOR`读取数据;

### `Cache-Aside`

`Cache-Aside`即业务代码围绕着`Cache`写,是由业务代码直接维护缓存;

**`读场景,先从缓存获取数据,如果没有命中,则回源到SoR并将源数据放入缓存供下次读取使用`;**
```
//1. 先从缓存中获取数据
value = myCache.getIfPresent(key);
if(value == null){
	// 2.1. 如果缓存没有命中,则回源到SoR获取源数据
	value = loadFromSoR(key);
	// 2.2. 将数据放入缓存,下次即可从缓存中获取数据
	myCache.put(key, value);
}
```

**`写场景,先将数据写入SoR,写入成功后立即将数据同步写入缓存`;**
```
// 1.先将数据写入SoR
writeToSoR(key, value);
// 2.执行成功后立即同步写入缓存
myCache.put(key, value);
```
**`先将数据写入SoR,写入成功后将缓存数据过期,下次读取时再加载缓存`;**
```
// 1.先将数据写入SoR
writeToSoR(key, value);
// 2.失效缓存,然后下次读时再加载缓存
myCache.invalidate(key);
```

>对于`Cache-Aside`,可能存在并发更新情况,即如果多个应用实例同时更新,那么缓存怎么办?
+ 如果是用户维度的数据(如订单数据,用户数据),加上过期时间来解决即可;
+ 对于如商品这种基础数据,可以考虑使用`canal`订阅`binlog`,来进行增量更新分布式缓存,这样不会存在缓存数据不一致的情况;
  + 缓存更新会存在延迟.而本地缓存可根据不一致容忍度设置合理的过期时间
+ 读服务场景,可以考虑使用一致性哈希,**将相同的操作负载均衡到同一个实例**,从而减少并发几率.或者**设置比较短的过期时间**;

### `Cache-As-SoR`
 
`Cache-As-SoR`即把`Cache`看作为`SoR`,所有操作都是对`Cache`进行,然后`Cache`再委托给`SoR`进行真实的读写;

`Read-Through` : 
+ **业务代码首先调用`Cache`**;
+ **如果`Cache`不命中由`Cache`回源到`SoR`,而不是业务代码(即由`Cache`读`SoR`)**;
+ `Guava Cache`和`Ehcache 3.x`都支持该模式;

```Guava
LoadingCache<Integer, Result<Category>> getCache = 
 CacheBuilder.newBuilder()
  			.softValues()
  			.maximumSize(5000)
  			.expireAfterWrite(2, TimeUnit.MINUTES)
  			.build(new CacheLoader<Integer, Result<Category>>(){
  				@Override
  				public Result<Category> load(final Integer sortId) throws Exception{
  					return categoryService.get(sortId);
  				}
  			});
```
1. 应用业务代码直接调用`getCache.get(sortId)`;
2. 首先查询`Cache`,如果缓存中有,则直接返回缓存数据;
3. 如果缓存没有命中,则委托给`CacheLoader`,`CacheLoader`会回源到`SoR`查询源数据(返回值必须不为`null`,可以包装为`Null`对象),然后写入缓存;

>使用`CacheLoader`的好处:
+ 应用业务代码更简洁了,不需要像`Cache-Aside`模式那样缓存查询代码和`SoR`代码交织在一起.如果缓存使用逻辑散落在多处,则使用这种方式很简单地消除了重复代码;
+ 解决`Dog-pile effect`,即当某个缓存失效时,又有大量相同的请求没命中缓存,从而使请求同时到后端,导致后端压力太大,此时限定一个请求去拿即可;

### `Write-Through`

`Write-Through`,被称为穿透写模式/直写模式:
+ 业务代码首先调用`Cache`写(新增/修改)数据;
+ 然后由`Cache`负责写缓存和写`SoR`;

### `Write-Behind`

`Write-Behind`,回写模式:
+ 异步写.异步之后可以实现批量写/合并写/延时和限流;

### `Copy Pattern`

+ `Copy-On-Read(在读时复制)` 
+ `Copy-On-Write(在写时复制)`

**在`Guava Cache`和`Ehcache`中堆缓存都是基于引用的,这样如果有人拿到缓存数据并修改了它,则可能发生不可预测的问题;**
