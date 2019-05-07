## Java静态代理：
代理对象和目标对象实现了相同的接口，目标对象作为代理对象的一个属性，具体接口实现中，代理对象可以在调用目标对象相应方法前后加上其他业务处理逻辑。

>缺点：**一个代理类只能代理一个业务类。如果业务类增加方法时，相应的代理类也要增加方法。**

--------------------------------------------------------------------------------

## Java动态代理：

Java动态代理是写一个类实现`InvocationHandler`接口，重写`Invoke`方法，在`Invoke`方法可以进行增强处理的逻辑的编写，这个公共代理类在运行的时候才能明确自己要代理的对象，同时可以实现该被代理类的方法的实现，然后在实现类方法的时候可以进行增强处理。

>实际上：**代理对象的方法 = 增强处理 + 被代理对象的方法**

--------------------------------------------------------------------------------

## JDK和CGLIB生成动态代理类的区别：
>+ `JDK动态代理`只能针对实现了接口的类生成代理（实例化一个类）。
  + 此时代理对象和目标对象实现了相同的接口，目标对象作为代理对象的一个属性，具体接口实现中，可以在调用目标对象相应方法前后加上其他业务处理逻辑
+ `CGLIB`是针对**类实现代理**，主要是对指定的类生成一个子类（没有实例化一个类），覆盖其中的方法 。