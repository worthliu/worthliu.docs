
**`MyBatis`配置文件的层次结构是不能改变的（其实貌似所有涉及配置的框架容器，其配置层次都是不可以改变的）**
![mybatisConfig.png](/images/mybatis/mybatisConfig.png)

## `properties`元素

`properties`是一个配置属性的元素，让我们能在配置文件的上下文中使用它。

>MyBatis提供3种配置方式：
+ **`property`子元素**：通过此种方式配置好的属性值，我们在配置时可以直接引用：
![propertiesElement.png](/images/mybatis/propertiesElement.png)
![propertiesConfig.png](/images/mybatis/propertiesConfig.png)
+ **`properties`配置文件**：通过`properties`配置文件来配置属性值，我们可以很方便的在多个配置文件中重复使用它们，也方便日后维护和随时修改；
![propertiesFile.png](/images/mybatis/propertiesFile.png)
![propertiesFile2.png](/images/mybatis/propertiesFile2.png)
+ **程序参数传递**：
  + 实际工作中，系统是由运维人员去配置的和维护的，例如数据库密码对于开发人员而言都是透明的，不具有可见性；
  + 这个时候，我们需要在`SqlSessionFactory`对加密的帐号密码进行解密，需要通过程序进行参数传递；

### 优先级

**`MyBatis`支持3种配置方式可能同时出现，并且属性还会重复配置。而这3种方式是存在优先级的;**

>`MyBatis`将按照下面的顺序来加载：
1. 在`properties`元素体内指定的属性首先被读取；
2. 根据`properties`元素中的`resource`属性读取类路径下属性文件，或者根据`url`属性指定的路径读取属性文件，并覆盖已读取的同名属性；
3. 读取作为方法参数传递的属性，并覆盖已读取的同名属性；

因此，通过方法参数传递的属性具有最高优先级，`resource/url`属性中指定的配置文件次之，最低优先级的是`properties属性`中指定的属性。

## 设置
设置在`MyBatis`中是最复杂的配置，同时也是最为重要的配置内容之一，它会改变`MyBatis`运行时的行为。

即使不配置`settings`，`MyBatis`也可以正常的工作；

![settings.png](/images/mybatis/settings.png)
![settings2.png](/images/mybatis/settings2.png)
![settings3.png](/images/mybatis/settings3.png)
![settingsFile.png](/images/mybatis/settingsFile.png)

## 别名
别名（`typeAliases`）是一个指代的名称。

因为我们遇到的类全限定名过长，所以我们希望用一个简短的名称去指代它，而这个名称可以在`MyBatis`上下文中使用。

别名在`MyBatis`里面分为系统定义别名和自定义别名两类。(**注意，在`MyBatis`中别名是不区分大小写的**)

一个`typeAliases`的实例是在解析配置文件时生成的，然后长期保存在`Configuration`对象中，当我们使用它时，再把它拿出来，这样就没有必要运行的时候再次生成它的实例；

### 系统定义别名
`MyBatis`系统定义了一些经常使用的类型的别名，例如，数值、字符串、日期和集合等。我们可以在`MyBatis`中直接使用它们，在使用时不要重复定义把他们给覆盖了：

![typeAliases.png](/images/mybatis/typeAliases.png)
![typeAliases2.png](/images/mybatis/typeAliases2.png)


### 自定义别名
系统所定义的别名往往是不够用的，因为不同的应用有着不同的需要，所以`MyBatis`允许自定义别名
![typeAliasesSelf.png](/images/mybatis/typeAliasesSelf.png)

如上述，我们就可以在`MyBatis`上下文中使用`role`来代替其全路径，减少配置的复杂度
如果`POJO`过多的时候，配置也是非常多时，MyBatis允许我们通过自动扫描的形式自定义别名：
![typeAliasesSelf2.png](/images/mybatis/typeAliasesSelf2.png)

