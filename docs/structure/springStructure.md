>+ Spring框架包含的功能被组织成了大约20个模块。
+ 模块划分为：
  + Core Container（核心容器）
  + Data Access/Integration（数据访问/集成）
  + Web（Spring MVC）
  + AOP (Aspect Oriented Programming面向切面编程)
  + Instrumentation
  + Test


#### 核心容器
　　核心容器包含了核心（Core），Bean组件（Beans），上下文（Context）和表达式语言（Expression Language）模块。

　　Core和Bean模块提供框架的基础部分，包括IoC和Dependency Injection功能。BeanFactorys是一个工厂模式的精密实现。它去掉了编程实现单例的需要，并允许你解除配置信息，以及实际程序逻辑的特定依赖之间的耦合。
　
　Context模块构建在则Core和Bean模块的基础之上：它可以让你以框架中的风格来访问对象，这和JNDI的注册是相似的。

  上下文模块继承了来自Bean模块的特性，并且添加国际化（比如使用资源包）、事件传播、资源加载和透明创建上下文（如Servlet容器）等方面的支持。上下文模块也支持Java EE特性，比如EJB，JMX和基本的远程调用。ApplicationContext接口是上下文模块的焦点。
　　
  表达式语言模块提供了强大的表达式语言，在运行时查询和操作对象图。这是JSP 2.1规范中的统一表达式语言（Unified EL）的一个扩展。该表达式语言支持设置和获取属性值，属性定义，方法调用，访问数组，集合以及索引的上下文。支持逻辑和数字运算，命名变量。还支持通过名称从Spring的IoC容器中检索对象。它也支持list的投影和选择操作，还有普通的list聚集操作。

#### 数据访问/集成
　　数据访问/集成层包括JDBC、ORM、OXM、JMS和事务模块。
　　
>+ JDBC模拟提供了不需要编写冗长的JDBC代码和解析数据库厂商特有的错误代码的JDBC抽象层。
+ ORM模块提供了对流行的对象-关系映射API的集成层，包含JPA，JDO，Hibernate。使用ORM包，你可以使用所有的O/R映射框架并联合Spring提供的所有其他特性，比如前面提到的简单声明式事务管理功能。
+ OXM模块集成了支持对象/XML映射实现的抽象层，这些实现包括JAXB、Castor、XMLBeans、JiBX和XStream。
+ Java消息服务（JMS模块包含生成和处理消息的特性。
+ 事务模块支持对实现特定接口的类和所有POJO（普通Java对象）的编程式和声明式的事务管理。

#### Web
　　Web层包含了Web、Web-Servlet、WebSocket和Web-Portlet模块。

>+ Spring Web模块提供了基本的面向Web的集成功能，例如多个文件上传（multipart file-upload）、使用Servlet监听器和Web应用上下文对IoC容器进行初始化。它也包含Spring远程访问支持的web相关部分。
+ Web-Servlet模块包含了Spring对Web应用的模型-视图-控制器（MVC）模式的实现。Spring的MVC框架提供了一个对领域模型代码和Web表单之间的清晰分离，并且集成了其它所有Spring框架的特性。
+ Web-Portlet模块提供用于portlet环境和Web-Servlet模块功能镜像的MVC实现。

#### AOP和Instrumentation基础组件
　　Spring AOP模块提供AOP联盟兼容的面向切面编程实现，它允许你自定义，比如，方法拦截器和切入点来完全分离各功能的代码。使用源码级别的元数据功能，你也可以在你的代码中包含行为信息，在某种程度上类似于.NET属性。
　　
单独的Aspects模块提供了集成使用AspectJ。
　　
Instrumentation模块提供了类instrumentation的支持，和用于某些应用程序服务器的类加载器实现。

#### 测试Test
　　测试模块支持使用JUnit或者TestNG来测试Spring 组件。它提供了对Spring ApplicationContexts和这些上下文的缓存的一致加载。它也提供模拟对象，你可以用它在隔离条件下来测试你的代码。


## spring源码导入

The following has been tested against `IntelliJ IDEA 2016.2.2`

Steps
Within your locally cloned spring-framework working directory:

+ Precompile `spring-oxm` with `./gradlew :spring-oxm:compileTestJava`
+ Import into IntelliJ (`File -> New -> Project from Existing Sources -> Navigate to directory -> Select build.gradle`)
+ When prompted exclude the `spring-aspects` module (or after the import via `File-> Project Structure -> Modules`)
+ Code away