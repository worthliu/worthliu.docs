>MyBatis的运行分为两大部分：
+ 读取配置文件缓存到`Configuration`对象，用以创建`SqlSessionFactory`；
+ `SqlSession`的执行过程；

在`MyBatis`中，`Mapper`仅仅是一个接口，而不是一个包含逻辑的实现类。

**其运行是通过动态代理；`Mapper`产生了代理类，这个代理类是由`MyBatis`为我们创建；**

## 代理模式
所谓的代理模式就是在原有的服务上多加一个占位，通过这个占位去控制服务的访问；

>**为什么要使用代理模式？**
+ 通过代理，一方面可以控制如何访问真正的服务对象，提供额外服务。另外一方面有机会通过重写一些类来满足特定的需要；

一般而言，动态代理分为两种，一种是`JDK`反射机制提供的代理，另一种是`CGLIB`代理。

在`JDK`提供的代理，我们必须要提供接口，而`CGLIB`则不需要提供接口，在`MyBatis`里面两种动态代理技术都已经使用了。

### 反射技术
```
public class ReflectObject{
  public void sayHello(String name){
      System.out.println("hello" + name);
  }

  public static void main(String[] args) throws Exception{
      Object service = Class.forName(ReflectObject.class.getName()).newInstance();
      Method method = service.getClass().getMethod("sayHello", String.class);
      method.invoke(service, "worth");
  }
}
```
上述代码，通过反射技术去创建`ReflectObject`对象，获取方法后通过反射调用；

反射调用的最大好处是配置性大大提高，就如同`SpringIOC`容器一样，我们可以给很多配置设置参数，使得`Java`应用程序能够顺利运行起来，大大提高了`Java`的灵活性和可配置性，降低模块之间的耦合；

### JDK动态代理
JDK动态代理，是由JDK的`java.lang.reflect.*`包提供支持的。
>+ 编写服务类和接口,这个是真正的服务提供者,在JDK代理中接口是必须的;
+ 编写代理类,提供绑定和代理方法;

JDK的代理最大的缺点是需要提供接口，而  `MyBatis`的`Mapper`就是一个接口，它采用的就是JDK的动态代理；

>+ 提供一个服务接口
+ 提供一个具体实现类
+ 提供一个代理类，包含真实对象的绑定和代理方法。代理类的要求是实现`InvocationHandler`接口的代理方法，当一个对象被绑定后，执行其方法的时候就会进入到代理方法里。

![proxy.png](/images/mybatis/proxy.png)

>上述代码中产生一个代理对象，这个代理对象有三个参数：
+ 第一个参数`target.getClass().getClassLoader()`是类加载器，
+ 第二个参数`target.getClass().getInterfaces()`是接口（代理对象挂在那个接口下），
+ 第三个参数this代表当前`HelloServiceProxy`类，换句话说是使用`HelloServiceProxy`的代理方法作为对象的代理执行者；

>一旦绑定后，在进入代理对象方法调用的时候就回到`HelloServiceProxy`的代理方法`invoke()`上，代理方法有三个参数：
+ 第一个`proxy`是代理对象，
+ 第二个是当前调用的那个方法，
+ 第三个是方法的参数。

### CGLIB动态代理
JDK提供的动态代理存在一个缺陷，就是你必须提供接口才可以使用，为了克服这个缺陷，我们可以使用开源框架——`CGLIB`，它是一种流行的动态代理；

![cglib.png](/images/mybatis/cglib.png)

这样便能够实现`CGLIB`的动态代理。在`MyBatis`中通常在延迟加载的时候才会用到`CGLIB`的动态代理。

```
public class HelloServiceCGLIBMain(){
  public static void main(String[] args){
      HelloServiceCglib helloHandler = new HelloServiceCglib();
      HelloService cglibProxy = (HelloServiceImpl)helloHandler.getInstance(new HelloServiceImpl());
      cglibProxy.sayHello("worth");
  }
}
```

## 构建`SqlSessionFactory`过程
`SqlSessionFactory`是`MyBatis`的核心类之一，其最重要的功能就是提供创建`MyBatis`的核心接口`SqlSession`，所以我们需要先创建`SqlSessionFactory`，为此我们需要提供配置文件和相关的参数。

