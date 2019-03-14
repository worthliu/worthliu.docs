### Spring事务

Spring事务处理模块是通过`AOP`功能来实现声明式事务处理；

在Spring事务处理中，可以通过设计一个`TransactionProxyFactoryBean`来使用`AOP`功能，通过这个`TransactionProxyFactoryBean`可以生成`Proxy`代理对象，在这个代理对象中，通过`TransactionInterceptor`来完成对代理方法的拦截，正是这些`AOP`的拦截功能，将事务处理的功能编制进来；


在使用Spring声明式事务处理的时候，一种常用的方法是结合IOC容器和Spring已有`TransactionProxyFactoryBean`对事务管理进行配置：

>1. 读取和处理在IOC容器中配置的事务处理属性，并转化为Spring事务处理需要的内部数据结构。
具体来说，这里涉及的类是`TransactionAttributeSourceAdvisor`，从名字可以看出，它是一个AOP通知器，Spring使用这个通知器来完成对事务处理属性值的处理；
处理的结果是，在IOC容器中配置的事务处理属性信息，会被读入并转化成`TransactionAttribute`表示的数据对象，这个数据对象是Spring对事物处理属性值的数据抽象，对这些属性的处理是和`TransactionProxyFactoryBean`拦截下来的事务方法的处理结合起来的；
2. Spring事务处理模块实现统一的事务处理过程；这个通用的事务处理过程包含处理事务配置属性，以及与线程绑定完成事务处理的过程，Spring通过`TransactionInfo`和`TransactionStatus`这两个数据对象，在事务处理过程中记录和传递相关的执行场景；
3. 底层的事务处理实现处理器，对于底层的事务操作，Spring委托给具体的事务处理器来完成，这些具体的事务处理器，就是IOC容器中配置声明式事务处理时，配置的`PlatformTransactionManager`的具体实现，比如`DataSourceTransactionManager`和`HibernateTransactionManager`等；


#### Spring事务配置

Spring配置文件中关于事务配置总是由三个组成部分，分别是`DataSource`、`TransactionManager`和`代理机制`这三部分，无论哪种配置方式，一般变化的只是`代理机制`这部分。


#### `Propagation`（Spring事务的七种传播属性）

**`Propagation` ：key属性确定代理应该给哪个方法增加事务行为。**

这样的属性最重要的部份是传播行为。有以下选项可供使用：   

传播行为|解释|例子|
--|--|--|
`PROPAGATION_REQUIRED`|加入当前正要执行的事务不在另外一个事务里，那么就起一个新的事务|比如说，`ServiceB.methodB`的事务级别定义为`PROPAGATION_REQUIRED`, 那么由于执行`ServiceA.methodA`的时候，`ServiceA.methodA`已经起了事务，这时调用`ServiceB.methodB`，`ServiceB.methodB`看到自己已经运行在`ServiceA.methodA`的事务内部，就不再起新的事务。而假如`ServiceA.methodA`运行的时候发现自己没有在事务中，他就会为自己分配一个事务。这样，在`ServiceA.methodA`或者在`ServiceB.methodB`内的任何地方出现异常，事务都会被回滚。即使`ServiceB.methodB`的事务已经被提交，但是`ServiceA.methodA`在接下来`fail`要回滚，`ServiceB.methodB`也要回滚|
PROPAGATION_SUPPORTS|如果当前在事务中，即以事务的形式运行，如果当前不再一个事务中，那么就以非事务的形式运行||
PROPAGATION_MANDATORY|必须在一个事务中运行。也就是说，他只能被一个父事务调用。否则，他就要抛出异常||
PROPAGATION_REQUIRES_NEW|新建事务，如果当前存在事务，把当前事务挂起。|比如我们设计`ServiceA.methodA`的事务级别为`PROPAGATION_REQUIRED`，`ServiceB.methodB`的事务级别为`PROPAGATION_REQUIRES_NEW`，那么当执行到`ServiceB.methodB`的时候，`ServiceA.methodA`所在的事务就会挂起，`ServiceB.methodB`会起一个新的事务，等待`ServiceB.methodB`的事务完成以后，他才继续执行。他与`PROPAGATION_REQUIRED`的事务区别在于事务的回滚程度了。因为`ServiceB.methodB`是新起一个事务，那么就是存在两个不同的事务。如果`ServiceB.methodB`已经提交，那么`ServiceA.methodA`失败回滚，`ServiceB.methodB`是不会回滚的。如果`ServiceB.methodB`失败回滚，如果他抛出的异常被`ServiceA.methodA`捕获，`ServiceA.methodA`事务仍然可能提交。|
PROPAGATION_NOT_SUPPORTED|当前不支持事务。|比如`ServiceA.methodA`的事务级别是`PROPAGATION_REQUIRED` ，而`ServiceB.methodB`的事务级别是`PROPAGATION_NOT_SUPPORTED` ，那么当执行到`ServiceB.methodB`时，`ServiceA.methodA`的事务挂起，而他以非事务的状态运行完，再继续`ServiceA.methodA`的事务。|
PROPAGATION_NEVER|不能在事务中运行。|假设`ServiceA.methodA`的事务级别是`PROPAGATION_REQUIRED`， 而`ServiceB.methodB`的事务级别是`PROPAGATION_NEVER` ，那么`ServiceB.methodB`就要抛出异常了。|
PROPAGATION_NESTED|理解Nested的关键是`savepoint`。他与`PROPAGATION_REQUIRES_NEW`的区别是，`PROPAGATION_REQUIRES_NEW`另起一个事务，将会与他的父事务相互独立，而`Nested`的事务和他的父事务是相依的，他的提交是要等和他的父事务一块提交的。也就是说，如果父事务最后回滚，他也要回滚的。||

### 事务隔离级别

#### 首先什么是事务？
事务是应用程序中一系列严密的操作，所有操作必须成功完成，否则在每个操作中所作的所有更改都会被撤消。

也就是事务具有原子性，一个事务中的一系列的操作要么全部成功，要么一个都不做。

事务的结束有两种，当事务中的所以步骤全部成功执行时，事务提交。如果其中一个步骤失败，将发生回滚操作，撤消撤消之前到事务开始时的所以操作。

#### 事务的 ACID
**事务具有四个特征：`原子性(Atomicity)`、`一致性(Consistency)`、`隔离性(Isolation)`和`持续性(Durability)`。这四个特性简称为 ACID 特性。**
     
>1. `原子性`:**事务是数据库的逻辑工作单位，事务中包含的各操作要么都做，要么都不做**
2. `一致性`:**事务执行的结果必须是使数据库从一个一致性状态变到另一个一致性状态。因此当数据库只包含成功事务提交的结果时，就说数据库处于一致性状态。如果数运行中发生故障，有些事务尚未完成就被迫中断，这些未完成事务对数据库所做的修改有一部分已写入物理数据库，这时数据库就处于一种不正确的状态，或者说是 不一致的状态。**
3. `隔离性`:**一个事务的执行不能其它事务干扰。即一个事务内部的操作及使用的数据对其它并发事务是隔离的，并发执行的各个事务之间不能互相干扰。**
4. `持续性`:**也称永久性，指一个事务一旦提交，它对数据库中的数据的改变就应该是永久性的。接下来的其它操作或故障不应该对其执行结果有任何影响。**

#### Mysql的四种隔离级别
SQL标准定义了4类隔离级别，包括了一些具体规则，用来限定事务内外的哪些改变是可见的，哪些是不可见的。低级别的隔离级一般支持更高的并发处理，并拥有更低的系统开销。

隔离级别|效果|
--|--|
`Read Uncommitted（读取未提交内容）`|在该隔离级别，所有事务都可以看到其他未提交事务的执行结果。本隔离级别很少用于实际应用，因为它的性能也不比其他级别好多少。读取未提交的数据，也被称之为脏读（Dirty Read）|
`Read Committed（读取提交内容）`|这是大多数数据库系统的默认隔离级别（但不是MySQL默认的）。它满足了隔离的简单定义：一个事务只能看见已经提交事务所做的改变。这种隔离级别 也支持所谓的不可重复读（Nonrepeatable Read），因为同一事务的其他实例在该实例处理其间可能会有新的commit，所以同一select可能返回不同结果。|
`Repeatable Read（可重读）`|这是MySQL的默认事务隔离级别，它确保同一事务的多个实例在并发读取数据时，会看到同样的数据行。不过理论上，这会导致另一个棘手的问题：幻读 （Phantom Read）。简单的说，幻读指当用户读取某一范围的数据行时，另一个事务又在该范围内插入了新行，当用户再读取该范围的数据行时，会发现有新的“幻影” 行。InnoDB和Falcon存储引擎通过多版本并发控制（MVCC，Multiversion Concurrency Control）机制解决了该问题。|
`Serializable（可串行化）`|这是最高的隔离级别，它通过强制事务排序，使之不可能相互冲突，从而解决幻读问题。简言之，它是在每个读的数据行上加上共享锁。在这个级别，可能导致大量的超时现象和锁竞争。|

这四种隔离级别采取不同的锁类型来实现，若读取的是同一个数据的话，就容易发生问题。


数据库操作过程中,事务之间可能产生问题如下,由此衍生出数据库的四类隔离级别:

数据问题|解释|
--|--|
脏读(Drity Read)|某个事务已更新一份数据，另一个事务在此时读取了同一份数据，由于某些原因，前一个RollBack了操作，则后一个事务所读取的数据就会是不正确的。|
不可重复读(Non-repeatable read)|在一个事务的两次查询之中数据不一致，这可能是两次查询过程中间插入了一个事务更新的原有的数据。|
幻读(Phantom Read)|在一个事务的两次查询中数据笔数不一致，例如有一个事务查询了几列(Row)数据，而另一个事务却在此时插入了新的几列数据，先前的事务在接下来的查询中，就会发现有几列数据是它先前所没有的。|
