# 类加载过程

在冯·诺伊曼定义的计算机模型中,任何程序都需要加载到内存才能与CPU进行交流;

字节码`.class`文件同样需要加载到内存中,才可以实例化类.

而`JDK`中提供了`ClassLoader`,它的使命就是提前加载`.class`类文件到内存中.在加载类时,使用的是`Parent Delegation Model`,溯源委派加载模型;


>每个Java程序执行前都必须经过**编译**, **加载、连接、和初始化**;

>1. `加载`：读取类文件产生二进制流,并转化为特定的数据结构,初步校验`cafe babe`魔法数,常量池,文件长度,是否有父类等,然后创建对应类的`java.lang.Class`实例;
 + 即加载后最终得到的是`Class`对象，并且更加值得注意的是：该`Java.lang.Class`对象是单实例的，无论这个类创建了多少个对象，他的`Class`对象时唯一的。而加载并获取该`Class`对象可以通过三种途径：
      1. `Class.forName`（类的全路径）；
      2. `实例对象.class`(属性)；
      3. `实例对象.getClass()`；
2. `连接`,包括验证,准备,解析三个步骤:
  + 验证,更详细的校验,如`fianl`是否合规,类型是否正确,静态变量是否合理等;
  + 准备,为静态变量分配内存,并设定默认值;
  + 解析,确保类与类之间的相互引用正确性;
3. `初始化`，执行类构造器 `<clinit>`方法;

**类加载是一个将`.class`字节码实例化成Class对象并进行相关初始化的过程;**

## Java类使用方式

Java对类的使用分为两种方式：主动使用和被动使用。其中主动使用如下图：

>主动使用:
+ 创建类的实例
+ 访问某个类或接口的静态变量,或者对该静态变量赋值;
+ 调用类的静态方法
+ 反射(`Class.forName("XXXXX")`)
+ 初始化一个类的子类
+ Java虚拟机启动时被标明为启动类的类

>区别：
  1. `Class cl=A.class;`JVM将使用类A的类装载器,将类A装入内存(前提是:类A还没有装入内存),不对类A做类的初始化工作.返回类A的Class的对象
  2. `Class cl=对象引用o.getClass();`返回引用o运行时真正所指的对象(因为:儿子对象的引用可能会赋给父对象的引用变量中)所属的类的Class的对象 
  3. `Class.forName("类名");`装入类A,并做类的初始化


>从JVM的角度看，我们使用关键字`new`创建一个类的时候，这个类可以没有被加载。
* 但是使用`Class`对象的`newInstance()`方法的时候，就必须保证：
1. 这个类已经加载；
2. 这个类已经连接了。而完成上面两个步骤的正是Class的静态方法`forName()`所完成的,这个静态方法调用了启动类加载器,即加载java API的那个加载器。 
  * `newInstance`: 弱类型。低效率。只能调用无参构造。 
  * `new`: 强类型。相对高效。能调用任何public构造。

## Java类加载器

>Java中有三个**默认类加载器**：
1. **`启动类加载器（Bootstrap）`**：**引导类装入器是用本地代码实现的类装入器**，它负责将`Java_Home/lib`下面的核心类库或`-Xbootclasspath`选项指定的jar包加载到内存中。
  + 由于引导类加载器涉及到虚拟机本地实现细节，开发者无法直接获取到启动类加载器的引用，所以不允许直接通过引用进行操作；
2. **`扩展类加载器（Extesion）`**：扩展类加载器是由Sun的`ExtClassLoader（sun.misc.Launcher$ExtClassLoader）`实现的。它负责将`Java_Home/lib/ext`或者由系统变量`-Djava.ext.dir`指定位置中的类库加载到内存中。
  + 开发者可以直接使用标准扩展类加载器
3. **`系统类加载器（System）`**：系统类加载器是由Sun的`AppClassLoader（sun.misc.Launcher$AppClassLoader）`实现的。它负责将系统类路径`java-classpath`或`-Djava.class.path`变量所指的目录下的类库加载内存中。
  + 开发者可以直接使用系统类加载器


>**`线程上下文类加载器（context class loader）`**是从 JDK 1.2 开始引入的。类 `java.lang.Thread`中的方法 `getContextClassLoader()`和 `setContextClassLoader(ClassLoader cl)`用来获取和设置线程的上下文类加载器。
  * 如果没有通过 `setContextClassLoader(ClassLoader cl)`方法进行设置的话，线程将继承其父线程的上下文类加载器。
  * Java 应用运行的初始线程的上下文类加载器是系统类加载器。在线程中运行的代码可以通过此类加载器来加载类和资源

### 双亲委派加载模型
>Java正常性加载类采用双亲委派模型进行工作：

