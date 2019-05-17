## `AOP`组件

### `Advice`通知

定义在连接点做什么，为切面增强提供织入接口。

**`它要描述Spring AOP围绕方法调用而注入的切面行为；`**

+ `BeforeAdvice` ： 
  + `MethodBeforeAdvice` :为待增强的目标方法设置的前置增强接口
+ `AfterAdvice` ： 
  + `AfterReturningAdvice` : 在目标方法调用结束并成功返回的时候，被AOP回调
+ `ThrowsAdvice` ： AOP通过使用反射机制，在方法抛出异常时回调


### `Pointcut`切点

决定`Advice`通知应该作用于那个连接点，也就是说通过`Pointcut`来定义需要增强的方法的集合，这些集合的选取可以按照一定的规则来完成；

### `Advisor`通知器

定义应该使用那个通知并在那个关注点使用它，也就说通过`Advisor`，把`Advice`和`Pointcut`结合起来；

## `AOP`的设计
`Spring AOP`起作用，需要完成一系列过程：
+ 为目标对象建立代理对象;
  + 这个代理对象可以通过使用`JDK`的`Proxy`来完成;
  + 也可以通过第三方的类生成器`CGLIB`完成。
+ 启动代理对象的拦截器来完成各种横切面的织入;
  + 这一系列的织入设计是通过一系列`Adapter`来实现的。
  + 通过`Adapter`的设计，可以把`AOP`的横切面设计和`Proxy`模式有机地结合起来，从而实现在`AOP`中定义好的各种织入方式；


### 建立`AopProxy`代理对象

在`Spring`的`AOP`模块中，一个主要的部分是代理对象的生成;

而对于`Spring`应用，可以看到，是通过配置和调用`Spring`的`ProxyFactoryBean`来完成这个任务的。
+ 在`ProxyFactoryBean`中，封装了主要代理对象的生成过程。
+ 在这个使用JDK的`Proxy`和`CGLIB`两种生成方式；

>+ `ProxyConfig`一个数据基类，为`ProxyFactoryBean`这样子类提供了配置属性；
+ `AdvisedSupport`封装了`AOP`对通知和通知器的相关操作；
+ `ProxyCreatorSupport`创建`AOP`代理对象的一个辅助类；
+ 具体的`AOP`代理对象的生成，根据不同的需要，分别由`ProxyFactoryBean`、`AspectJProxyFactory`和`ProxyFactory`来完成；
  + `ProxyFactoryBean`，可以在`IOC`容器中完成**声明式配置**；
  + `ProxyFactory`，则需要编程式地使用`Spring AOP`的功能;

#### `ProxyFactoryBean`的配置和使用：

在基于`XML`配置`Spring`的`Bean`时，需要一系列的配置步骤来使用：
+ 定义使用的通知器`Advisor`，这个通知器应该作为一个`Bean`来定义；
  + 这个通知器的实现**定义了需要对目标对象进行增强的切面行为**，就是`Advice`通知
+ 定义`ProxyFactoryBean`，把它作为另一种`Bean`来定义，它是封装`AOP`功能的主要类；
  + 在配置`ProxyFactoryBean`时，需要设定与`AOP`实现相关的重要属性：
    + `proxyInterface`，设置代理对象的接口
    + `interceptorNames`，设置需要定义的通知器
    + `target`
+ 定义`target`属性，作为`target`属性注入的`Bean`，是需要用`AOP`通知器中切面应用来增强的对象；

`ProxyFactoryBean`生成`AopProxy`代理对象
+ 在`ProxyFactoryBean`中，通过`interceptorNames`属性来配置已经定义好的通知器`Advisor`。
  + `interceptorNames`实际上是提供`AOP`应用配置通知器的地方
+ 在`ProxyFactoryBean`中，需要为`target`目标对象生成`Proxy`代理对象，从而为`AOP`横切面的编织做好准备工作。
+ `ProxyFactoryBean`的AOP实现需要依赖JDK或者CGLIB提供的Proxy特性。
  + 从`FactoryBean`中获取对象，是以`getObject()`方法作为入口完成的；
+ `ProxyFactoryBean`实现中的`getObject()`方法，是`FactoryBean`需要实现的接口。
+ `getObject()`方法首先对通知器链进行初始化，通知器链封装了一系列的拦截器，这些拦截器都要从配置读取，然后为代理对象的生成做好准备；