>`MyBatis`是一个复杂的系统，采用构造模式去创建`SqlSessionFactory`，我们可以通过`SqlSessionFactoryBuilder`去构建。构建分为两步：
1. 通过`org.apache.ibatis.builder.xml.XMLConfigBuilder`解析配置的XML文件，读出配置参数，并将读取的数据存入这个`org.apache.ibatis.session.Configuration`类中。（注意：`MyBatis`几乎所有的配置都是存在这里的）
2. 使用`Configuration`对象去创建`SqlSessionFactory`。`MyBatis`中的`SqlSessionFactory`是一个接口，而不是实现类，为此`MyBatis`提供了一个默认的`SessionFactory`实现类，我们一般都会使用它`org.apache.ibatis.session.default.DefaultSqlSessionFactory`.（**注意：在大部分情况下我们都没有必要自己去创建新的SqlSessionFactory的实现类**）

这样创建的方式就是一种`Builder`模式。对于复杂的对象而言，直接使用构造方法构建是有困难的，这回导致大量的逻辑放在构造方法中，由于对象的复杂性，在构建的时候，我们更希望一步步有秩序的来构建它，从而降低其复杂性。这个时候使用一个参数类总领全局，如Configuration类，然后分步构建，如`DefaultSqlSessionFactory`类，就可以构建一个复杂的对象，如`SqlSessionFactory`；

## 构建`Configuration`
在`SqlSessionFactory`构建中，`Configuration`是最重要的，作用如下：
>+ 读入配置文件,包括基础配置的XML文件和映射器的XML文件;
+ 初始化基础配置,比如MyBatis的别名等.一些重要的类对象,例如:插件、映射器、ObjectFactory和typeHandler对象；
+ 提供单例，位后续创建SessionFactory服务并提供配置的参数；
+ 执行一些重要的对象方法，初始化配置信息；

`MyBatis`的配置信息都是来自于`Configuration`，全局采用单态模式，将所有的配置信息保存为一个单例。`Configuration`是通过`XMLConfigBuilder`去构建的。

首先，`MyBatis`会读出所有`XML`配置的信息，然后，将这些信息保存到`Configuration`类的单例中。其会做如下的初始化：
>+ properties全局参数；
+ settings设置；
+ typeAliases别名；
+ typeHandler类型处理器；
+ ObjectFactory对象；
+ Plugin插件；
+ Environment环境；
+ DatabaseIdProvider数据库标识；
+ Mapper映射器；

## 映射器的内部组成
>一个映射器是由3个部分组成：
+ `MappedStatement`，它保存映射器的一个节点（`select|Insert|delete|update`）。包括许多我们配置的`SQL`、`SQL`的`id`、缓存信息、`resultMap`、`parameterType`、`resultType`、`languageDriver`等重要配置内容；
+ `SqlSource`，它是提供`BoundSql`对象的地方，它是`MappedStatement`的一个属性。
+ `BoundSql`，它是建立`SQL`和参数的地方。它有3个常用的属性：`SQL`、`parameterObject`、`parameterMappings`；

![mapperForm.png](/images/mybatis/mapperForm.png)

`MappedStatement`对象涉及的东西较多，一般都不去修改它，因为容易产生不必要的错误；

`SqlSource`是一个接口，它主要作用是根据参数和其他的规则组装SQL；

对于参数和`SQL`而言，主要的规则都反映在`BoundSql`类对象上，在插件中往往需要拿到它进而可以拿到当前运行的SQL和参数以及参数规则，做出适当的修改，来满足我们特殊的需求；（**这里对于不通过配置文件进行分页操作，就可以在这里进行了**）

`BoundSql`会提供3个主要的属性：`parameterMapping`、`parameterObject`和`sql`；

>+ 其中parameterObject为参数本身，可以传递简单对象，POJO、Map或者@Param注解的参数；
    + 传递简单对象（包括int、String、float、double等）；
    + 如果我们传递的是POJO或者Map，那么这个parameterObject就是你传入的POJO或者Map不变；
    + 传递多个参数，如果没有@Param注解，那么MyBatis就会把parameterObject变为一个Map<String,Object>对象，其键值的关系是按顺序来规划的，可以使用#{param1}或者#{1}去引用第一个参数；
    + 如果使用@Param注解，那么MyBatis就会把parameterObject也会变为一个Map<String,Object>对象，类似于没有@Param注解，只是把其中数字的键值对应置换为了@Param注解的键值；