>双亲委派模型的工作过程是：
**（双亲委派模型的实现是通过组合继承调用父类加载器）**
* 如果一个类加载器收到了类加载的请求，它首先不会自己去尝试加载这个类，而是把这个请求委派给`父类加载器`去完成(`扩展类加载器`将其父类加载器设置为`Null`，促使程序去寻找`启动类加载器`)，每一个层次的类加载器都是如此；
* 因此所有的加载请求最终都应该传送到顶层的`启动类加载器`中，只有当`父加载器`反馈自己无法完成这个加载请求（它的搜索范围中没有找到所需的类）时，子加载器才会尝试自己去加载；

## `java.lang.ClassLoader`

从JDK源码查看可知，类加载器均是继承自`java.lang.ClassLoader`抽象类。让我们来看看其中几个重要方法：

```
/**
 *加载指定名称（包括包名）的二进制类型，供用户调用的接口
 */
public Class<?> loadClass(String name) throws ClassNotFoundException {
        return loadClass(name, false);
}
```
>+ 加载指定名称（包括包名）的二进制类型;
+ 同时指定是否解析（但是这里的resolve参数不一定真正能达到解析的效果），供继承使用

```ClassLoader
protected Class<?> loadClass(String name, boolean resolve)
        throws ClassNotFoundException {
        // 同步加锁
        synchronized (getClassLoadingLock(name)) {
            // 首先检查是否已加载过类
            Class<?> c = findLoadedClass(name);
            if (c == null) {
                long t0 = System.nanoTime();
                try {
                    if (parent != null) {
                        //调用父类加载器
                        c = parent.loadClass(name, false);
                    } else {
                        //调用启动类加载器
                        c = findBootstrapClassOrNull(name);
                    }
                } catch (ClassNotFoundException e) {
                    // ClassNotFoundException thrown if class not found
                    // from the non-null parent class loader
                }

                if (c == null) {
                    // If still not found, then invoke findClass in order
                    // to find the class.
                    long t1 = System.nanoTime();
                    c = findClass(name);

                    // this is the defining class loader; record the stats
                    sun.misc.PerfCounter.getParentDelegationTime().addTime(t1 - t0);
                    sun.misc.PerfCounter.getFindClassTime().addElapsedTimeFrom(t1);
                    sun.misc.PerfCounter.getFindClasses().increment();
                }
            }
            if (resolve) {
                resolveClass(c);
            }
            return c;
        }
    }

    // 获取类加载所对象
    protected Object getClassLoadingLock(String className) {
        // 获取本身对象作为锁对象
        Object lock = this;
        // 并行锁对象Map不为空
        if (parallelLockMap != null) {
            // 创建一个新的锁对象
            Object newLock = new Object();
            // put入Map集合内,已存在Key不存入
            lock = parallelLockMap.putIfAbsent(className, newLock);
            // 替换锁对象
            if (lock == null) {
                lock = newLock;
            }
        }
        return lock;
    }
    // 查找已加载过的类对象
    protected final Class<?> findLoadedClass(String name) {
        if (!checkName(name))
            return null;
        return findLoadedClass0(name);
    }
    // 检查类名规范
    private boolean checkName(String name) {
        if ((name == null) || (name.length() == 0))
            return true;
        // 类名存在/或虚拟机配置允许数组语法且类名为数组起头
        if ((name.indexOf('/') != -1)
            || (!VM.allowArraySyntax() && (name.charAt(0) == '[')))
            return false;
        return true;
    }

    // 
    private native final Class<?> findLoadedClass0(String name);

    // 
    private Class<?> findBootstrapClassOrNull(String name)
    {
        if (!checkName(name)) return null;

        return findBootstrapClass(name);
    }

    // return null if not found
    private native Class<?> findBootstrapClass(String name);

```

```
    JNIEXPORT jclass JNICALL
    Java_java_lang_ClassLoader_findLoadedClass0(JNIEnv *env, jobject loader,
                                               jstring name)
    {
        if (name == NULL) {
            return 0;
        } else {
            return JVM_FindLoadedClass(env, loader, name);
        }
    }
```

```
    #define JVM_ENTRY(result_type, header)                               \
    extern "C" {                                                         \
      result_type JNICALL header {                                       \
        JavaThread* thread=JavaThread::thread_from_jni_environment(env); \
        ThreadInVMfromNative __tiv(thread);                              \
        debug_only(VMNativeEntryWrapper __vew;)                          \
        VM_ENTRY_BASE(result_type, header, thread)


    #define JVM_END } }
```

