当前`SpringBoot`程序启动时,依赖两个方面:
+ `@SpringBootApplication`
+ `SpringApplication.run()`

由上述两个入口,在启动之初构建`Spring`容器,并自动化加载相应`Bean`配置;

```
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

## `SpringApplication`

启动时,通过`SpringApplication.run()`创建一个`SpringApplication`对象实例;
+ `SpringApplication`实例通过`SpringFactoriesLoader.loadFactoryNames()`加载配置信息:
+ 根据`classpath`里面是否存在某个特征类（`org.springframework.web.context.ConfigurableWebApplicationContext`）来决定是否应该创建一个为`Web`应用使用的ApplicationContext类型。
+ 使用`SpringFactoriesLoader`在应用的`classpath`中查找并加载所有可用的`ApplicationContextInitializer`。
+ 使用`SpringFactoriesLoader`在应用的`classpath`中查找并加载所有可用的`ApplicationListener`。
+ 推断并设置`main`方法的定义类。

```SpringApplication
	public static ConfigurableApplicationContext run(Class<?>[] primarySources,
			String[] args) {
				// 创建实例
		return new SpringApplication(primarySources).run(args);
	}

	public SpringApplication(Class<?>... primarySources) {
		this(null, primarySources);
	}

	public SpringApplication(ResourceLoader resourceLoader, Class<?>... primarySources) {
		this.resourceLoader = resourceLoader;
		Assert.notNull(primarySources, "PrimarySources must not be null");
		this.primarySources = new LinkedHashSet<>(Arrays.asList(primarySources));
		// 设置程序类型 
		this.webApplicationType = WebApplicationType.deduceFromClasspath();
		// 加载上下文初始化类
		setInitializers((Collection) getSpringFactoriesInstances(
				ApplicationContextInitializer.class));
		// 加载上下文监听类
		setListeners((Collection) getSpringFactoriesInstances(ApplicationListener.class));
		// 推断主类
		this.mainApplicationClass = deduceMainApplicationClass();
	}

	// 从配置文件中加载类
	private <T> Collection<T> getSpringFactoriesInstances(Class<T> type) {
		return getSpringFactoriesInstances(type, new Class<?>[] {});
	}

	private <T> Collection<T> getSpringFactoriesInstances(Class<T> type,
			Class<?>[] parameterTypes, Object... args) {
		ClassLoader classLoader = getClassLoader();
		// Use names and ensure unique to protect against duplicates
		Set<String> names = new LinkedHashSet<>(
				SpringFactoriesLoader.loadFactoryNames(type, classLoader));
		List<T> instances = createSpringFactoriesInstances(type, parameterTypes,
				classLoader, args, names);
		AnnotationAwareOrderComparator.sort(instances);
		return instances;
	}
```

+ `SpringApplication`实例初始化完成并且完成设置后，就开始执行`run`方法的逻辑了，方法执行伊始，首先遍历执行所有通过`SpringFactoriesLoader`可以查找到并加载的`SpringApplicationRunListener`;
+ 调用它们的`started()`方法，通知`SpringApplicationRunListener`;


```SpringApplication.run
		StopWatch stopWatch = new StopWatch();
		stopWatch.start();
		ConfigurableApplicationContext context = null;
		Collection<SpringBootExceptionReporter> exceptionReporters = new ArrayList<>();
		configureHeadlessProperty();
		// 加载spring监听类
		SpringApplicationRunListeners listeners = getRunListeners(args);
		listeners.starting();
		try {
			ApplicationArguments applicationArguments = new DefaultApplicationArguments(
					args);
			ConfigurableEnvironment environment = prepareEnvironment(listeners,
					applicationArguments);
			configureIgnoreBeanInfo(environment);
			// 打印图标
			Banner printedBanner = printBanner(environment);
			// 创建上下文
			context = createApplicationContext();
			// 创建异常报告类
			exceptionReporters = getSpringFactoriesInstances(
					SpringBootExceptionReporter.class,
					new Class[] { ConfigurableApplicationContext.class }, context);
			// 上下文环境准备
			prepareContext(context, environment, listeners, applicationArguments,
					printedBanner);
			// 上下文加载
			refreshContext(context);
			afterRefresh(context, applicationArguments);
			stopWatch.stop();
			if (this.logStartupInfo) {
				new StartupInfoLogger(this.mainApplicationClass)
						.logStarted(getApplicationLog(), stopWatch);
			}
			listeners.started(context);
			callRunners(context, applicationArguments);
		}
		catch (Throwable ex) {
			handleRunFailure(context, ex, exceptionReporters, listeners);
			throw new IllegalStateException(ex);
		}

		try {
			listeners.running(context);
		}
		catch (Throwable ex) {
			handleRunFailure(context, ex, exceptionReporters, null);
			throw new IllegalStateException(ex);
		}
		return context;
	}
```

![springboot](/images/springboot.png)