+ parameterMappings，它是一个List，每一个元素都是ParameterMapping的对戏那个。这个对戏那个会描述我们的参数，参数包括属性、名称、表达式、javaType、jdbcType、typeHandler等重要信息。通过它可以实现参数和SQL的结合，以便PreparedStatement能够通过它找到parameterObject对象的属性并设置参数，使得程序准确运行；
+ sql属性就是在映射器里面的一条SQL；


## 构建SqlSessionFactory
有了`Configuration`对象构建`SqlSessionFactory`就很简单了：
```
sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
```
MyBatis会根据Configuration的配置读取所配置的信息，构建SqlSessionFactory对象；

## SqlSession运行过程
`SqlSession`是一个接口，使用它并不复杂。我们构建`SqlSessionFactory`就可以轻易地拿到`SqlSession`了。

`SqlSession`给出了查询、插入、更新、删除的方法；在新版`MyBatis`中我们建议使用`Mapper`，其就是`MyBatis`最为常用的和重要的接口之一；

### 映射器的动态代理

![mapperProxy.png](/images/mybatis/mapperProxy.png)

这里我们可以看到动态代理对接口的绑定，它的作用就是生成动态代理对象（占位）。而代理的方法则被放到了`MapperProxy`类中；
![mapperProxy2.png](/images/mybatis/mapperProxy2.png)

上面运用了`invoke`方法。一旦`mapper`是一个代理对象，那么它就会运行到`invoke`方法里面;

`invoke`首先判断它是否是一个类，显然这里`Mapper`是一个接口不是类，所以判定失败，那么就会生成`MapperMethod对象，它是通过cacheMapperMethod`方法对其初始化的，然后执行`execute()`方法，把`sqlSession`和当前运行的参数传递进去；

查看execute()方法源码如下：

![execute.png](/images/mybatis/execute.png)
![executeForMany.png](/images/mybatis/executeForMany.png)

`MapperMethod`采用命令模式运行，根据上下文跳转，它可能跳转到许多方法中，我们不需要全部明白。而`executeForMang（）`方法，其实际上是通过`sqlSession`对象去运行对象的`SQL`；
（**至此，我们可以知道MyBatis为什么只用Mapper接口便能够运行SQL，因为映射器的XML文件的命名空间对应的便是这个接口的全路径，那么它根据全路径和方法名便能绑定起来，通过动态代理技术，让这个接口跑起来。**

**而后采用命令模式匹配不同操作关键字操作，最后还是使用SqlSession接口的方法使得它能够执行查询，有了这层封装我们便可以使用接口编程**）

## SqlSession下的四大对象
映射器说到底就是一个动态代理对象，进入到了`MapperMethod`的`execute`方法。它经过简单判断就进入了`SqlSession`的删除、更新、插入、选择等方法；

那么对应具体的方法是如何执行呢？

显然通过类名和方法名字就可以匹配到我们配置的SQL；
`Mapper`执行的过程是通过`Executor`、`StatementHandler`、`ParameterHandler`和`ResultHandler`来完成数据库操作和结果返回的；

>+ Executor代表执行器，由它来调度StatementHandler、ParameterHandler、ResultHandler等来执行对应的SQL；
+ StatementHandler的作用是使用数据库的Statement(PreparedStatement)执行操作，它是四大对象的核心，起到承上启下的作用；
+ ParameterHandler用于SQL对参数的处理；
+ ResultHandler是进行最后数据集（ResultSet）的封装返回处理的；

### Executor执行器
它是一个真正执行的Java和数据库交互的东西。

在MyBatis中存在三种执行器。可以在MyBatis的配置文件中进行选择（setting元素的属性defaultExecutorType）：
>+ SIMPLE：简易执行器，不配置它就是默认执行器；
+ REUSE：是一种执行器重用预处理语句；
+ BATCH：执行器重用语句和批量更新，它是针对批量专用的执行器；
![newExecutor.png](/images/mybatis/newExecutor.png)

