
## 传统的`JDBC`编程
`Java`程序都是通过`JDBC（Java Data Base Connectivity）`连接数据库的，这样我们就可以通过SQL对数据库编程。

`JDBC`是由`SUN`公司提出一系列规范，但是它只定义了接口规范，而具体的实现是交由各个数据库厂商的去实现的，因为每个数据库都有其特殊性，这些是`Java`规范没有办法确定的，所以`JDBC`就是一种典型的桥接模式。

>从代码中我们可以看出整个过程大致分为以下几步：
+ 使用`JDBC`编程需要连接数据库，注册驱动和数据库信息
+ 操作`Connection`，打开`Statement`对象
+ 通过`Statement`执行`SQL`，返回结果到`ResultSet`对象
+ 使用`ResultSet`读取数据，然后通过代码转化为具体的`POJO`对象
+ 关闭数据库相关资源

---

>1. 注册驱动和数据库信息，一般通过`Class.forName("com.mysql.jdbc.Driver")`；通过驱动类全限名进行加载驱动信息；
 + 其中`Class.forName`源码如下：**`forName（String）`默认需要初始化，并获取当前类加载器取加载目标类**
![forName](/images/mybatis/forName.png)
2. `Class.forName(xxx.xx.xx)`的作用就是要求`JVM`查找并加载指定的类，如果在类中有静态初始化器的话，JVM必然会执行该类的静态代码段。
 + 数据库驱动`com.mysql.jdbc.Driver`，源码如下：**其主要通过一个静态块向`JVM`注册驱动，所以`forName`的初始化参数必须为`true`；**
![Driver](/images/mybatis/Driver.png)

---

>传统`JDBC`一些弊端：
+ 工作量相对较大，我们需要先连接，然后处理JDBC底层事务，处理数据类型，还需要操作`Connection`对象、`Statement`对象和`ResultSet`对象去拿到数据，并准确关闭它们；
+ 要对`JDBC`编程可能产生的异常进行捕捉处理并正确关闭资源。

## `ORM`模型

`ORM`模型就是数据库的表和简单`Java`对象`（Plain Ordinary Java Object）`的映射关系模型，**它主要解决数据库数据和POJO对象的相互映射**。
![ORM](/images/mybatis/ORM.png)
## `Hibernate`
`Hibernate`是建立在若干POJO通过XML映射文件（或注解）提供的规则映射到数据库表上的。换句话说，我们可以通过POJO直接操作数据库的数据。它提供的是一种全表映射的模型。

`Hibernate`对`JDBC`的封装程度还是比较高的，我们已经不需要编写`SQL`语言，只要使用`HQL`语言就可以了；
![Hibernate](/images/mybatis/Hibernate.png)
>缺点：
+ 全表映射带来的不便，比如更新时需要发送所有的字段
+ 无法根据不同的条件组装不同的`SQL`
+ 对多表关联和复杂`SQL`查询支持较差，需要自己写`SQL`，返回后，需要自己将数据组装位`POJO`
+ 不能有效支持存储过程
+ 虽然有`HQL`，但是性能较差，大型互联网系统往往需要优化`SQL`，而`Hibernate`做不到

## `MyBatis`
半自动映射的框架`MyBatis`应运而生，之所以称它为半自动，是因为它需要手工匹配提供`POJO`、`SQL`和映射关系，而全表映射的`Hibernate`只需要提供`POJO`和映射关系便可；

>`MyBatis`所需要提供的映射文件包含以下三个部分：
+ `SQL`
+ 映射规则
+ `POJO`

在`MyBatis`里面，你需要自己编写SQL，虽然比Hibernate配置得多，但是`MyBatis`可以配置动态`SQL`，这就解决了`Hibernate`的表名根据时间变化，不同条件下列名不一样的问题。

同时你也可以优化`SQL`，通过配置决定你的SQL映射规则，也能支持存储过程，所以对于一些复杂的和需要优化性能SQL的查询它更加方便，`MyBatis`几乎能做到`JDBC`所能做到的所有事情。

![MyBatis](/images/mybatis/mybatis.png)