```看不懂-_-
    // 在VM中查找已加载类的缓存
    JVM_ENTRY(jclass, JVM_FindLoadedClass(JNIEnv *env, jobject loader, jstring name))
      JVMWrapper("JVM_FindLoadedClass");
      ResourceMark rm(THREAD);

      Handle h_name (THREAD, JNIHandles::resolve_non_null(name));
      Handle string = java_lang_String::internalize_classname(h_name, CHECK_NULL);

      const char* str   = java_lang_String::as_utf8_string(string());
      // Sanity check, don't expect null
      if (str == NULL) return NULL;

      const int str_len = (int)strlen(str);
      if (str_len > Symbol::max_length()) {
        // It's impossible to create this class;  the name cannot fit
        // into the constant pool.
        return NULL;
      }
      TempNewSymbol klass_name = SymbolTable::new_symbol(str, str_len, CHECK_NULL);

      // Security Note:
      //   The Java level wrapper will perform the necessary security check allowing
      //   us to pass the NULL as the initiating class loader.
      Handle h_loader(THREAD, JNIHandles::resolve(loader));
      if (UsePerfData) {
        is_lock_held_by_thread(h_loader,
                               ClassLoader::sync_JVMFindLoadedClassLockFreeCounter(),
                               THREAD);
      }

      Klass* k = SystemDictionary::find_instance_or_array_klass(klass_name,
                                                                  h_loader,
                                                                  Handle(),
                                                                  CHECK_NULL);

      return (k == NULL) ? NULL :
                (jclass) JNIHandles::make_local(env, k->java_mirror());
    JVM_END
```

>一般被loadClass方法调用去加载指定名称类，供继承使用

```
protected Class<?> findClass(String name) throws ClassNotFoundException {
        throw new ClassNotFoundException(name);
}
```

>URLClassLoader.findClass(继承了ClassLoader.java)

```
protected Class<?> findClass(final String name)
        throws ClassNotFoundException
    {
        final Class<?> result;
        try {
            result = AccessController.doPrivileged(
                new PrivilegedExceptionAction<Class<?>>() {
                    public Class<?> run() throws ClassNotFoundException {
                        String path = name.replace('.', '/').concat(".class");
                        Resource res = ucp.getResource(path, false);
                        if (res != null) {
                            try {
                                return defineClass(name, res);
                            } catch (IOException e) {
                                throw new ClassNotFoundException(name, e);
                            }
                        } else {
                            return null;
                        }
                    }
                }, acc);
        } catch (java.security.PrivilegedActionException pae) {
            throw (ClassNotFoundException) pae.getException();
        }
        if (result == null) {
            throw new ClassNotFoundException(name);
        }
        return result;
}

private Class<?> defineClass(String name, Resource res) throws IOException {
    long t0 = System.nanoTime();
    int i = name.lastIndexOf('.');
    URL url = res.getCodeSourceURL();
    if (i != -1) {
        String pkgname = name.substring(0, i);
        // Check if package already loaded.
        Manifest man = res.getManifest();
        definePackageInternal(pkgname, man, url);
    }
    // Now read the class bytes and define the class
    java.nio.ByteBuffer bb = res.getByteBuffer();
    if (bb != null) {
        // Use (direct) ByteBuffer:
        CodeSigner[] signers = res.getCodeSigners();
        CodeSource cs = new CodeSource(url, signers);
        sun.misc.PerfCounter.getReadClassBytesTime().addElapsedTimeFrom(t0);
        return defineClass(name, bb, cs);
    } else {
        byte[] b = res.getBytes();
        // must read certificates AFTER reading bytes.
        CodeSigner[] signers = res.getCodeSigners();
        CodeSource cs = new CodeSource(url, signers);
        sun.misc.PerfCounter.getReadClassBytesTime().addElapsedTimeFrom(t0);
        return defineClass(name, b, 0, b.length, cs);
    }
}
```