我们需要自定义别名的，它是使用注解`@Alias`，如下：
![typeAliasesSelf3.png](/images/mybatis/typeAliasesSelf3.png)

## `typeHandler`类型处理器
`MyBatis`在预处理语句（`PreparedStatement`）中设置一个参数时，或者从结果集（`ResultSet`）中取出一个值时，都会用注册了的`typeHandler`进行处理；

由于数据库可能来自于不同的厂商，不同的厂商设置的参数可能有所不同，同时数据库也可以自定义数据类型，`typeHandler`允许根据项目的需要自定义设置`Java`传递到数据库的参数中，或者从数据库读出数据，我们也需要进行特殊的处理，这些都可以在自定义的`typeHandler`中处理，尤其是在使用枚举的时候我们常常需要使用`typeHandler`进行转换；

`typeHandler`和别名一样，分为`MyBatis`系统定义和用户自定义两种。一般来说，使用`MyBatis`系统定义就可以实现大部分的功能，如果使用用户自定义的`typeHandler`，我们在处理的时候务必小心谨慎，以避免出现不必要的错误。
`typeHandler`常用的配置为`Java`类型（`javaType`）、`JDBC`类型（`jdbcType`）。

`typeHandler`的作用就是将参数从`javaType`转化为`jdbcType`，或者从数据库取出结果时把`jdbcType`转化为`javaType`。

### 系统定义的`typeHandler`

![typeHandler.png](/images/mybatis/typeHandler.png)

>注意：
+ 数值类型的精度，数据库`int`、`double`、`decimal`这些类型和`java`的精度、长度都是不一样的；
+ 时间精度，取数据到日用`DateOnlyTypeHandler`即可，用到精度为秒的用`SqlTimestampTypeHandler`等；

### 自定义`TypeHandler`
一般而言，`MyBatis`系统定义的`TypeHandler`已经能够应付大部分的场景了，但是我们不能排除不够用的情况。

我们自定义的`TypeHandler`需要处理什么类型？

现有的`TypeHandler`适合我们使用吗？
![typeHandlerSelf.png](/images/mybatis/typeHandlerSelf.png)

这里定义的数据库为`Varchar`型。当`Java`的参数为`String`型的时候，我们将使用`MyStringTypeHandler`进行处理。

但是只有这个配置`MyBatis`不会自动帮组你去使用这个`typeHandler`去转化，你需要更多的配置；

对于`MyStringTypeHandler`的要求是必须实现接口：`org.apache.ibatis.type.TypeHandler`，在`MyBatis`中，也可以继承`org.apache.ibatis.type.BaseTypeHandler`来实现，因为`BaseTypeHandler`已经实现了`typeHandler`接口。

![typeHandlerSelf2.png](/images/mybatis/typeHandlerSelf2.png)

代码里涉及了使用预编译（`PreparedStatement`）设置参数，获取结果集的时候使用的方法，并且给出日志；

>自定义`typeHandler`里用注解配置`JbdcType`和`JavaType`。这两个注解是：
+ `@MappedTypes`定义的是`JavaType`类型，可以指定那些`Java`类型被拦截；
+ `@MappedJdbcTypes`定义的是`JdbcType`类型，它需要满足枚举类`org.apache.ibatis.type.JdbcType`所列的枚举类型；

我还需要去标识那些参数或者结果类型去用`typeHandler`进行转换，在没有任何标识的情况下，`MyBatis`是不会启用你定义的`typeHandler`进行转换结果的，所以还要给予对应的标识，比如配置`jdbcType`和`javaType`，或者直接用`typeHandler`属性指定，因此我们需要修改映射器的`XML`配置；

![typeHandlerSelfConfig.png](/images/mybatis/typeHandlerSelfConfig.png)
![typeHandlerSelfConfig2.png](/images/mybatis/typeHandlerSelfConfig2.png)

