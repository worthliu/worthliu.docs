**MyBatis四大对象的运行过程，在`Configuration`对象的创建方法里我们看到了`MyBatis`用责任链模式去封装它们；**

**换句话，我们有机会在四大对象调度的时候插入我们代码去执行一些特殊的要求以满足特殊场景需求；（插件技术）**

## 插件接口
在MyBatis中使用插件，我们必须实现接口`Interceptor`：

```
public interface Interceptor{
	Object intercept(Invocation invocation) throws Throwable;

	Object plugin(Object target);

	void setProperties(Properties properties);
}
```

>在接口中,运用了3个方法:
+ `intercept`方法：它将直接覆盖你所拦截对象原有的方法，因此它是插件的核心方法。intercept里面有个参数Invocation对象，通过它可以反射调度原来对象的方法；
+ `plugin`方法：`target`是被拦截对戏那个，它的作用是给被拦截对象生成一个代理对象，并返回它。为了方便`MyBatis`使用`org.apache.ibatis.plugin.Plugin`中的wrap静态方法提供生成代理对象，我们往往使用plugin方法便可以生成一个代理对象了；
+ `setProperties`方法：允许在plugin元素中配置所需要参数，方法在插件初始化的时候就被调用了一次，然后把插件对象存入到配置中，以便后面再取出；

## 插件的初始化
插件的初始化是在MyBatis初始化的时候完成，通过`XMLConfigBuilder`中的代码便可知道：
![pluginInit.png](/images/mybatis/pluginInit.png)

**在解析配置文件的时候，在MyBatis的上下文初始化过程中，就开始读入插件节点和我们配置的参数，同时使用反射技术生成对应的插件实例，然后调用插件方法中的setProperties方法，设置我们配置的参数，然后将插件实例保存到配置对象中，以便读取和使用它。**

所以插件的实例对象是一开始就被初始化的，而不是用到的时候才初始化的，我们使用它的时候，直接拿出来就可以了，这样有助与性能的提高；

`InterceptorChain`在`Configuration`里面是一个属性，它里面有个`addInterceptor`方法：

### 插件的代理和反射设计
插件用的是责任链模式，首先什么是责任链模式，就是一个对象，在MyBatis中可能是四大对象中的一个，在多个角色中传递，处于传递链上的任何角色都有处理它的机会。

MyBatis的责任链是由intercetorChain去定义的（创建执行器有如下代码）：
```
executor = (Executor)interceptorChain.pluginAll(executor);

public Object pluginAll(Object target){
	for(Interceptor interceptor : interceptors){
		target = interceptor.plugin(target);
	}
	return target;
}
```

**plugin方法是生成代理对象的方法，当它取出插件的时候是从Configuration对象中去取出的。**

**从第一个对象（四大对象中的一个）开始，将对象传递给了plugin方法，然后返回一个代理；**

**如果存在第二个代理，那么我们就拿到第一个代理对象，传递给plugin方法再返回第一个代理对象的代理（以此类推），有多少个拦截器就生成多少个代理对象。**

**MyBatis中提供了一个常用的工具类，用来生成代理对象，它便是Plugin类。Plugin类实现了InvocationHandler接口，采用的是JDK的动态代理：**

![pluginProxy.png](/images/mybatis/pluginProxy.png)

这是一个代理对象，其中wrap方法为我们生成这个对象的动态代理对象。invoke方法，如果你使用这个类为插件生成代理对象，那么代理对象在调用方法的时候就会进入到invoke方法中。在invoke方法中，如果存在签名的拦截方法，插件的intercept方法就会被我们在这里调用，然后就返回结果。如果不存在签名方法，那么将直接反射调度我们要执行的方法；

这个方法就是调度被代理对象的真实方法。

在初始化的时候，加载插件实例，并共`setProperties()`方法进行初始化。可以使用MyBaatis提供的`Plugin.wrap`方法区生成代理对象，再一层层地使用`Invocation`对象的`proceed`方法来推动代理对象运行。

所有在多插件的环境下，调度`proceed`方法时，MyBatis总是从最后一个代理对象运行到第一个代理对象最后是真实被拦截的对象方法被运行。

### 常用的工具类——MetaObject
`MetaObject`，它可以有效读取或者修改一些重要对象的属性。在`MyBatis`中，四大对象给我们提供的`public`设置参数的方法很少，我们难以通过其自身得到相关的属性信息，但是有了`MetaObject`这个工具类我们就可以通过其他的技术手段来读取或者修改这些重要对象的属性。
> + `MetaObject forObject(Object object, ObjectFactory objectFactory, ObjectWarapperFactory objectWrapperFactory)`方法用于包装对象，这个方法我们已经不再使用了，而是用MyBatis为我们提供的`SystemMetaObject.forObject(Object obj)`;
+ `Object getValue(String name)`方法用于获取对象属性值，支持OGNL；
  + `void setValue(String name, Object value)`方法用于修改对象属性值，支持OGNL；

在MyBatis对象总大量使用了这个类进行包装，包括四大对象，使得我们可以通过它来给四大对象的某些属性赋值从而满足我们的需要；

