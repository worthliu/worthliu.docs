# Servlet

## Servlet生命周期
>**Servlet 加载—>实例化—>服务—>销毁**


>1. `init()`：在`Servlet`的生命周期中，仅在第一次创建`Servlet实例对象`并执行一次`init()`方法，后面无论有多少客户机访问Servlet，都不会重复执行`init()`。`Servlet实例对象`在两种情况下会创建 
  1. 首次访问`Servlet`时创建`Servlet实例对象`，并调用`init()`方法。 
  2. 如果在`web.xml`文件中的`servlet元素`中配置了`load-on-startup元素`，则会在web服务器启动时就创建`Servlet实例对象`，并调用`init()方法`。`struts框架`，就是在web服务器启动时就创建`Servlet` 
2. `service()`：它是`Servlet的核心`，负责响应客户的请求。每当一个客户请求一个`HttpServlet对象`，该对象的`Service()`方法就要调用，而且传递给这个方法一个“请求”（`ServletRequest`）对象和一个“响应”（`ServletResponse`）对象作为参数。在`HttpServlet`中已存在`Service()`方法。默认的服务功能是调用与`HTTP请求`的方法相应的`do功能`。 
3. `destroy()`： 仅执行一次，在服务器端停止且卸载`Servlet`时执行该方法。当`Servlet对象`退出生命周期时，负责释放占用的资源。
  1. 一个Servlet在运行`service()`方法时可能会产生其他的线程，因此需要确认在调用`destroy()`方法时，这些线程已经终止或完成。

## Servlet运行过程
`Servlet`是由`Servlet容器`调用的（如`Tomcat`，也称为`Web服务器`），在Web浏览器连上`Servlet容器`，并向`Servlet容器`发送`http请求`（**包括请求行，请求头，请求正文**），`Web Server`解析出想访问的**主机名，web应用，web资源**后： 

>1. `Servlet容器`先检查是否已经创建了`Servlet实例对象`，如果没有，先创建一个`Servlet实例对象`，并调用`Servlet`的`init()`方法完成对象初始化；
如果已经创建了，则直接执行下一步。因为`Servet实例对象`**仅在第一次访问时创建**，之后无论有多少客户机再次访问`Servlet`，都**不会重复创建`Servlet实例对象`**，也不会再次执行`init()`方法; （**Servlet就是一个单态实例**）
2. `Servlet容器`创建一个`HttpRequest对象`，将`Web Client请求`的信息封装到这个对象中 ；
3. `Servlet容器`创建一个`HttpResponse对象` ；
4. `Servlet容器`调用`HttpServlet对象`的`service方法`，把`HttpRequest对象`与`HttpResponse对象`作为参数传给 `HttpServlet 对象`。 
5. `HttpServlet`调用`HttpRequest对象`的有关方法，获取**Http请求信息**。 
6. `HttpServlet`调用`HttpResponse对象`的有关方法，**生成响应数据（包括响应行，响应头，响应正文）** 
7. `Servlet容器`把`HttpServlet`的响应结果传给`Web Client`。


## Servlet工作原理

>1. **Servlet接收和响应客户请求的过程**，首先客户发送一个请求，`Servlet`是调用`service()`方法对请求进行响应的，通过源代码可见，`service()`方法中**对请求的方式**进行了匹配，选择调用`doGet`,`doPost`等这些方法，然后再进入对应的方法中调用逻辑层的方法，实现对客户的响应。
  1. 在`Servlet接口`和`GenericServlet`中是没有`doGet（）`、`doPost（）`等等这些方法的，`HttpServlet`中定义了这些方法，但是都是返回`error信息`，所以，我们每次定义一个`Servlet`的时候，都必须实现`doGet`或`doPost`等这些方法。
2. 每一个自定义的Servlet都必须实现`Servlet的接口`，Servlet接口中定义了五个方法，其中比较重要的三个方法涉及到Servlet的生命周期，分别是上文提到的`init()`,`service()`,`destroy()`方法。
  1. `GenericServlet`是一个通用的，不特定于任何协议的`Servlet`,它实现了`Servlet接口`。而`HttpServlet`继承于`GenericServlet`，因此`HttpServlet`也实现了`Servlet接口`。所以我们定义`Servlet`的时候只需要继承`HttpServlet`即可。
3. `Servlet接口`和`GenericServlet`是不特定于任何协议的，而`HttpServlet`是特定于`HTTP协议`的类，所以`HttpServlet`中实现了`service()`方法，并将请求`ServletRequest`、`ServletResponse` 强转为`HttpRequest` 和 `HttpResponse`。

## Servlet是否线程安全

>`Servlet`体系结构是建立在`Java多线程机制`之上的，它的生命周期是由`Web容器`负责的。当客户端第一次请求某个`Servlet`时，`Servlet容器`将会根据`web.xml`配置文件实例化这个`Servlet类`。当有新的客户端请求该`Servlet`时，一般不会再实例化该`Servlet类`，也就是有多个线程在使用这个实例。 
　这样，当两个或多个线程同时访问同一个Servlet时，可能会发生多个线程同时访问同一资源的情况，数据可能会变得不一致。所以在用Servlet构建的Web应用时如果不注意线程安全的问题，会使所写的Servlet程序有难以发现的错误。 

>要解决问题，有如下方案供选择： 
1. `synchronized锁`，将需要同步的代码放在`synchronized代码块`中，单线程的，现实不适用，一次只能一个Client访问
2. 实现`SingleThreadModel接口`，这个接口为`标志接口`，如果servlet实现了该接口，会确保不会有两个线程同时执行`servlet`的`service()`方法。 servlet容器通过同步化访问`servlet的单实例`来保证，也可以通过维持`servlet的实例池`，对于新的请求会分配给一个空闲的servlet。 
但`SingleThreadModel`不会解决所有的线程安全隐患。例如，`会话属性`和`静态变量`仍然可以被多线程的多请求同时访问，即便使用了`SingleThreadModel`

## Servlet和Filter的区别

>**Filter对用户请求进行预处理，接着将请求交给Servlet进行处理并生成响应，最后Filter再对服务器响应进行后处理**。

Filter有如下几个用处：
>Filter可以进行对特定的url请求和相应做预处理和后处理。
  * 在HttpServletRequest到达Servlet之前，拦截客户的HttpServletRequest。
  * 根据需要检查HttpServletRequest，也可以修改HttpServletRequest头和数据。
  * 在HttpServletResponse到达客户端之前，拦截HttpServletResponse。
  * 根据需要检查HttpServletResponse，也可以修改HttpServletResponse头和数据。

>实际上Filter和Servlet极其相似，区别只是**Filter不能直接对用户生成响应**。	
实际上`Filter`里`doFilter()`方法里的代码就是从多个`Servlet`的`service()`方法里抽取的通用代码，通过使用Filter可以实现更好的复用。

>Filter和Servlet的生命周期：
1. `Filter`在`web服务器`启动时初始化
2. 如果某个`Servlet`配置了1 ，该`Servlet`也是在`Tomcat`（Servlet容器）启动时初始化。
3. 如果`Servlet`没有配置1 ，该`Servlet`不会在`Tomcat`启动时初始化，而是在请求到来时初始化。
4. 每次请求，`Request`都会被初始化，响应请求后，请求被销毁。
5. `Servlet`初始化后，将不会随着请求的结束而注销。
6. 关闭Tomcat时，`Servlet`、`Filter`依次被注销。