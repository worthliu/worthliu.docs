### `Spring`事务

`Spring`事务处理模块是通过`AOP`功能来实现声明式事务处理；

在`Spring`事务处理中，可以通过设计一个`TransactionProxyFactoryBean`来使用`AOP`功能;
+ 通过这个`TransactionProxyFactoryBean`可以生成`Proxy`代理对象;
+ 在这个代理对象中，通过`TransactionInterceptor`来完成对代理方法的拦截，正是这些`AOP`的拦截功能，将事务处理的功能编制进来；


在使用`Spring`声明式事务处理的时候，一种常用的方法是结合`IOC`容器和`Spring`已有`TransactionProxyFactoryBean`对事务管理进行配置：

>1. 读取和处理在`IOC`容器中配置的事务处理属性，并转化为`Spring`事务处理需要的内部数据结构。
  + 具体来说，这里涉及的类是`TransactionAttributeSourceAdvisor`，从名字可以看出，它是一个AOP通知器，`Spring`使用这个通知器来完成对事务处理属性值的处理；
  + 处理的结果是，在`IOC`容器中配置的事务处理属性信息，会被读入并转化成`TransactionAttribute`表示的数据对象，这个数据对象是Spring对事物处理属性值的数据抽象，对这些属性的处理是和`TransactionProxyFactoryBean`拦截下来的事务方法的处理结合起来的；
2. Spring事务处理模块实现统一的事务处理过程；
  + 这个通用的事务处理过程包含处理事务配置属性，以及与线程绑定完成事务处理的过程，Spring通过`TransactionInfo`和`TransactionStatus`这两个数据对象，在事务处理过程中记录和传递相关的执行场景；
3. 底层的事务处理实现处理器，对于底层的事务操作，`Spring`委托给具体的事务处理器来完成;
  + 这些具体的事务处理器，就是IOC容器中配置声明式事务处理时，配置的`PlatformTransactionManager`的具体实现，比如`DataSourceTransactionManager`和`HibernateTransactionManager`等；


#### `Spring`事务配置

`Spring`配置文件中关于事务配置总是由三个组成部分，
 + 分别是`DataSource`
 + `TransactionManager`
 + `代理机制`
这三部分，无论哪种配置方式，一般变化的只是`代理机制`这部分。


#### `Propagation`（Spring事务的七种传播属性）

**`Propagation` ：key属性确定代理应该给哪个方法增加事务行为。**

这样的属性最重要的部份是传播行为。有以下选项可供使用：   

+ `PROPAGATION_REQUIRED`
  + **加入当前正要执行的事务不在另外一个事务里，那么就起一个新的事务**
  + 若`ServiceB.methodB`的事务级别定义为`PROPAGATION_REQUIRED`, 那么由于执行`ServiceA.methodA`的时候，`ServiceA.methodA`已经起了事务;
    + 这时调用`ServiceB.methodB`，`ServiceB.methodB`看到自己已经运行在`ServiceA.methodA`的事务内部，就不再起新的事务。
    + 假如`ServiceA.methodA`运行的时候发现自己没有在事务中，他就会为自己分配一个事务。
  + 这样，在`ServiceA.methodA`或者在`ServiceB.methodB`内的任何地方出现异常，事务都会被回滚。
  + 即使`ServiceB.methodB`的事务已经被提交，但是`ServiceA.methodA`在接下来`fail`要回滚，`ServiceB.methodB`也要回滚

+ `PROPAGATION_SUPPORTS`
  + **如果当前在事务中，即以事务的形式运行，如果当前不再一个事务中，那么就以非事务的形式运行**

+ `PROPAGATION_MANDATORY`
  + **必须在一个事务中运行。也就是说，他只能被一个父事务调用。否则，`就要抛出异常`**

+ `PROPAGATION_REQUIRES_NEW`
  + **新建事务，如果当前存在事务，把当前事务挂起。**
  + 若设计`ServiceA.methodA`的事务级别为`PROPAGATION_REQUIRED`，`ServiceB.methodB`的事务级别为`PROPAGATION_REQUIRES_NEW`;
  + 那么当执行到`ServiceB.methodB`的时候，`ServiceA.methodA`所在的事务就会挂起，`ServiceB.methodB`会起一个新的事务，等待`ServiceB.methodB`的事务完成以后，他才继续执行。
  + 他与`PROPAGATION_REQUIRED`的事务区别在于事务的回滚程度了。
    + 因为`ServiceB.methodB`是新起一个事务，那么就是存在两个不同的事务。
    + 如果`ServiceB.methodB`已经提交，那么`ServiceA.methodA`失败回滚，`ServiceB.methodB`是不会回滚的。
    + 如果`ServiceB.methodB`失败回滚，如果他抛出的异常被`ServiceA.methodA`捕获，`ServiceA.methodA`事务仍然可能提交。

+ `PROPAGATION_NOT_SUPPORTED`
  + **当前不支持事务。**
  + 比如`ServiceA.methodA`的事务级别是`PROPAGATION_REQUIRED` ，而`ServiceB.methodB`的事务级别是`PROPAGATION_NOT_SUPPORTED` ;
  + 那么当执行到`ServiceB.methodB`时，`ServiceA.methodA`的事务挂起，而他以非事务的状态运行完，再继续`ServiceA.methodA`的事务。

+ `PROPAGATION_NEVER`
  + **不能在事务中运行。**
  + 假设`ServiceA.methodA`的事务级别是`PROPAGATION_REQUIRED`， 而`ServiceB.methodB`的事务级别是`PROPAGATION_NEVER` ，那么`ServiceB.methodB`就要抛出异常了。

+ `PROPAGATION_NESTED`
  + 理解Nested的关键是`savepoint`。
  + 他与`PROPAGATION_REQUIRES_NEW`的区别是:
    + `PROPAGATION_REQUIRES_NEW`另起一个事务，将会与他的父事务相互独立;
    + `Nested`的事务和他的父事务是相依的，他的提交是要等和他的父事务一块提交的。也就是说，**如果父事务最后回滚，他也要回滚的**。


