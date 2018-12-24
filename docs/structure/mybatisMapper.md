映射器是`MyBatis`最强大的工具，也是我们使用`MyBatis`时用得最多的工具；

`MyBatis`是针对映射器构造的`SQL`构建的轻量级框架，并且通过配置生成对应的`JavaBean`返回给调用者，而这些配置主要便是映射器；

在`MyBatis`中你可以根据情况定义动态`SQL`来满足不同的场景的需要，它比其他框架灵活得多；

MyBatis还支持自动绑定`JavaBean`，我们只要让`SQL`返回的字段名和`JavaBean`的属性名保持一致（或者采用驼峰式命名），便可以省掉这些繁琐的映射配置；

元素名称|描述|备注|
--|--|--|
select|查询语句，最常用、最复杂的元素之一|可以自定义参数，返回结果集等|
insert|插入语句|执行后返回一个整数，代表插入的条数|
update|更新语句|执行后返回一个整数，代表更新条数|
delete|删除语句|执行后返回一个整数，代表删除的条数|
parameterMap|定义参数映射关系|即将被删除的元素，不建议大家使用|
sql|允许定义一部分的SQL，然后在各个地方引用它|***|
resultMap|用来描述从数据库结果集中来加载对象，它是最复杂、最强大的元素|它将提供映射规则|
cache|给定命名空间的缓存配置||
cache-ref|其他命名空间缓存配置的引用||


### select元素
执行select语句前，我们需要定义参数，可以是一个简单的参数类型，如`int`、`float`、`String`，也可以是一个复杂的参数类型，如`JavaBean`、`Map`等；这些都是`MyBatis`接受的参数类型。

执行`SQL`后，`MyBatis`也提供了强大的映射规则，甚至是自动映射来帮助我们把返回的结果集绑定到`JavaBean`中

![select.png](/images/mybatis/select.png)
![select2.png](/images/mybatis/select2.png)


### 自动映射
`autoMappingBehavior`参数，当它不设置为`NONE`的时候，`MyBatis`会提供自动映射的功能，只要返回的`SQL`列名和`JavaBean`的属性一致，`MyBatis`就会帮助我们回填这些字段而无需任何配置，它可以在很大程度上简化我们的配置工作。

![selectSelf.png](/images/mybatis/selectSelf.png)

### 传递多个参数
使用Map传递参数

![paramters.png](/images/mybatis/paramters.png)
![paramters2.png](/images/mybatis/paramters2.png)
![paramters3.png](/images/mybatis/paramters3.png)

这样设置参数使用了`Map`，而`Map`需要键值对应，由于业务关联性不强，你需要深入到程序中看代码，造成可读性下降。

### 使用注解方式传递参数
![paramters4.png](/images/mybatis/paramters4.png)

使用`MyBatis`的参数注解`@Param（org.apache.ibatis.annotations.Param）`来实现：

![paramters5.png](/images/mybatis/paramters5.png)

当传入参数太多时，就会使代码变得很长，可读性也是不佳

### 使用`JavaBean`传递参数
在参数过多的情况下，`MyBatis`允许组织一个`JavaBean`，通过简单的`setter`和`getter`方法设置参数，这样就可以提高我们的可读性

![JavaBean.png](/images/mybatis/JavaBean.png)
![JavaBean2.png](/images/mybatis/JavaBean2.png)
![JavaBean3.png](/images/mybatis/JavaBean3.png)

### 使用`resultMap`映射结果集

![resultMap.png](/images/mybatis/resultMap.png)
![resultMap2.png](/images/mybatis/resultMap2.png)

### `insert`元素

![insert.png](/images/mybatis/insert.png)

#### 主键回填和自定义
首先我们可以使用`keyProperty`属性指定那个是主键字段，同时使用`useGeneratedKeys`属性告诉`MyBatis`这个主键是否使用数据库内置策略生成；

![insert2.png](/images/mybatis/insert2.png)

需要自定义主键规则时，可以使用`selectKey`元素进行处理：
![insert3.png](/images/mybatis/insert3.png)


### `update`元素和`delete`元素
和`insert`元素一样，`MyBatis`执行完`update`元素和`delete`元素后会返回一个整数，标出执行后影响的记录条数：

![update.png](/images/mybatis/update.png)

### 参数
通过制定参数的类型去让对应的`typeHandler`处理他们：

#### 参数配置
![paramtersConfig.png](/images/mybatis/paramtersConfig.png)

