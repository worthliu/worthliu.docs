`spi(service provider interface)`,接口服务提供者;**为接口自动寻找实现类;**

>+ 标准制定者制定接口
+ 不同厂商编写针对于该接口的实现类，并在jar的`classpath:META-INF/services/全接口名称`文件中指定相应的实现类全类名
+ 开发者直接引入相应的`jar`，就可以实现为接口自动寻找实现类的功能

```测试入口
	public static void main(String[] args){
        ServiceLoader<SpiInterface> serviceLoader = ServiceLoader.load(SpiInterface.class);
        Iterator<SpiInterface> iterator = serviceLoader.iterator();
        while (iterator.hasNext()){
            SpiInterface spiInterface = iterator.next();
            spiInterface.execute();
        }
    }
```

```接口定义
public interface SpiInterface {

    void execute();
}

```

```接口实现类
public class OtherSpiImpl implements SpiInterface {
    @Override
    public void execute() {
        System.out.println("Now, the executor is OtherSpiImpl...");
    }
}

public class MySpiImpl implements SpiInterface {
    @Override
    public void execute() {
        System.out.println("Now, the executor is MySpiImpl....");
    }
}

public class YouSpiImpl implements SpiInterface {

    @Override
    public void execute() {
        System.out.println("Now, the executor is YouSpiImpl....");
    }
}
```

```com.worthliu.spi.SpiInterface
com.worthliu.spi.OtherSpiImpl
com.worthliu.spi.MySpiImpl
com.worthliu.spi.YouSpiImpl
```


**`JDK`中`ServiceLoader`不是实例化以后，就去读取配置文件中的具体实现，并进行实例化。**

**而是等到使用迭代器去遍历的时候，才会加载对应的配置文件去解析，调用`hasNext()`方法的时候会去加载配置文件进行解析，调用`next()`方法的时候进行实例化并缓存;**

## `ServiceLoader`

**`ServiceLoader`内部定义了6个属性:**

```
// 定义实现类接口文件所在目录
private static final String PREFIX = "META-INF/services/";

// 加载对应类的接口定义
private final Class<S> service;

// 定位,加载,实例化的实现类
private final ClassLoader loader;

// 权限控制上下文
private final AccessControlContext acc;

// 加载缓存,按照初始化顺序保存
private LinkedHashMap<String,S> providers = new LinkedHashMap<>();

// 当前迭代器
private LazyIterator lookupIterator;
```

```
	// 重载内部迭代器,清空缓存
	public void reload() {
        providers.clear();
        lookupIterator = new LazyIterator(service, loader);
    }

    private ServiceLoader(Class<S> svc, ClassLoader cl) {
        service = Objects.requireNonNull(svc, "Service interface cannot be null");
        loader = (cl == null) ? ClassLoader.getSystemClassLoader() : cl;
        acc = (System.getSecurityManager() != null) ? AccessController.getContext() : null;
        reload();
    }

    public static <S> ServiceLoader<S> load(Class<S> service,
                                            ClassLoader loader)
    {
        return new ServiceLoader<>(service, loader);
    }

    public static <S> ServiceLoader<S> load(Class<S> service) {
        ClassLoader cl = Thread.currentThread().getContextClassLoader();
        return ServiceLoader.load(service, cl);
    }

```

```外层迭代器
	public Iterator<S> iterator() {
        return new Iterator<S>() {

            Iterator<Map.Entry<String,S>> knownProviders
                = providers.entrySet().iterator();

            public boolean hasNext() {
                if (knownProviders.hasNext())
                    return true;
                return lookupIterator.hasNext();
            }

            public S next() {
                if (knownProviders.hasNext())
                    return knownProviders.next().getValue();
                return lookupIterator.next();
            }

            public void remove() {
                throw new UnsupportedOperationException();
            }

        };
    }

```

>从查找过程`hasNext()`和迭代过程`next()`来看。
+ `hasNext()`：
  + 先从`provider（缓存）`中查找，如果有，直接返回`true`；
  + 如果没有，通过`LazyIterator`来进行查找。
+ `next()`：
  + 先从`provider（缓存）`中直接获取，如果有，直接返回实现类对象实例；
  + 如果没有，通过`LazyIterator`来进行获取。

### `LazyIterator`

```
	private class LazyIterator
        implements Iterator<S>
    {
    	// 定义类接口
        Class<S> service;
        // 类加载器
        ClassLoader loader;
        // 配置文件信息
        Enumeration<URL> configs = null;
        // 配置文件中内容
        Iterator<String> pending = null;
        // 当前实现类的全限定名
        String nextName = null;
        ....
    }
```

