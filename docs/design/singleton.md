## 单例模式
Ensure a class has only one instance, and provide a global point of access to it;

确保某一个只有一个实例，而且自行实例化并向整个系统提供这个实例;

![image](/images/singleton.png)

### 优缺点

>单例模式的优点
+ 由于单例模式在内存中只有一个实例，减少了内存开支，特别是一个对象需要频繁地创建、销毁时，而且创建或销毁时性能又无法优化，单例模式的优势就非常明显。
+ 由于单例模式只生成一个实例，所以减少了系统的性能开销，当一个对象的产生需要比较多的资源时，如读取配置、产生其他依赖对象时，则可以通过在应用启动时直接产生一
个单例对象，然后用永久驻留内存的方式来解决（在Java EE中采用单例模式时需要注意`JVM`垃圾回收机制）。
+ 单例模式可以避免对资源的多重占用，例如一个写文件动作，由于只有一个实例存在内存中，避免对同一个资源文件的同时写操作。
+ 单例模式可以在系统设置全局的访问点，优化和共享资源访问，例如可以设计一个单例类，负责所有数据表的映射处理。

>单例模式的缺点
+ 单例模式一般没有接口，扩展很困难，若要扩展，除了修改代码基本上没有第二种途径可以实现。
  + 单例模式为什么不能增加接口呢？
    + 因为接口对单例模式是没有任何意义的，它要求“自行实例化”，并且提供单一实例、接口或抽象类是不可能被实例化的。当然，在特殊情况下，单例模式可以实现接口、被继承等，需要在系统开发中根据环境判断。
+ 单例模式对测试是不利的。在并行开发环境中，如果单例模式没有完成，是不能进行测试的，没有接口也不能使用mock的方式虚拟一个对象。
+ 单例模式与单一职责原则有冲突。一个类应该只实现一个逻辑，而不关心它是否是单例的，是不是要单例取决于环境，单例模式把“要单例”和业务逻辑融合在一个类中。

## 代码实现

1. 线程非安全版本

```
public class SingletonNoSafe {
    private static SingletonNoSafe instance = null;

    private SingletonNoSafe(){
    }

    public static SingletonNoSafe getInstance(){
        if(instance == null){
            instance = new SingletonNoSafe();
        }
        return instance;
    }
}
```
2.线程安全但浪费内存资源(无论是否用到都先行创建对象)

```
public class SingletonFirst {
    private static final SingletonFirst instance = new SingletonFirst();
    
    private SingletonFirst(){
        
    }
    
    public static SingletonFirst getInstance(){
        return instance;
    }
}
```

3. 线程安全双重判断

```
public class SingletonSafeSecond {
    private SingletonSafeSecond instance = null;

    private SingletonSafeSecond() {
    }

    /**
     * 
     * @return
     */
    public SingletonSafeSecond getInstance() {
        if (instance == null) {
            synchronized (this) {
                if (instance == null) {
                    instance = new SingletonSafeSecond();
                }
            }
        }
        //
        return instance;
    }
}
```

对于上述代码中,使用者在调用`getInstance()`时,有可能会得到初始化未完成的对象.究其原因,与`Java`虚拟机的编译优化有关.对`Java`编译器而言,初始化`SingletonSafeSecond`实例和将对象地址写到`instance`字段并非原子操作,且这两个阶段的执行顺序是未定义的.

假设某个线程执行`new SingletonSafeSecond();`时,构造方法还未被调用,编译器仅仅为该对象分配了内存空间并设置默认值,此时若另一个线程调用`getInstance()`方法,由于`instance != null`,但是此时`instance`对象还没有被赋予真正有效的值,从而无法取得正确的service单例对象.

这就是著名的双重检查锁定问题,对象引用在没有同步的情况下进行读操作,导致用户可能会获取未构造完成的对象.

**对此问题,最简单解决方案就是使用`volatile`修饰目标属性;**

4. 线程安全内部静态类

```
public class SingletonSafeThird {
    private SingletonSafeThird() {
    }
    
    public static SingletonSafeThird getInstance(){
        return SingletonHolder.instance;
    }
    
    private static class SingletonHolder{
        private static final SingletonSafeThird instance = new SingletonSafeThird(); 
    }
}
```
