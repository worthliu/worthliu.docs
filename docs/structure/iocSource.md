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
  + `doCreateBean()`-->`createBeanInstance()`-->`instantiateBean()`
  + -->`populateBean()`