```ProxyFactoryBean
	@Override
	@Nullable
	public Object getObject() throws BeansException {
		// 初始化通知调用链
		initializeAdvisorChain();
		if (isSingleton()) {
			return getSingletonInstance();
		}
		else {
			if (this.targetName == null) {
				logger.info("Using non-singleton proxies with singleton targets is often undesirable. " +
						"Enable prototype proxies by setting the 'targetName' property.");
			}
			return newPrototypeInstance();
		}
	}
```
```ProxyFactoryBean
	private synchronized Object getSingletonInstance() {
		if (this.singletonInstance == null) {
			this.targetSource = freshTargetSource();
			if (this.autodetectInterfaces && getProxiedInterfaces().length == 0 && !isProxyTargetClass()) {
				// Rely on AOP infrastructure to tell us what interfaces to proxy.
				Class<?> targetClass = getTargetClass();
				if (targetClass == null) {
					throw new FactoryBeanNotInitializedException("Cannot determine target class for proxy");
				}
				setInterfaces(ClassUtils.getAllInterfacesForClass(targetClass, this.proxyClassLoader));
			}
			// Initialize the shared singleton instance.
			super.setFrozen(this.freezeProxy);
			this.singletonInstance = getProxy(createAopProxy());
		}
		return this.singletonInstance;
	}
```
```ProxyFactoryBean

	private synchronized Object newPrototypeInstance() {
		// In the case of a prototype, we need to give the proxy
		// an independent instance of the configuration.
		// In this case, no proxy will have an instance of this object's configuration,
		// but will have an independent copy.
		if (logger.isTraceEnabled()) {
			logger.trace("Creating copy of prototype ProxyFactoryBean config: " + this);
		}

		ProxyCreatorSupport copy = new ProxyCreatorSupport(getAopProxyFactory());
		// The copy needs a fresh advisor chain, and a fresh TargetSource.
		TargetSource targetSource = freshTargetSource();
		copy.copyConfigurationFrom(this, targetSource, freshAdvisorChain());
		if (this.autodetectInterfaces && getProxiedInterfaces().length == 0 && !isProxyTargetClass()) {
			// Rely on AOP infrastructure to tell us what interfaces to proxy.
			Class<?> targetClass = targetSource.getTargetClass();
			if (targetClass != null) {
				copy.setInterfaces(ClassUtils.getAllInterfacesForClass(targetClass, this.proxyClassLoader));
			}
		}
		copy.setFrozen(this.freezeProxy);

		if (logger.isTraceEnabled()) {
			logger.trace("Using ProxyCreatorSupport copy: " + copy);
		}
		return getProxy(copy.createAopProxy());
	}

	protected final synchronized AopProxy createAopProxy() {
		if (!this.active) {
			activate();
		}
		return getAopProxyFactory().createAopProxy(this);
	}
```

这里使用了`AopProxyFactory`来创建`AopProxy`，`AopProxyFactory`使用的是`DefaultAopProxyFactory`：
+ 在`DefaultAopProxyFactory`创建`AopProxy`的过程中，对不同的`AopProxy`代理对象的生成所涉及的生成策略和场景做了相应的设计;
+ 但是对于具体的`AopProxy`代理对象的生成，最终并没有由`DefaultAopProxyFactory`来完成;
+ 具体实际代理对象生成，是由`Spring`封装的`JdkDynamicAopProxy`和`CglibProxyFactory`类来完成的；

```DefaultAopProxyFactory
	@Override
	public AopProxy createAopProxy(AdvisedSupport config) throws AopConfigException {
		if (config.isOptimize() || config.isProxyTargetClass() || hasNoUserSuppliedProxyInterfaces(config)) {
			Class<?> targetClass = config.getTargetClass();
			if (targetClass == null) {
				throw new AopConfigException("TargetSource cannot determine target class: " +
						"Either an interface or a target is required for proxy creation.");
			}
			if (targetClass.isInterface() || Proxy.isProxyClass(targetClass)) {
				return new JdkDynamicAopProxy(config);
			}
			return new ObjenesisCglibAopProxy(config);
		}
		else {
			return new JdkDynamicAopProxy(config);
		}
	}
```

#### `JDK`生成`AopProxy`代理对象
在`JdkDynamicAopProxy`中，使用了`JDK`的`Proxy`类来生成代理对象:
+ 在生成`Proxy`对象之前，首先需要从`advised`对象中取得代理对象的代理接口配置;
+ 然后调用`Proxy`的`newProxyInstance`方法，最终得到对应的`Proxy`代理对象。

