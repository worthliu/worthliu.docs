## `Dubbo`中的`SPI`

`Dubbo`框架中大量使用了`SPI`技术，里面有很多个组件，每个组件在框架中都是以接口的形成抽象出来！具体的实现又分很多种，在程序执行时根据用户的配置来按需取接口的实现。方便了接口的各种实现灵活应用。

不过`Dubbo`使用的`SPI`技术不是源用`jdk`的实现，但是它们的思想仍然是一样的。

```
	public static DubboProtocol getDubboProtocol() {
        if (INSTANCE == null) {
            // load
            ExtensionLoader.getExtensionLoader(Protocol.class).getExtension(DubboProtocol.NAME);
        }

        return INSTANCE;
    }
```

从上述代码看到,`Dubbo`中的`SPI`实现是依赖于`ExtensionLoader`;

## `ExtensionLoader`

```ExtensionLoader.getExtensionLoader
	public static <T> ExtensionLoader<T> getExtensionLoader(Class<T> type) {
        if (type == null) {
            throw new IllegalArgumentException("Extension type == null");
        }

        // 加载对象类型必须是接口
        if (!type.isInterface()) {
            throw new IllegalArgumentException("Extension type (" + type + ") is not an interface!");
        }

        // 接口必须带有SPI注解
        if (!withExtensionAnnotation(type)) {
            throw new IllegalArgumentException("Extension type (" + type +
                    ") is not an extension, because it is NOT annotated with @" + SPI.class.getSimpleName() + "!");
        }
        // 获取接口类对象加载器
        ExtensionLoader<T> loader = (ExtensionLoader<T>) EXTENSION_LOADERS.get(type);
        // 若无新增对象加载器
        if (loader == null) {
            EXTENSION_LOADERS.putIfAbsent(type, new ExtensionLoader<T>(type));
            loader = (ExtensionLoader<T>) EXTENSION_LOADERS.get(type);
        }
        return loader;
    }

    private ExtensionLoader(Class<?> type) {
        this.type = type;
        objectFactory = (type == ExtensionFactory.class ? null : ExtensionLoader.getExtensionLoader(ExtensionFactory.class).getAdaptiveExtension());
    }
```

>1. `EXTENSION_LOADERS`这个`Map`中以接口为`key`,以`ExtensionLoader`对象为`value`。
2. 判断`Map`中根据接口`ge`t对象，如果没有就`new个ExtensionLoader`对象保存进去。并返回该`ExtensionLoader`对象。
3. 注意创建`ExtensionLoader`对象的构造函数代码，将传入的接口`type`属性赋值给了`ExtensionLoader`类的`type`属性
4. 创建`ExtensionFactory objectFactory`对象。

```Holder
	public class Holder<T> {

	    private volatile T value;

	    public void set(T value) {
	        this.value = value;
	    }

	    public T get() {
	        return value;
	    }

	}
```

```ExtensionLoader.getAdaptiveExtension
	public T getAdaptiveExtension() {
		// 适配器实例缓存对象
        Object instance = cachedAdaptiveInstance.get();
        if (instance == null) {
        	// 创建适配器实例异常对象
            if (createAdaptiveInstanceError == null) {
            	// 双重校验锁,对应实例必须使用volatile修改
                synchronized (cachedAdaptiveInstance) {
                    instance = cachedAdaptiveInstance.get();
                    if (instance == null) {
                        try {
                        	// 对象生成入口
                            instance = createAdaptiveExtension();
                            // 设置生成对象到cache中
                            cachedAdaptiveInstance.set(instance);
                        } catch (Throwable t) {
                            createAdaptiveInstanceError = t;
                            throw new IllegalStateException("Failed to create adaptive instance: " + t.toString(), t);
                        }
                    }
                }
            } else {
                throw new IllegalStateException("Failed to create adaptive instance: " + createAdaptiveInstanceError.toString(), createAdaptiveInstanceError);
            }
        }

        return (T) instance;
    }
```

```
	private T createAdaptiveExtension() {
        try {
            return injectExtension((T) getAdaptiveExtensionClass().newInstance());
        } catch (Exception e) {
            throw new IllegalStateException("Can't create adaptive extension " + type + ", cause: " + e.getMessage(), e);
        }
    }

    private Class<?> getAdaptiveExtensionClass() {
        getExtensionClasses();
        if (cachedAdaptiveClass != null) {
            return cachedAdaptiveClass;
        }
        return cachedAdaptiveClass = createAdaptiveExtensionClass();
    }

    private Class<?> createAdaptiveExtensionClass() {
        String code = new AdaptiveClassCodeGenerator(type, cachedDefaultName).generate();
        ClassLoader classLoader = findClassLoader();
        org.apache.dubbo.common.compiler.Compiler compiler = ExtensionLoader.getExtensionLoader(org.apache.dubbo.common.compiler.Compiler.class).getAdaptiveExtension();
        return compiler.compile(code, classLoader);
    }

    private Map<String, Class<?>> getExtensionClasses() {
        Map<String, Class<?>> classes = cachedClasses.get();
        if (classes == null) {
            synchronized (cachedClasses) {
                classes = cachedClasses.get();
                if (classes == null) {
                    classes = loadExtensionClasses();
                    cachedClasses.set(classes);
                }
            }
        }
        return classes;
    }
```