>定义类型，一般在`findClass`方法中读取到对应字节码后调用，可以看出不可继承(JVM已经实现了对应具体功能，解析对应的字节码，产生对应的内部数据结构放置方法区，所以无需覆写，直接调用即可）

```
protected final Class<?> defineClass(String name, java.nio.ByteBuffer b,
                                     ProtectionDomain protectionDomain)
    throws ClassFormatError
{
    int len = b.remaining();

    // Use byte[] if not a direct ByteBufer:
    if (!b.isDirect()) {
        if (b.hasArray()) {
            return defineClass(name, b.array(),
                               b.position() + b.arrayOffset(), len,
                               protectionDomain);
        } else {
            // no array, or read-only array
            byte[] tb = new byte[len];
            b.get(tb);  // get bytes out of byte buffer.
            return defineClass(name, tb, 0, len, protectionDomain);
        }
    }

    protectionDomain = preDefineClass(name, protectionDomain);
    String source = defineClassSourceLocation(protectionDomain);
    Class<?> c = defineClass2(name, b, b.position(), len, protectionDomain, source);
    postDefineClass(c, protectionDomain);
    return c;
}
```

## `Class.forName()`加载类

```
public static Class<?> forName(String className) throws ClassNotFoundException {
  return forName0(className, true, ClassLoader.getCallerClassLoader());
}

public static Class<?> forName(String name, boolean initialize,ClassLoader loader) throws ClassNotFoundException {
    if (loader == null) {
        SecurityManager sm = System.getSecurityManager();
        if (sm != null) {
        ClassLoader ccl = ClassLoader.getCallerClassLoader();
        if (ccl != null) {
            sm.checkPermission(SecurityConstants.GET_CLASSLOADER_PERMISSION);
        }
        }
    }
    return forName0(name, initialize, loader);
}

private static native Class forName0(String name, boolean initialize,ClassLoader loader) throws ClassNotFoundException;
```

>* 其中`initialize`参数是很重要的，它表示在加载同时是否完成初始化的工作（说明：单参数版本的forName方法默认是完成初始化的）
* 有些场景下需要将`initialze`设置为`true`来强制加载同时完成初始化。例如典型的就是利用`DriverManager`进行`JDBC`驱动程序类注册的问题。因为每一个JDBC驱动程序类的静态初始化方法都用`DriverManager`注册驱动程序，这样才能被应用程序使用。

## 双亲委派模型破坏

1. 双亲委派模型的第一次“被破坏”其实发生在双亲委派模型出现之前--即`JDK1.2`发布之前。
  1. 由于双亲委派模型是在JDK1.2之后才被引入的，而类加载器和抽象类`java.lang.ClassLoader`则是JDK1.0时候就已经存在，面对已经存在的用户自定义类加载器的实现代码，Java设计者引入双亲委派模型时不得不做出一些妥协。
  2. 为了向前兼容，JDK1.2之后的`java.lang.ClassLoader`添加了一个新的proceted方法`findClass()`，在此之前，用户去继承`java.lang.ClassLoader`的唯一目的就是重写`loadClass()`方法，因为虚拟机在进行类加载的时候会调用加载器的私有方法`loadClassInternal()`，而这个方法的唯一逻辑就是去调用自己的`loadClass()`。
  3. JDK1.2之后已不再提倡用户再去覆盖`loadClass()`方法，应当把自己的类加载逻辑写到`findClass()`方法中，在`loadClass()`方法的逻辑里，如果父类加载器加载失败，则会调用自己的`findClass()`方法来完成加载，这样就可以保证新写出来的类加载器是符合双亲委派模型的。

2. 双亲委派模型的第二次"被破坏"是这个模型自身的缺陷所导致的,**双亲委派模型很好地解决了`各个类加载器的基础类统一问题(越基础的类由越上层的加载器进行加载)`**;
  1. 基础类之所以被称为"基础"，是因为它们总是作为被调用代码调用的API。但是，如果基础类又要调用用户的代码，那该怎么办呢。
  2. 这并非是不可能的事情，一个典型的例子便是`JNDI服务`它的代码`由启动类加载器`去加载(`在JDK1.3时放进rt.jar`);
  3. 但JNDI的目的就是**对资源进行集中管理和查找**，它需要调用独立厂商实现部部署在应用程序的classpath下的JNDI接口提供者(SPI, Service Provider Interface)的代码，但启动类加载器不可能"认识"之些代码，该怎么办？
  4. 为了解决这个困境，Java设计团队只好引入了一个不太优雅的设计：线程上下文件类加载器(Thread Context ClassLoader);
    1. 这个类加载器可以通过`java.lang.Thread`类的`setContextClassLoader()`方法进行设置，如果创建线程时还未设置，它将会从父线程中继承一个；
    2. 如果在应用程序的全局范围内都没有设置过，那么这个类加载器默认就是应用程序类加载器。
    3. 有线程上下文类加载器，JNDI服务使用这个线程上下文类加载器去加载所需要的SPI代码，也就是父类加载器请求子类加载器去完成类加载动作，这种行为实际上就是打通了双亲委派模型的层次结构来逆向使用类加载器，已经违背了双亲委派模型，但这也是无可奈何的事情。
    4. `Java中所有涉及SPI的加载动作基本上都采用这种方式，例如JNDI,JDBC,JCE,JAXB和JBI等`。

3. 双亲委派模型的第三次"被破坏"是由于用户对程序的动态性的追求导致的，例如OSGi的出现。在OSGi环境下，类加载器不再是双亲委派模型中的树状结构，而是进一步发展为网状结构。

>**（从上述打破的结论而言，想要打破双亲委派模型，其实就是`继承ClassLoader`，`覆盖掉原始的findClass（）、loadClass（）`去自定义自己想要加载方式，这样JDK本身的加载模型就不可用了）**