## 插件开发过程和实例

确定需要拦截的签名，正如`MyBatis`插件可以拦截四大对象中的任意一个一样。

从`Plugin`源码中我们可以看到它需要注册签名才能够运行插件：

1. 确定需要拦截的对象：
+ 首先要根据功能来确定你需要拦截什么对象：
  + `Executor`是执行SQL的全过程，包括组装参数，组装结果集返回和执行SQL过程，都可以拦截，较为广泛，我们一般用的不算太多；
  + `StatementHandler`是执行SQL的过程，我们可以重写执行SQL的过程。这是我们最常用的拦截对象；
  + `ParameterHandler`，很明显它主要是拦截执行SQL的参数组装，你可以重写组装参数规则；
  + `ResultSetHandler`用于拦截执行结果的组装，你可以重写组装结果的规则；

我们清除需要拦截的是`StatementHandler`对象，应该在预编译SQL之前，修改SQL使得结果返回数量被限制；

2. 拦截方法和参数
当你确定了需要拦截什么对象，接下来就要确定需要拦截什么方法及方法的参数，这些都是在你理解了MyBatis四大对象运作的基础上才能确定的；

查询的过程是通过Executor调度`StatementHandler`来完成的。调度`StatementHandler`的`prepare`方法预编译SQL，于是我们需要拦截的方法便是`prepare`方法，在此之前完成 SQL的重新编写。

prepare方法预编译SQL，于是我们需要拦截的方法便是perpare方法，在此之前完成SQL的重新编写。

```
public interface StatementHandler{
	Statement prepare(Connection connection) throws SQLException;

	void parameterize(Statement statement) throws SQLException;

	void batch(Statement statement) throws SQLException;

	int update(Statement statement) throws SQLException;

	<E> List<E> query(Statement statement, ResultHandler resultHandler)  throws SQLException;

	BoundSql getBoundSql();

	ParameterHandler getParameterHandler();
}
```

```
@Intercepts({@Signature(type=StatementHandler.class,
			 method="prepare", args={Connection.class})})
public class MyPlugin implements Interceptor{
	****
}
```
其中`@Intercepts`说明它是一个拦截器，`@Signature`是注册拦截器签名的地方，只有满足签名条件才能拦截，`type`可以是四大对象中的一个，`method`代表要拦截四大对象的某一种接口方法，而`args`则表示该方法的参数，你需要根据拦截对象的方法参数进行设置；

### 实现拦截方法

![MyPlugin.png](/images/mybatis/MyPlugin.png)

## 配置和运行
要使用插件，需在MyBatis配置文件里面配置，如下：

```
<plugins>
	<plugin interceptor="xxx.MyPlugin">
		<property name="dbType" value="mysql"/>
	</plugin>
</plugins>
```
我们需要清楚配置的那个类是插件。它会去解析注解，知道拦截那个对象、方法和方法的参数，在初始化的时候就会调用`setProperties()`方法，初始化参数；

## 插件实例
实现对数据库查询返回数据量限制，以避免数据量过大造成网站瓶颈。

首先先确定需要拦截四大对象中哪一个，根据功能我们需要修改SQL的执行。`SqlSession`运行原理告诉我们需要拦截的是`StatementHandler`对象，因为是由它的`prepare`方法来预编译`SQL`语句的，我们可以在预编译前修改语句来满足需求。

![QueryLimitPlugin.png](/images/mybatis/QueryLimitPlugin.png)

在`setProperties`方法中可以读入配置给插件的参数；

在`plugin`方法里，使用了`MyBatis`提供的类来生成代理对象。

那么插件就会进入`plugin`的`invoke`方法，它最后会使用到拦截器的intercept方法。

这个插件的`intercept`方法就会覆盖掉`StatementHandler`的`perpare`方法，我们先从代理对象分离出真实对象，然后根据需要修改SQL，来达到限制返回行数的需求。

最后使用`invocation.proceed()`来调度真实`StatementHandler`的`prepare`方法完成`SQL`预编译，最后需要在`MyBatis`配置文件里面才能运行这个插件。

```
<plugins>
	<plugin interceptor="xxx.QueryLimitPlugin">
		<property name="dbType" value="mysql"/>
		<property name="limit" value="50"/>
	</plugin>
</plugins>
```
>+ 能不用插件尽量不要用插件,因为它将修改`MyBatis`的底层设计;
+ 插件生成的是层层代理对象的责任链模式,通过反射方法运行,性能不高,所以减少插件就能减少代理,从而提高系统的性能;
+ 编写插件需要了解`MyBatis`的运行原理,了解四大对象及其方法的作用,准确判断需要拦截什么对象,什么方法,参数是什么,才能确定签名如何编写;
+ 在插件中往往需要读取和修改`MyBatis`映射器中的对象属性,你需要熟练掌握关于`MyBatis`映射器内部组成的知识;
+ 插件的代码编写要考虑全面,特别是多个插件层层代理的时候,要保证逻辑的正确性;
+ 尽量少改动`MyBatis`底层的东西,以减少错误的发生;