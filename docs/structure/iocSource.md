## IOC容器的初始化

初始化由`refresh()`方法来启动，包含三个过程：`BeanDefinition`的`Resource定位`、`载入`和`注册`：
>+ `Resource`定位过程：由`ResourceLoader`通过统一的`Resource`接口来完成：
   + 文件系统中的`Bean`定义信息使用`FileSystemResource`；
   + 类路径中的`Bean`定义信息使用`ClassPathResource`；
+ `BeanDefinition`的载入：把用户定义好的Bean表示成IOC容器内部的数据结构，而这个容器内部的数据结构就是`BeanDefinition`；
+ 向IOC容器注册`BeanDefinition`：调用`BeanDefinitionRegistry`接口的实现来完成的；
  + 在IOC容器内部将`BeanDefinition`注入到一个`Map`中，容器通过这个`HashMap`来持有这些`BeanDefinition`数据的；

初始化过程中，不包含`Bean`依赖注入的实现，依赖注入一般发生在应用第一次通过`getBean`向容器索取`Bean`的时候。

+ 通过`Bean`定义信息中`lazyinit`属性，可以预实例化`Bean`；
+ 对某个`Bean`设置了`lazyinit`属性，那么这个`Bean`的依赖注入在IOC容器初始化时就预先完成了，而不需要等到整个初始化完成以后，第一次使用`getBean`时才会触发;

对于`Lazyinit`属性默认值为`false`，`Spring`默认对`singleton`是预加载的，当其设置为`true`时，只有通过`getBean`才会触发加载产生`Bean`;

## IOC容器的依赖注入

上述的初始化过程完成的主要工作**是在IOC容器中建立`BeanDefinition`数据映射**；

首先，`依赖注入`的过程是用户第一次向`IOC容器`索要`Bean`时触发的;

当然，也可以在`BeanDefinition`信息中通过控制`lazyinit`属性来让容器完成对`Bean`的预实例化。

IOC容器接口`BeanFactory`中，`getBean`的接口实际就是触发依赖注入发生的地方:
+ `getBean()`,主要实现在`DefaultListableBeanFactory`的基类`AbstractBeanFactory`中：
  + `AbstractBeanFactory.getBean()`-->`doGetBean()`--->
  + `AbstractAutowireCapableBeanFactory.createBean()`-->
  + `doCreateBean()`-->`createBeanInstance()`-->`instantiateBean()`-->`populateBean()`
  + `SimpleInstantiationStrategy.instantiate()`

![ioc](/images/ioc.png)

```SimpleInstantiationStrategy
	public Object instantiate(RootBeanDefinition bd, @Nullable String beanName, BeanFactory owner) {
		// Don't override the class with CGLIB if no overrides.
		if (bd.getMethodOverrides().isEmpty()) {
			//这里取得指定的构造器或者生成对象的工厂方法来对Bean进行实例化
			Constructor<?> constructorToUse;
			synchronized (bd.constructorArgumentLock) {
				constructorToUse = (Constructor<?>) bd.resolvedConstructorOrFactoryMethod;
				if (constructorToUse == null) {
					final Class<?> clazz = bd.getBeanClass();
					if (clazz.isInterface()) {
						throw new BeanInstantiationException(clazz, "Specified class is an interface");
					}
					try {
						if (System.getSecurityManager() != null) {
							constructorToUse = AccessController.doPrivileged(new PrivilegedExceptionAction<Constructor<?>>() {
								@Override
								public Constructor<?> run() throws Exception {
									return clazz.getDeclaredConstructor((Class[]) null);
								}
							});
						}
						else {
							constructorToUse =	clazz.getDeclaredConstructor((Class[]) null);
						}
						bd.resolvedConstructorOrFactoryMethod = constructorToUse;
					}
					catch (Throwable ex) {
						throw new BeanInstantiationException(clazz, "No default constructor found", ex);
					}
				}
			}
			//通过BeanUtils进行实例化，这个BeanUtils的实例化通过Constructor来实例化Bean
			//在BeanUtils中可以看到具体的调用ctor.newInstance(args)
			return BeanUtils.instantiateClass(constructorToUse);
		}
		else {
			// Must generate CGLIB subclass.
			//这里使用子类CglibSubclassingInstantiationStrategy，采用CGLIB来实例化对象
			return instantiateWithMethodInjection(bd, beanName, owner);
		}
	}
```

这里使用一个常用的字节码生成器的类库，它提供了一系列的API来提供生成和转换Java的字节码的功能；
在实例化Bean的话时候，有两种方法：
+ 通过`BeanUtils.instantiateClass`以JDK提供的反射机制实例化
+ 通过`CGLIB`通过字节码库实例化

## IOC的容器

在Spring IOC容器的设计中，有两个主要容器系列：

+ 是实现了`BeanFactory`接口的简单容器系列，只实现了容器的最基本功能；
+ `ApplicationContext`应用上下文，它作为容器的高级形态而存在。

增加了许多面向框架的特性，同时对应用环境作了许多适配；


Spring通过定义`BeanDefinition`来管理基于Spring的应用中的各种对象以及它们之间的相互依赖关系；

`BeanDefinition`抽象了我们对Bean的定义，是让容器起作用的主要数据类型；

+ 从接口`BeanFactory`到`HierarchicalBeanFactory`，再到`ConfigurableBeanFactory`，是一条主要的`BeanFactory`设计路径；
  + `BeanFactory`接口定义了基本的IOC容器的规范（`getBean()`可以从容器中取得Bean）
  + `HierarchicalBeanFactory`接口在继承了`BeanFactory`基础之上，增加了`getParentBeanFactory()`的接口功能，使`BeanFactory`具备了双亲IOC容器的管理功能；
  + `ConfigurableBeanFactory`，主要定义了对`BeanFactory`配置功能（如：通过`setParentBeanFactory()`设置双亲IOC容器，通过`addBeanPostProcessor()`配置Bean后置处理器）
+ 以`ApplicationContext`应用上下接口为核心，从`BeanFactory`到`ListableBeanFactory`，再到`ApplicationContext`，再到我们常用的`WebApplicationContext`或者`ConfigurableApplicationContext`接口；
  + `ApplicationContext`接口，它通过继承`MessageSource`、`ResourceLoader`、`ApplicationEventPublisher`接口，在`BeanFactory`简单IOC容器的基础上添加了许多对高级容器的特性的支持；
(具体容器实现：`DefaultListableBeanFactory`)

### `BeanFactory`的应用场景
用户可以通过`BeanFactory`接口方法中的`getBean`来使用`Bean`名字，从而在获取`Bean`时：
+ 通过接口方法`containsBean`让用户能够判断容器是否含有指定名字的Bean；
+ 通过接口方法`isSingleton`来查询指定名字的`Bean`是否是`Singleton`类型的Bean；
  + 对于`Singleton`属性，用户可以在`BeanDefinition`中指定；
+ 通过接口方法`isPrototype`来查询指定名字的Bean是否是`prototype`类型的，与`Singleton`一样，可以由用户在`BeanDefinition`中指定；
+ 通过接口方法`isTypeMatch`来查询指定了名字的`Bean`的`Class`类型是否是特定的`Class`类型；
+ 通过接口方法`getType`来查询指定名字的`Bean`的`Class`类型
+ 通过接口方法`getAliases`来查询指定了名字的Bean的所有别名，这些别名都是用户在`BeanDefinition`中定义的；