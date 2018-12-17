

**MyBatis配置文件的层次结构是不能改变的（其实貌似所有涉及配置的框架容器，其配置层次都是不可以改变的）**

## properties元素

properties是一个配置属性的元素，让我们能在配置文件的上下文中使用它。MyBatis提供3种配置方式：
  ● property子元素

通过此种方式配置好的属性值，我们在配置时可以直接引用：

  ● properties配置文件
通过properties配置文件来配置属性值，我们可以很方便的在多个配置文件中重复使用它们，也方便日后维护和随时修改；



  ● 程序参数传递
实际工作中，系统是由运维人员去配置的和维护的，例如数据库密码对于开发人员而言都是透明的，不具有可见性；这个时候，我们需要在SqlSessionFactory对加密的帐号密码进行解密，需要通过程序进行参数传递；

优先级
MyBatis支持3种配置方式可能同时出现，并且属性还会重复配置。而这3种方式是存在优先级的，MyBatis将按照下面的顺序来加载：
  1. 在properties元素体内指定的属性首先被读取；
  2. 根据properties元素中的resource属性读取类路径下属性文件，或者根据url属性指定的路径读取属性文件，并覆盖已读取的同名属性；
  3. 读取作为方法参数传递的属性，并覆盖已读取的同名属性；
因此，通过方法参数传递的属性具有最高优先级，resource/url属性中指定的配置文件次之，最低优先级的是properties属性中指定的属性。
--------------------------------------------------------------------------------
设置
设置在MyBatis中是最复杂的配置，同时也是最为重要的配置内容之一，它会改变MyBatis运行时的行为。即使不配置settings，MyBatis也可以正常的工作；









--------------------------------------------------------------------------------
别名
别名（typeAliases）是一个指代的名称。因为我们遇到的类全限定名过长，所以我们希望用一个简短的名称去指代它，而这个名称可以在MyBatis上下文中使用。别名在MyBatis里面分为系统定义别名和自定义别名两类。注意，在MyBatis中别名是不区分大小写的。一个typeAliases的实例是在解析配置文件时生成的，然后长期保存在Configuration对象中，当我们使用它时，再把它拿出来，这样就没有必要运行的时候再次生成它的实例；

系统定义别名
MyBatis系统定义了一些经常使用的类型的别名，例如，数值、字符串、日期和集合等。我们可以在MyBatis中直接使用它们，在使用时不要重复定义把他们给覆盖了：



自定义别名
系统所定义的别名往往是不够用的，因为不同的应用有着不同的需要，所以MyBatis允许自定义别名

如上述，我们就可以在MyBatis上下文中使用role来代替其全路径，减少配置的复杂度
如果POJO过多的时候，配置也是非常多时，MyBatis允许我们通过自动扫描的形式自定义别名：

我们需要自定义别名的，它是使用注解@Alias，如下：


--------------------------------------------------------------------------------
typeHandler类型处理器
MyBatis在预处理语句（PreparedStatement）中设置一个参数时，或者从结果集（ResultSet）中取出一个值时，都会用注册了的typeHandler进行处理；
由于数据库可能来自于不同的厂商，不同的厂商设置的参数可能有所不同，同时数据库也可以自定义数据类型，typeHandler允许根据项目的需要自定义设置Java传递到数据库的参数中，或者从数据库读出数据，我们也需要进行特殊的处理，这些都可以在自定义的typeHandler中处理，尤其是在使用枚举的时候我们常常需要使用typeHandler进行转换；
typeHandler和别名一样，分为MyBatis系统定义和用户自定义两种。一般来说，使用MyBatis系统定义就可以实现大部分的功能，如果使用用户自定义的typeHandler，我们在处理的时候务必小心谨慎，以避免出现不必要的错误。
typeHandler常用的配置为Java类型（javaType）、JDBC类型（jdbcType）。typeHandler的作用就是将参数从javaType转化为jdbcType，或者从数据库取出结果时把jdbcType转化为javaType。

系统定义的typeHandler




注意：
  ● 数值类型的精度，数据库int、double、decimal这些类型和java的精度、长度都是不一样的；
  ● 时间精度，取数据到日用DateOnlyTypeHandler即可，用到精度为秒的用SqlTimestampTypeHandler等；

自定义TypeHandler
一般而言，MyBatis系统定义的TypeHandler已经能够应付大部分的场景了，但是我们不能排除不够用的情况。
我们自定义的TypeHandler需要处理什么类型？
现有的TypeHandler适合我们使用吗？

