`SpringMVC`框架是以请求为驱动，围绕`Servlet`设计，将请求发给控制器，然后通过模型对象，分派器来展示请求结果视图。

其中核心类是`DispatcherServlet`，它是一个`Servlet`，顶层是实现的`Servlet`接口。

## `spring MVC`使用

使用前需要在`web.xml`中配置`DispatcherServlet`。并且需要配置`spring`监听器`ContextLoaderListener`

```
<listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>        
<servlet>
    <servlet-name>springmvc</servlet-name>
	<servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <!-- 如果不设置init-param标签，则必须在/WEB-INF/下创建xxx-servlet.xml文件，其中xxx是servlet-name中配置的名称。  -->
        <init-param>
		   <param-name>contextConfigLocation</param-name>
		   <param-value>classpath:spring/springmvc-servlet.xml</param-value>
	    </init-param>
	<load-on-startup>1</load-on-startup>
</servlet>
<servlet-mapping>
	<servlet-name>springmvc</servlet-name>
	<url-pattern>/</url-pattern>
</servlet-mapping>
```

## `spring MVC`工作流程

![springMVC](/images/springMVC.png)

>+ 客户端（浏览器）发送请求，直接请求到`DispatcherServlet`。
+ `DispatcherServlet`根据请求信息调用`HandlerMapping`，解析请求对应的`Handler`。
+ 解析到对应的`Handler`后，开始由`HandlerAdapter`适配器处理。
+ `HandlerAdapter`会根据`Handler`来调用真正的处理器开处理请求，并处理相应的业务逻辑。
+ 处理器处理完业务后，会返回一个`ModelAndView`对象，`Model`是返回的数据对象，`View`是个逻辑上的`View`。
+ `ViewResolver`会根据逻辑`View`查找实际的`View`。
+ `DispaterServlet`把返回的`Model`传给`View`。
+ 通过`View`返回给请求者（浏览器）

### `spring MVC`的工作机制

+ 在容器初始化时,会建立所有`url`和`controller`的对应关系,保存到`Map<url,controller>`中.
  + `tomcat`启动时会通知`spring`初始化容器(`加载bean的定义信息和初始化所有单例bean`),然后`springmvc`会遍历容器中的`bean`,获取每一个`controller`中的所有方法访问的`url`,然后将`url`和`controller`保存到一个`Map`中;
+ 这样就可以根据`request`快速定位到`controller`,因为最终处理`request`的是`controller`中的方法,`Map`中只保留了`url`和`controller`中的对应关系,所以要根据`request`的`url`进一步确认`controller`中的`method`;
+ **这一步工作的原理就是拼接`controller`的`url`(`controller`上`@RequestMapping`的值)和方法的`url`(`method`上`@RequestMapping`的值),与`request`的`url`进行匹配,找到匹配的那个方法;**
+ 确定处理请求的`method`后,接下来的任务就是`参数绑定`,把`request`中参数绑定到方法的`形式参数`上,这一步是整个请求处理过程中最复杂的一个步骤。

>`springmvc`提供了两种`request`参数与方法形参的绑定方法:
+ 通过注解进行绑定,@RequestParam
  + 使用注解进行绑定,我们只要在方法参数前面声明`@RequestParam("a")`,就可以将`request`中参数`a`的值绑定到方法的该参数上.
+ 通过参数名称进行绑定.
　+ 使用参数名称进行绑定的前提是必须要获取方法中参数的名称,`Java反射`只提供了获取方法的参数的类型,并没有提供获取参数名称的方法.
  + `springmvc`解决这个问题的方法是用`asm框架`**读取字节码文件,来获取方法的参数名称**.
    + `asm框架`是一个字节码操作框架,使用注解来完成参数绑定,这样就可以省去`asm框架`的读取字节码的操作.

## 谈谈`springmvc`的优化

上面我们已经对springmvc的工作原理和源码进行了分析,在这个过程发现了几个优化点:

1. `controller`如果能保持单例,尽量使用单例,这样可以减少创建对象和回收对象的开销.
  + 如果`controller`的类变量和实例变量可以以方法形参声明的尽量以方法的形参声明,不要以类变量和实例变量声明,这样可以避免线程安全问题.
2. 处理`request`的方法中的形参务必加上`@RequestParam`注解,这样可以避免`springmvc`使用`asm框架`读取`class文件`获取方法参数名的过程.
  + 即便springmvc对读取出的方法参数名进行了缓存,如果不要读取class文件当然是更加好.
3. 阅读源码的过程中,发现`springmvc`并没有对处理`url`的方法进行缓存;
  + 也就是说每次都要根据请求`url`去匹配`controller`中的方法`url`,如果把`url`和`method`的关系缓存起来,会不会带来性能上的提升呢?
  + 有点恶心的是,负责解析`url`和`method`对应关系的`ServletHandlerMethodResolver`是一个`private`的内部类,不能直接继承该类增强代码,必须要该代码后重新编译.当然,如果缓存起来,必须要考虑缓存的线程安全问题.