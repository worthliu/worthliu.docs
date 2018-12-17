## `MyBatis`的基本构成

>+ `SqlSessionFactoryBuilder`（构造器）:它会根据配置信息或者代码来生成`SqlSessionFactory`（工厂接口）
+ `SqlSessionFactory`：依靠工厂来生成`SqlSession`（会话）
+ `SqlSession`：是一个既可以发送`SQL`去执行并返回结果，也可以获取`Mapper`的接口
+ `SQL Mapper`：它是`MyBatis`新设计的组件，它是由一个`Java`接口和`XML`文件（或者注解）构成的，需要给出对应的`SQL`和映射规则，它负责发送`SQL`去执行，并返回结果；

![mybatisConstitute](/images/mybatis/mybatisConstitute.png)

--------------------------------------------------------------------------------
## 构建`SqlSessionFactory`
每个`MyBatis`的应用都是以`SqlSeesionFactory`的实例为中心的。`SqlSessionFactory`的实例可以通过`sqlSessionFactoryBuilder`获得。

**需要注意`SqlSessionFactory`是一个工厂接口而不是现实类，它的任务是创建`SqlSession`。**

>`SqlSeesion`类似于一个`JDBC`的`Connection`对象。`MyBatis`提供了两种模式去创建`SqlSessionFactory`：
+ `XML`配置的方式
+ 代码的方式

`Configuration`的类全限定名为`org.apache.ibatis.session.Configuration`，它MyBatis中将以一个`Configuration`类对象的形式存在，而这个对象将存在与整个`MyBatis`应用生命周期中，以便重复读取和运用。

在内存中的数据是计算机系统中读取速度最快的，我们可以解析一次配置的`XML`保存到`Configuration`类对象中，方便我们从这个对象中读取配置信息，性能高。

在`MyBatis`中提供了两个`SqlSessionFactory`的实现类，`DefaultSqlSessionFactory`和`SqlSessionManager`。目前使用的是`DefaultSqlSessionFactory`；

![SqlSessionFactory](/images/mybatis/SqlSessionFactory.png)

## 创建`SqlSession`
`SqlSession`是一个接口类，它扮演着门面的作用，而真正干活的是`Executor`接口，你可以认为它是公司的工程师；

我们只需要告知其我要什么信息（参数），要做什么东西，过段时间，她会将结果给我。

`SqlSession`接口类似于一个`JDBC`中的`Connection`接口对象，我们需要保证每次用完正常关闭它。

>`SqlSession`的用途主要有两种：
+ 获取映射器，让映射器通过命名空间和方法名称找到对应的SQL，发送给数据库执行后返回结果；
+ 直接通过命名信息去执行SQL返回结果，这是`iBatis`版本留下的方式。
+ 在`SqlSession`层我们可以通过`update`、`insert`、`select`、`delete`等方法，带上SQL的id来操作在XML中配置好的SQL，从而完成我们的工作；与此同时它也支持事务，通过`commit`、`rollback`方法提交或者回滚事务；


## 映射器
映射器是由`Java`接口和`XML`文件（或注解）共同组成的，它的作用如下：
>+ 定义参数类型；
+ 描述缓存
+ 描述`SQL`语句
+ 定义查询结果和`POJO`的映射关系
一个映射器的实现方式有两种，一种是通过XML文件方式实现，另一种就是通过代码方式实现，在Configuration里面注册Mapper接口（需要注解）
+ `Java`注解是受限，功能较少，而`MyBatis`的`Mapper`内容相当多，而且相当复杂，功能很强大，使用XML文件方式可以带来更为灵活的空间，显示出`MyBatis`功能的强大和灵活；
+ 如果你的`SQL`很复杂，条件很多，尤其是存在动态`SQL`的时候，写在`Java`文件里面可读性较差，增加维护的成本；


## XML文件配置方式实现Mapper
使用`XML`文件配置是`MyBatis`实现`Mapper`的首选方式。

它由一个`Java`接口和一个`XML`文件构成；
![xml](/images/mybatis/xml.png)

## 生命周期

![mybatisLife.png](/images/mybatis/mybatisLife.png)

1. `SqlSessionFactoryBuilder`
  + `SqlSessionFactoryBuilder`是利用XML或者Java编码获得资源来构建`SqlSessionFactory`的，通过它可以构建多个`SessionFactory`。
  + 它的作用就是一个构建器，一旦我们构建了`SqlSessionFactory`，它的作用就已经完结，失去了存在意义；
  + 所以它的生命周期只存在与方法的局部，它的作用就是生成`SqlSessionFactory`对象；

2. `SqlSessionFactory`
  + `SqlSessionFactory`的作用是创建`SqlSession`，而`SqlSession`就是一个会话，相当于`JDBC`中的`Connection`对象。每次应用程序需要访问数据库，我们就要通过`SqlSessionFactory`创建`SqlSession`，所以`SqlSessionFactory`应该在`MyBatis`应用的整个生命周期中。
  + 而如果我们多次创建同一个数据库的`SqlSessionFactory`，则每次创建`SqlSessionFactory`会打开更多的数据库连接（`Connection`）资源，那么连接资源就很快会被耗尽。
  + 因此`SqlSessionFactory`的责任是唯一的，它的责任就是创建`SqlSession`，所以我们果断采用单例模式。

3. `SqlSession`
 + `SqlSession`是一个会话，相当于`JDBC`的一个`Connection`对象，它的生命周期应该是在请求数据库处理事务过程中。	
 + 它是一个线程不安全的对象，在涉及多线程的时候我们需要特别的当心，操作数据库需要注意其隔离级别，数据库锁等高级特性。
 + 每次创建`SqlSession`都必须及时关闭它，它长期存在就会使数据库连接池的活动资源减少，对系统性能的影响很大。

4. `Mapper`
 + `Mapper`是一个接口，而没有任何实现类，它的作用是发送`SQL`，然后返回我们需要的结果，或者执行`SQL`从而修改数据库的数据，因此它应该在一个`SqlSession`事务方法之内，是一个方法级别的东西。

 ## 一些疑问
**1. 在`MyBatis`中保留着`iBatis`，通过“命名空间（`namespace`）+`SQLId`”的方式发送`SQL`并返回数据的形式，而不需要去获取映射器；那么困惑是我们需要`Mapper`吗？**

**`Mapper`是一个接口，相对而言它可以进一步屏蔽`SqlSession`这个对象，使得它具有更强的业务可读性。**

>建议采用映射器方式编写代码：
+ `sqlSession.selectOne`是功能性代码，长长的字符串比较晦涩难懂，不包含业务逻辑的含义，不符合面向对象的规范，而对于`roleMapper.getRole`这个样才是符合面向对象规范的编程，也更符合业务的逻辑
+ 使用`Mapper`方式，`IDE`可以检查`Java`语法，避免不必要的错误

这是`MyBatis`特有的接口编程模式，而`iBatis`只能通过`SqlSession`用`SQL`的`id`过滤`SQL`去执行；

**2. 我们使用的仅仅是Java接口和一个XML文件或者注解去实现Mapper，Java接口不是实现类，对于Java语言不熟悉的读者肯定会十分疑惑，一个没有实现类的接口怎么能够运行呢？**

**其实它需要运用到`Java`语言的动态代理去实现，而实现`Java`语言的动态代理的方式有多种。**

>理解：我们会在`MyBatis`上下文中描述这个接口，而`MyBatis`会为这个接口生成代理类对象，代理对象会根据**“接口全路径+方法名”**去匹配，找到对应的`XML`文件（或者注解）去完成它所需要的任务，返回我们需要的结果；