### 存储过程支持
对于存储过程而言，存在3种参数，输入参数（`IN`）、输出参数（`OUT`）、输入输出参数（`INOUT`）。

`MyBatis`的参数规则则为其提供了良好的支持，我们通过制定mode属性来确定其是哪一种参数，它的选项有3种：`IN`、`OUT`、`INOUT`；

当你返回的是一个游标（也就是我们制定`JdbcType=CURSOR`）的时候，你还需要去设置`resultMap`以便`MyBatis`将存储过程的参数映射到对应的类型，这时`MyBatis`就会通过你所设置的`resultMap`自动为你设置映射结果；

![cursor.png](/images/mybatis/cursor.png)

### 特殊字符串替换和处理（`#`和`$`）
在MyBatis中，传递字符串，我们设置的参数`#`（`name`）在大部分的情况下`MyBatis`会用创建预编译的语句，然后`MyBatis`为它设值，而有时候我们需要的是传递`SQL`语句的本身，而不是`SQL`所需要的参数：
![$.png](/images/mybatis/$.png)

这样`MyBatis`就不会帮我们转译`columns`，而变为直出，而不是作为`SQL`的参数进行设置。只是这样是对`SQL`而言是不安全，`MyBatis`给了灵活性的同时，也需要自己去控制参数以保证`SQL`运转的正确性和安全性；

### `sql`元素
`sql`元素的意义，在于我们可以定义一串`SQL`语句的组成部分，其他的语句可以通过引用来使用它。
![sql.png](/images/mybatis/sql.png)
![sql2.png](/images/mybatis/sql2.png)

### `resultMap`结果映射集
其作用是定义映射规则、级联的更新、定制类型转化器等
![resultMapElement.png](/images/mybatis/resultMapElement.png)

其中`constructor`元素用于配置构造方法。

![resultMapConst.png](/images/mybatis/resultMapConst.png)

![resultMapTable.png](/images/mybatis/resultMapTable.png)

#### 级联
>在MyBatis中级联分为3种：
+ `association`，代表一对一关系；
+ `collection`，代表一对多关系；
+ `discriminator`，是鉴别器，它可以根据实际选择采用那个类作为实例，允许你根据特定的条件去关联不同的结果集；

#### 性能分析和`N+1`问题
**级联的优势是能够方便快捷地获取数据。**

多层关联时，建议超过三层关联时尽量少用级联，因为不仅用处不大，而且会造成复杂度的增加，不利于他人的理解和维护。

级联还有更严重的问题，如果我们采取类似默认的场景那么有一个关联我们就要多执行一次`SQL`，会造成`SQL`执行过多导致性能下降，这就是`N+1`的问题；

>+ 为了解决这个问题我们应该考虑采用延迟加载的功能；
+ 为了处理`N+1`的问题，`MyBatis`引入了延迟加载的功能，延迟加载功能的意义在于，一开始并不取出级联数据，只有当使用它了才发送`SQL`去取回数据；

![lazyLoading.png](/images/mybatis/lazyLoading.png)
![lazyLoadingConfig.png](/images/mybatis/lazyLoadingConfig.png)

上面的是全局设置，不太灵活；因为我们不能制定到那些属性可以立即加载，那些属性可以延迟加载。当一个功能的两个对象经常需要一起用时，我们采用及时加载更好，因为即时加载可以多条SQL一次性发送，性能高。

MyBatis也有局部延迟加载的功能。我们在`association`和`collection`元素上加入属性值`fetchType`就可以了，它有两个取值范围，即`eager`和`lazy`。它的默认值取决于你在配置文件`settings`的配置。假如没有配置它，那么它的值就是`eager`；

![association.png](/images/mybatis/association.png)

### 缓存`cache`
**缓存是互联网系统常常用到的，其特点是数据保存在内存中。**

目前流行的缓存服务器有`MongoDB`、`Redis`、`Ehcache`等。缓存是在计算机内存上保存的数据，在读取的时候无需再从磁盘读入，因此具备快速读取和使用的特点；如果缓存命中率高，那么可以极大地提高系统的性能。如果缓存命中率很低，那么缓存就不存在使用的意义，所以使用缓存的关键在于存储内容访问的命中率；

#### 系统缓存（一级缓存和二级缓存）
`MyBatis`对缓存提供支持，但是在没有配置的默认的情况下，它只开启一级缓存（一级缓存只是相对于同一个`SqlSession`而言）。