MyBatis将根据配置类型去确认你需要创建三种执行器中的哪一种，在创建对象后，它会去执行一行代码：
```
executor = (Executor)interceptorChain.pluginAll(executor);
```
这就是MyBatis的插件，这里它将为我们构建一层层的动态代理对象。在调度真实的Executor方法之前执行配置插件的代码可以修改
![simpleExecutor.png](/images/mybatis/simpleExecutor.png)

从上面可以看出MyBatis根据`Configuration`来构建`StatementHandler`，然后使用`PreparedStatement`方法，对SQL编译并对参数进行初始化；

它的实现过程，它调用了`StatementHandler`的`prepare()`进行了预编译和基础设置，然后通过`StatementHandler`的`parameterize()`来设置参数并执行，`resultHandler`再组装查询结果返回给调用者来完成一次查询。

### 数据库会话器（StatementHandler）
StatementHandler就是专门处理数据库会话的；

创建的真实对象是一个`RoutingStatementHandler`对象，它实现接口`StatementHandler`。和`Executor`一样，用代理对象做一层层的封装；

>`RoutingStatementHandler`不是我们真实的服务对象，它是通过适配器模式找到对应的`StatementHandler`来执行的。

>在MyBatis中，`StatementHandler`和`Executor`一样分为三种：
+ `SimpleStatementHandler`
+ `PreparedStatementHandler`
+ `CallableStatementHandler`

在初始化 `RoutingStatementHandler`对象的时候它会根据上下文环境决定创建那个`StatementHandler`对象：

`StatementHandler`定义了一个对象的适配器`delegate`，它是一个`StatementHandler`接口对象，构造方法根据配置来适配对应的`StatementHandler`对象。它的作用是给实现类对象的使用提供一个统一、简易的使用适配器。
以`PreparedStatementHandler`为例：

>`instantiateStatement()`方法是对SQL进行了预编译。首先，做一些基础配置，比如超时、获取的最大行数等的设置。然后，`Executor`会调用`paramenterize()`方法去设置参数（这个是调用`ParameterHandler`完成）：

>由于在执行前参数和SQL都被`prepare()`方法预编译，参数在`parameterize()`方法上已经进行了设置。所以这里只要执行SQL，然后返回结果就可以了。执行后`ResultSetHandler`对结果的封装和返回；

>Executor会先调用StatementHandler的prepare()方法预编译SQL语句，同时设置一些基本运行的参数，然后用parameterize()方法启用ParameterHandler设置参数，完成预编译，跟着就是执行查询，而update()也是这样的，最后如果需要查询，我们就用ResultSetHandler封装结果返回给调用者；

### 参数处理器（ParameterHandler）
在MyBatis中是通过参数处理器（ `ParameterHandler`）对预编译语句进行参数设置的。它的作用是明显的，那就是完成对预编译参数的设置。

其中，`getParameterObject()`方法的作用是返回参数对象，`setParameters()`方法的作用是设置预编译SQL语句的参数。

MyBatis为`ParameterHandler`提供了一个实现类`DefaultParameterHandler`：

**它还是从`parameterObject`对象中取参数，然后使用`typeHandler`进行参数处理，如果你有设置，那么它就会根据签名注册的`typeHandler`对参数进行处理。而`typeHandler`也是在`MyBatis`初始化的时候，注册在`Configuration`里面的；**

### 结果处理器（StatementHandler）

其中，`handlerOutputParameters（）`方法是处理存储过程输出参数的；

`handlerResultSets（）`方法，它是包装结果集的。

**MyBatis同样为我们提供了一个`DefaultResultSetHandler`类，在默认的情况下都是通过这个类进行处理的。这个实现有些复杂，它涉及使用`JAVAssist`或者`CGLIB`作为延迟加载，然后通过`typeHandler`和`ObjectFactory`进行组装结果在返回。**

## SqlSession运行总结

>`SqlSession`是通过`Executor`创建`StatementHandler`来运行的，而`StatementHandler`要经过下面三步：
+ `prepared`预编译SQL
+ `parameterize`设置参数
+ `query/update`执行SQL

![sqlSession.png](/images/mybatis/sqlSession.png)