```LazyIterator.hasNext
	// 检验是否存在实现类
	public boolean hasNext() {
		// 访问控制器不存在
        if (acc == null) {
            return hasNextService();
        } else {
            PrivilegedAction<Boolean> action = new PrivilegedAction<Boolean>() {
                public Boolean run() { return hasNextService(); }
            };
            return AccessController.doPrivileged(action, acc);
        }
    }

    // 检验是否存在实现类
    private boolean hasNextService() {
        if (nextName != null) {
            return true;
        }
        // 配置信息不存在时
        if (configs == null) {
            try {
            	// 组装需要加载类配置文件地址
                String fullName = PREFIX + service.getName();
                // 通过加载器加载对应配置文件信息
                if (loader == null)
                    configs = ClassLoader.getSystemResources(fullName);
                else
                    configs = loader.getResources(fullName);
            } catch (IOException x) {
                fail(service, "Error locating configuration files", x);
            }
        }

        // 解析配置文件信息内容
        while ((pending == null) || !pending.hasNext()) {
            if (!configs.hasMoreElements()) {
                return false;
            }
            pending = parse(service, configs.nextElement());
        }
        nextName = pending.next();
        return true;
    }
```
`hasNextService()`中，核心实现如下：

+ 使用`loader`加载配置文件，此时找到了`META-INF/services/XXXX`文件；
+ 解析配置文件，并将各个实现类名称存储在`pending`的`ArrayList`中; 
+ 最后指定`nextName`; 


```LazyIterator.next
	public S next() {
        if (acc == null) {
            return nextService();
        } else {
            PrivilegedAction<S> action = new PrivilegedAction<S>() {
                public S run() { return nextService(); }
            };
            return AccessController.doPrivileged(action, acc);
        }
    }

    private S nextService() {
        if (!hasNextService())
            throw new NoSuchElementException();
        // 获取实现类全限定名
        String cn = nextName;
        nextName = null;
        Class<?> c = null;
        try {
        	// 以反射形式实例化类
            c = Class.forName(cn, false, loader);
        } catch (ClassNotFoundException x) {
            fail(service,
                 "Provider " + cn + " not found");
        }
        // 判断是否spi接口的实现类
        if (!service.isAssignableFrom(c)) {
            fail(service,
                 "Provider " + cn  + " not a subtype");
        }
        // 将实例化类转换成spi接口类类型,并缓存
        try {
            S p = service.cast(c.newInstance());
            providers.put(cn, p);
            return p;
        } catch (Throwable x) {
            fail(service,
                 "Provider " + cn + " could not be instantiated",
                 x);
        }
        throw new Error();          // This cannot happen
    }
```
`nextService()`中，核心实现如下：
+ 加载`nextName`代表的类`Class`；
+ 之后创建该类的实例，并转型为所需的接口类型
+ 最后存储在provider中，供后续查找，最后返回转型后的实现类实例。
再`next()`之后，拿到实现类实例后，就可以执行其具体的方法了。

```ServiceLoader.parse
	private Iterator<String> parse(Class<?> service, URL u)
        throws ServiceConfigurationError
    {
        InputStream in = null;
        BufferedReader r = null;
        ArrayList<String> names = new ArrayList<>();
        try {
            in = u.openStream();
            r = new BufferedReader(new InputStreamReader(in, "utf-8"));
            int lc = 1;
            while ((lc = parseLine(service, u, r, lc, names)) >= 0);
        } catch (IOException x) {
            fail(service, "Error reading configuration file", x);
        } finally {
            try {
                if (r != null) r.close();
                if (in != null) in.close();
            } catch (IOException y) {
                fail(service, "Error closing configuration file", y);
            }
        }
        return names.iterator();
    }

    private int parseLine(Class<?> service, URL u, BufferedReader r, int lc,
                          List<String> names)
        throws IOException, ServiceConfigurationError
    {
        String ln = r.readLine();
        if (ln == null) {
            return -1;
        }
        int ci = ln.indexOf('#');
        if (ci >= 0) ln = ln.substring(0, ci);
        ln = ln.trim();
        int n = ln.length();
        if (n != 0) {
            if ((ln.indexOf(' ') >= 0) || (ln.indexOf('\t') >= 0))
                fail(service, u, lc, "Illegal configuration-file syntax");
            int cp = ln.codePointAt(0);
            if (!Character.isJavaIdentifierStart(cp))
                fail(service, u, lc, "Illegal provider-class name: " + ln);
            for (int i = Character.charCount(cp); i < n; i += Character.charCount(cp)) {
                cp = ln.codePointAt(i);
                if (!Character.isJavaIdentifierPart(cp) && (cp != '.'))
                    fail(service, u, lc, "Illegal provider-class name: " + ln);
            }
            if (!providers.containsKey(ln) && !names.contains(ln))
                names.add(ln);
        }
        return lc + 1;
    }
```


## 缺点

1. 对于一个`spi`接口的实现,由于内部存放的数据缓存为`LinkedHashMap`,无法通过`key`快速查找,每次查找都需要遍历;
2. 由于一个`spi`接口对应一份配置文件,每加载一种`spi`接口都需要初始化一个`ServiceLoader`对象,需要外部使用时进行管理相关对象加载器;