所以在参数和SQL完全一样的情况下，我们使用同一个`SqlSession`对象调用同一个`Mapper`的方法，往往只执行一次`SQL`，因为使用`SqlSession`第一次查询后，`MyBatis`会将其放在缓存中，以后再查询的时候，如果没有声明需要刷新，并且缓存没超时的情况下，`SqlSession`都只会取出当前的缓存的数据，而不会再次发送`SQL`到数据库；

但是如果你使用的是不同的`SqlSession`对象，因为不同的`SqlSession`都是相互隔离的，所以用相同的`Mapper`、参数和方法，它还是会再次发送`SQL`到数据库去执行，返回结果；

为了克服这个问题，我们往往需要配置二级缓存，使得缓存在`SqlSessionFactory`层面上能够提供给各个`SqlSession`对象共享；

而`SqlSessionFactory`层面上的二级缓存是不开启的，二级缓存的开启需要进行配置，实现二级缓存的时候，`MyBatis`要求返回的`POJO`必须是可序列化的，也就是要求实现`Serializable`接口，配置的方法很简单，只需要在映射`XML`文件配置就可以开启缓存了；
```
<cache/>
```

>这样的一个语句里面，很多配置是默认的，如果我们只是这样配置，那么就意味着：
+ 映射语句文件中的所有select语句将会缓存；
+ 映射语句文件中的所有insert、update和delete语句会刷新缓存；
+ 缓存会使用默认的Least Recently Used（LRU，最近最少使用的）算法来收回；
+ 根据时间表，比如No Flush Interval，（CNFI，没有刷新间隔），缓存不会以任何时间顺序来刷新；
+ 缓存会存储列表集合或对象（无论查询方法返回什么）的1024个引用；
+ 缓存会被视为是read/write（可读/可写）的缓存，意味着对象检索不是共享的，而且可以安全地被调用者修改，不干扰其他调用者或线程所做的潜在修改；

```
<cache eviction="LRU" flushInterval="100000" size="1024" readOnly="true"/>
```

>+ eviction：代表的是缓存回收策略，目前MyBatis提供以下策略：
  + LRU：最近最少使用的，移除最长时间不用的对象；
  + FIFO：先进先出，按对象进入缓存的顺序来移除它们；
  + SOFT：软引用，移除基于垃圾回收器状态和软引用规则的对象；
  + WEAK：弱引用，更积极移除基于垃圾收集器状态和弱引用规则的对象。这里采用的是LRU，移除最长时间不用的对象；
+ flushInterval：刷新间隔时间，单位位毫秒，这里配置的是100秒刷新，如果你不配置它，那么当SQL被执行的时候才会去刷新缓存；
+ size：引用数目，一个正整数，代表缓存最多可以存储多少个对象，不宜设置过大，设置过大会导致内存溢出，这里配置的是1024个对象；
+ readOnly：只读，意味着缓存数据只能读取而不能修改，这样设置的好处是我们以快速读取缓存，缺点是我们没有办法修改缓存，它的默认值为false，不允许我们修改；

#### 自定义缓存
系统缓存是`MyBatis`应用机器上的本地缓存，但是在大型服务器上，会使用各类不同的缓存服务器，这个时候我们可以定制缓存，如`Redis`缓存；
我们需要实现`MyBatis`为我们提供的接口`org.apache.ibatis.cache.Cache`：

```
String getId();//获取缓存编号
void putObject(Object key, Object value);//保存key值缓存对象
Object getObject(Object key);//通过Key获取缓存对象
Object removeObject(Object key);//通过key删除缓存对象
void clear();//清空缓存
int getSize();//获取缓存对象大小
ReadWriteLock getReadWriteLock();//获取缓存的读写锁
```
```
配置自定义缓存
<cache type="*****"/>
```
如果在自定义的类增加`setName`方法，那么它在初始化的时候就会被调用：

在映射器上可以配置`insert、delete、select、update`元素，也可以配置SQL层面上的缓存规则，来决定它们是否需要使用或者刷新缓存，根据两个属性：`useCache`和`flushCache`来完成的，其中`useCache`表示是否需要使用缓存，而`flushCache`表示插入后是否需要刷新缓存：

```
<select ... flushCache="false" useCache="true"/>
<insert ... flushCache="true"/>
<update ... flushCache="true"/>
<delete ... flushCache="true"/>
```