### 枚举类型typeHandler
在`MyBatis`中枚举类型的`typeHandler`则有自己特殊的规则，`MyBatis`内部提供了两个转化枚举类型的`typeHandler`给我们使用：

![typeHandlerSelfConfig2.png](/images/mybatis/typeHandlerSelfConfig2.png)
其中，`EnumTypeHandler`是使用枚举字符串名称座位参数传递的；`EnumOrdinalTypeHandler`是使用整数下标作为参数传递的；

## `environment`配置环境
配置环境可以注册多个数据源（`datasource`），每个一个数据源分为两大部分：一个是数据库源的配置，另外一个是数据库事务（`transactionManager`）的配置；
![datasource.png](/images/mybatis/datasource.png)

>+ `environments`中的属性`default`，标明在缺省的情况下，我们将启用那个数据源配置；
+ `environment`元素是配置一个数据源的开始，属性`id`是设置这个数据源的标志，以便`MyBatis`上下文使用它；
+ `transactionManager`配置的是数据库事务，其中`type`属性有3种配置方式：
  + `JDBC`，采用`JDBC`方式管理事务，在独立编码中常常使用；
  + `MANAGED`，采用容器方式管理事务，在`JNDI`数据源中常用；
  + 自定义，由使用者自定义数据库事务管理办法，适用于特殊应用；
+ `property`元素则是可以配置数据源的各类属性，这里配置了`autoCommit=false`则是要求数据源不自动提交；
+ `datasource`标签，是配置数据源连接的信息，type属性是提供我们对数据库连接方式的配置，同样`MyBatis`提供这么几种配置方式：
  + `UNPOOLED`，非连接池数据库
  + `POOLED`，连接池数据库
  + `JNDI`，`JNDI`数据源
  + 自定义数据源

### 数据库事务
数据库事务`MyBatis`是交由`SqlSession`去控制的，我们可以通过`SqlSession`提交（`commit`）或者回滚（`rollback`）。

>数据源
`MyBatis`内部提供了3种数据源的实现方式：
+ `UNPOOLED`，非连接池，使用`MyBatis`提供的`org.apache.ibatis.datasource.unpooled.UnpooledDataSource`实现；
+ `POOLED`，连接池，使用`MyBatis`提供的`org.apache.ibatis.datasource.pooled.PooledDataSource`实现；
+ `JNDI`，使用`MyBatis`提供的`org.apache.ibatis.datasource.jndi.JndiDataSourceFactory`来获取数据源；

只需要把数据源的属性`type`定义为`UNPOOLED`、`POOLED`、`JNDI`即可；
如果使用自定义数据源，它必须实现`org.apache.ibatis.datasource.DataSourceFactory`接口。

![datasource2.png](/images/mybatis/datasource2.png)

### `databaseIdProvider`数据库厂商标识
在相同数据库厂商的环境下，数据库厂商标识没有什么意义，在实际的应用中使用的比较少，因为使用不同的厂商的数据库系统还是比较少的，`MyBatis`可能会运行在不同厂商的数据库中，它为此提供一个数据库标识，并提供自定义，它的作用在于指定`SQL`到对应的数据库厂商提供的数据库中运行；
![databaseldProvider.png](/images/mybatis/databaseldProvider.png)

`type=“DB_VENDOR”`是启动`MyBatis`内部注册的策略器。

首先`MyBatis`会将你的配置读入`Configuration`类里面，在连接数据库后调用`getDatabaseProductName()`方法去获取数据库的信息，然后用我们配置的`name`值去做匹配来得到`DatabaseId`。

MyBatis也提供规则允许自定义，只要实现databaseIdProvider接口，并且实现配置即可：
![datasourceSelf.png](/images/mybatis/datasourceSelf.png)


## 引入映射器的方法
映射器是`MyBatis`最复杂、最核心的组件。
![Mapper.png](/images/mybatis/Mapper.png)

引入映射器的方法很多:
![Mapper2.png](/images/mybatis/Mapper2.png)