这里定义的数据库为Varchar型。当Java的参数为String型的时候，我们将使用MyStringTypeHandler进行处理。但是只有这个配置MyBatis不会自动帮组你去使用这个typeHandler去转化，你需要更多的配置；
对于MyStringTypeHandler的要求是必须实现接口：org.apache.ibatis.type.TypeHandler，在MyBatis中，也可以继承org.apache.ibatis.type.BaseTypeHandler来实现，因为BaseTypeHandler已经实现了typeHandler接口。


代码里涉及了使用预编译（PreparedStatement）设置参数，获取结果集的时候使用的方法，并且给出日志；
自定义typeHandler里用注解配置JbdcType和JavaType。这两个注解是：
  ● @MappedTypes定义的是JavaType类型，可以指定那些Java类型被拦截；
  ● @MappedJdbcTypes定义的是JdbcType类型，它需要满足枚举类org.apache.ibatis.type.JdbcType所列的枚举类型；
我还需要去标识那些参数或者结果类型去用typeHandler进行转换，在没有任何标识的情况下，MyBatis是不会启用你定义的typeHandler进行转换结果的，所以还要给予对应的标识，比如配置jdbcType和javaType，或者直接用typeHandler属性指定，因此我们需要修改映射器的XML配置；



枚举类型typeHandler
在MyBatis中枚举类型的typeHandler则有自己特殊的规则，MyBatis内部提供了两个转化枚举类型的typeHandler给我们使用：

其中，EnumTypeHandler是使用枚举字符串名称座位参数传递的；
EnumOrdinalTypeHandler是使用整数下标作为参数传递的；
--------------------------------------------------------------------------------
environment配置环境
配置环境可以注册多个数据源（datasource），每个一个数据源分为两大部分：一个是数据库源的配置，另外一个是数据库事务（transactionManager）的配置；

  ● environments中的属性default，标明在缺省的情况下，我们将启用那个数据源配置；
  ● environment元素是配置一个数据源的开始，属性id是设置这个数据源的标志，以便MyBatis上下文使用它；
  ● transactionManager配置的是数据库事务，其中type属性有3种配置方式：
      ○ JDBC，采用JDBC方式管理事务，在独立编码中常常使用；
      ○ MANAGED，采用容器方式管理事务，在JNDI数据源中常用；
      ○ 自定义，由使用者自定义数据库事务管理办法，适用于特殊应用；
  ● property元素则是可以配置数据源的各类属性，这里配置了autoCommit=false则是要求数据源不自动提交；
  ● datasource标签，是配置数据源连接的信息，type属性是提供我们对数据库连接方式的配置，同样MyBatis提供这么几种配置方式：
      ○ UNPOOLED，非连接池数据库
      ○ POOLED，连接池数据库
      ○ JNDI，JNDI数据源
      ○ 自定义数据源

数据库事务
数据库事务MyBatis是交由SqlSession去控制的，我们可以通过SqlSession提交（commit）或者回滚（rollback）。

数据源
MyBatis内部提供了3种数据源的实现方式：
  ● UNPOOLED，非连接池，使用MyBatis提供的org.apache.ibatis.datasource.unpooled.UnpooledDataSource实现；
  ● POOLED，连接池，使用MyBatis提供的org.apache.ibatis.datasource.pooled.PooledDataSource实现；
  ● JNDI，使用MyBatis提供的org.apache.ibatis.datasource.jndi.JndiDataSourceFactory来获取数据源；
只需要把数据源的属性type定义为UNPOOLED、POOLED、JNDI即可；
如果使用自定义数据源，它必须实现org.apache.ibatis.datasource.DataSourceFactory接口。


databaseIdProvider数据库厂商标识
在相同数据库厂商的环境下，数据库厂商标识没有什么意义，在实际的应用中使用的比较少，因为使用不同的厂商的数据库系统还是比较少的，MyBatis可能会运行在不同厂商的数据库中，它为此提供一个数据库标识，并提供自定义，它的作用在于指定SQL到对应的数据库厂商提供的数据库中运行；

type=“DB_VENDOR”是启动MyBatis内部注册的策略器。首先MyBatis会将你的配置读入Configuration类里面，在连接数据库后调用getDatabaseProductName()方法去获取数据库的信息，然后用我们配置的name值去做匹配来得到DatabaseId。

MyBatis也提供规则允许自定义，只要实现databaseIdProvider接口，并且实现配置即可：


--------------------------------------------------------------------------------
引入映射器的方法
映射器是MyBatis最复杂、最核心的组件。

引入映射器的方法很多:

