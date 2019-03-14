### IOC
Spring容器通常理解为BeanFactory或者ApplicationContext；

>**BeanFactory与ApplicationContext的区别是什么？**
+ BeanFactory采用了工厂设计模式，负责读取bean配置文档，管理bean的加载，实例化，维护bean之间的依赖关系，负责bean的声明周期。
+ ApplicationContext除了提供上述BeanFactory所能提供的功能之外，还提供了更完整的框架功能：国际化支持、aop、事务等。
+ 同时BeanFactory在解析配置文件时并不会初始化对象,只有在使用对象getBean()才会对该对象进行初始化，而ApplicationContext在解析配置文件时对配置文件中的所有对象都初始化了,getBean()方法只是获取对象的过程；


>1. bean的创建：   
  1. 如果我们默认的scope配置为Singleton的话， bean的创建实在Spring容器创建的时候创建； 
  2. 如果scope的配置为Prototype的话，bena的创建是在getBean的时候创建的。 
  3. 同样我们还可以在`<bean>`的配置中配置`lazy-init = "true"`是bean的创建在getBean时。
2. 我们有时候可能在bean完成之后可能想要打开一些资源。 
  1. 我们可以配置`init-method="init"`, init方法在调用了类的默认构造函数之后执行；
3. 如果我们想在bean销毁时，释放一些资源。
  1. 我们可以配置`destroy-method="destroy"`, destroy方法在bean对象销毁时执行；


### AOP

AOP是Aspect-Oriented programming（面向切面）

>+ AOP联盟定义的AOP体系结构把与AOP相关的概念大致分为由高到低，从使用到实现的三个层次；
1. `Advice通知`，定义在连接点做什么，为切面增强提供织入接口。在`Spring AOP`中，它主要描述`Spring AOP`围绕方法调用而注入的切面行为。具体的接口定义在`org.aopalliance.aop.Advice`;
2. `Pointcut切点`，决定`Advice`通知应该作用于那个连接点，也就是说通过`Pointcut`来定义需要增强的方法的集合，这些集合的选取可以按照一定的规则来完成。
Pointcut通常意味标识方法，例如需要增强的地方可以由某个正则表达式进行标识，或根据某个方法名进行匹配等；
3. `Advisor通知器`，完成对目标方法的切面增强设计（Advice）和关注点的设计（`Pointcut`）以后，需要一个对象把他们给结合起来，完成这个作用的就是`Advisor`（通知器）。
通过`Advisor`，可以定义应该使用那个通知并在那个关注点使用它，也就是说通过`Advisor`，把`Advice`和`Pointcut`结合起来，这个结合为使用`IOC`容器配置`AOP`应用，或者说即开即用地使用`AOP`基础设施，提供了便利；

#### AOP的设计与实现：
1. JVM的动态代理特性
  + 在Spring AOP实现中，使用的核心技术是动态代理，而这种动态代理实际上是JDK的一个特性。
  + 通过JDK的动态代理特性，可以为任意Java对象创建代理对象，对于具体使用来说，这个特性是通过Java Reflection API（反射）来完成；
2. Proxy模式：
  + 在代理模式的设计中，会设计一个接口和目标对象一致的代理对象Proxy，它们都实现了接口Subject的request方法；
  + 在这种情况下，对目标对象的request的调用，往往就被代理对象“浑水摸鱼”给拦截了，通过这种拦截，为目标对象的方法操作做了铺垫，所以称之为代理模式；

可以在Java的`reflection`包中看到`proxy`对象，这个对象生成后，所起的作用就类似于`Proxy`模式中的`Proxy`对象。

在使用时，还需要为代理对象（Proxy）设计一个回调方法，这个回调方法起到的作用是，在其中加入了作为代理需要额外处理的动作；

在JDK回调方法就是`InvocationHandler`接口，这个接口方法中，只声明了一个`invoke`方法，这个`invoke`方法的第一个参数是代理对象实例，第二个参数是`Method`方法对象，代表的是当前`Proxy`被调用的方法，最后一个参数是被调用的方法中的参数；
 