>在生成代理对象时，需要指明三个参数:
+ 一个是类装载器
+ 一个代理接口
+ 一个就是Proxy回调方法所在的对象
  + 这个对象需要实现`InvocationHandler`接口。
  + 这个`InvocationHandler`接口定义了`invoke`方法，提供代理对象的回调入口；

```JdkDynamicAopProxy
	@Override
	public Object getProxy(@Nullable ClassLoader classLoader) {
		if (logger.isTraceEnabled()) {
			logger.trace("Creating JDK dynamic proxy: " + this.advised.getTargetSource());
		}
		Class<?>[] proxiedInterfaces = AopProxyUtils.completeProxiedInterfaces(this.advised, true);
		findDefinedEqualsAndHashCodeMethods(proxiedInterfaces);
		return Proxy.newProxyInstance(classLoader, proxiedInterfaces, this);
	}
```

#### CGLIB生成AopProxy代理对象

```CglibAopProxy
	@Override
	public Object getProxy(@Nullable ClassLoader classLoader) {
		if (logger.isTraceEnabled()) {
			logger.trace("Creating CGLIB proxy: " + this.advised.getTargetSource());
		}

		try {
			Class<?> rootClass = this.advised.getTargetClass();
			Assert.state(rootClass != null, "Target class must be available for creating a CGLIB proxy");

			Class<?> proxySuperClass = rootClass;
			if (rootClass.getName().contains(ClassUtils.CGLIB_CLASS_SEPARATOR)) {
				proxySuperClass = rootClass.getSuperclass();
				Class<?>[] additionalInterfaces = rootClass.getInterfaces();
				for (Class<?> additionalInterface : additionalInterfaces) {
					this.advised.addInterface(additionalInterface);
				}
			}

			// Validate the class, writing log messages as necessary.
			validateClassIfNecessary(proxySuperClass, classLoader);

			// Configure CGLIB Enhancer...
			Enhancer enhancer = createEnhancer();
			if (classLoader != null) {
				enhancer.setClassLoader(classLoader);
				if (classLoader instanceof SmartClassLoader &&
						((SmartClassLoader) classLoader).isClassReloadable(proxySuperClass)) {
					enhancer.setUseCache(false);
				}
			}
			enhancer.setSuperclass(proxySuperClass);
			enhancer.setInterfaces(AopProxyUtils.completeProxiedInterfaces(this.advised));
			enhancer.setNamingPolicy(SpringNamingPolicy.INSTANCE);
			enhancer.setStrategy(new ClassLoaderAwareUndeclaredThrowableStrategy(classLoader));

			Callback[] callbacks = getCallbacks(rootClass);
			Class<?>[] types = new Class<?>[callbacks.length];
			for (int x = 0; x < types.length; x++) {
				types[x] = callbacks[x].getClass();
			}
			// fixedInterceptorMap only populated at this point, after getCallbacks call above
			enhancer.setCallbackFilter(new ProxyCallbackFilter(
					this.advised.getConfigurationOnlyCopy(), this.fixedInterceptorMap, this.fixedInterceptorOffset));
			enhancer.setCallbackTypes(types);

			// Generate the proxy class and create a proxy instance.
			return createProxyClassAndInstance(enhancer, callbacks);
		}
		catch (CodeGenerationException | IllegalArgumentException ex) {
			throw new AopConfigException("Could not generate CGLIB subclass of " + this.advised.getTargetClass() +
					": Common causes of this problem include using a final class or a non-visible class",
					ex);
		}
		catch (Throwable ex) {
			// TargetSource.getTarget() failed
			throw new AopConfigException("Unexpected AOP exception", ex);
		}
	}
```


通过使用`AopProxy`对象封装`target`目标对象之后，`ProxyFactoryBean`的`getObject`方法得到的对象就不是一个普通的`Java`对象了，而是一个`AopProxy`代理对象。
  + 在`ProxyFactoryBean`中配置的`target`目标对象，这时已经不会让应用直接调用其方法实现，而是作为`AOP`实现的一部分。
  + 对`target`目标对象的方法调用会首先被`AopProxy`代理对象拦截，对于不同的`AopProxy`代理对象生成方式，会使用不同的拦截回调入口：
    + 对于`JDK`的`AopProxy`代理对象，使用的是`InvocationHandler`的`invoke`回调入口
    + 对于`CGLIB的AopProxy`代理对象，使用的是设置好的`Callback`回调，这是由对`CGLIB`的使用来决定的，在这些`callback`回调中，对于`AOP`实现，是通过`DynamicAdvisedInterceptor`来完成的，而`DynamicAdvisedInterceptor`的回调入口是`intercept`方法；