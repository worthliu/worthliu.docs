## 远程通讯协议的基本原理
网络通信需要做的就是将流从一台计算机传输到另外一台计算机，基于传输协议和网络`IO`来实现，其中传输协议比较出名的有`http`、`tcp`、`udp`等等;

`http`、`tcp`、`udp`都是在基于`Socket`概念上为某类应用场景而扩展出的传输协议，网络`IO`，主要有`bio`、`nio`、`aio`三种方式，所有的分布式应用通讯都基于这个原理而实现，只是为了应用的易用，各种语言通常都会提供一些更为贴近应用易用的应用层协议。

## 应用级协议`Binary-RPC`
`Binary-RPC`是一种和`RMI`类似的远程调用的协议，它和`RMI`的不同之处在于它以标准的二进制格式来定义请求的信息(请求的对象、方法、参数等)，这样的好处是什么呢，就是在跨语言通讯的时候也可以使用。

>来看下`Binary-RPC`协议的一次远程通信过程：
+ 客户端发起请求，按照`Binary-RPC`协议将请求信息进行填充；
+ 填充完毕后将二进制格式文件转化为流，通过传输协议进行传输；
+ 接收到在接收到流后转换为二进制格式文件，按照`Binary-RPC`协议获取请求的信息并进行处理；
+ 处理完毕后将结果按照`Binary-RPC`协议写入二进制格式文件中并返回。

>问题总结：
+ 传输的标准格式是？
	+ 标准格式的二进制文件。
+ 怎么样将请求转化为传输的流？
	+ 将二进制格式文件转化为流。
+ 怎么接收和处理流？
	+ 通过监听的端口获取到请求的流，转化为二进制文件，根据协议获取请求的信息，进行处理并将结果写入`XML`中返回。
+ 传输协议是？
	+ `Http` 。

## `Hessian`——一种实现远程通讯的`library`
`Hessian`是由`caucho`提供的一个基于`binary-RPC`实现的远程通讯`library`。

>+ 是基于什么协议实现的？
  + 基于`Binary-RPC`协议实现。
+ 怎么发起请求？
  + 需通过`Hessian`本身提供的`API`来发起请求。
+ 怎么将请求转化为符合协议的格式的？
  + `Hessian`通过其自定义的串行化机制将请求信息进行序列化，产生二进制流。
+ 使用什么传输协议传输？
  + `Hessian`基于`Http`协议进行传输。
+ 响应端基于什么机制来接收请求？
  + 响应端根据`Hessian`提供的`API`来接收请求。
+ 怎么将流还原为传输格式的？
  + `Hessian`根据其私有的串行化机制来将请求信息进行反序列化，传递给使用者时已是相应的请求信息对象了。
+ 处理完毕后怎么回应？
  + 处理完毕后直接返回,`hessian`将结果对象进行序列化,传输至调用端。

## `Hessian`源码分析
以`hessian`和`spring dm server`整合环境为例。

### 客户端发起请求
Hessian 的这个远程过程调用，完全使用动态代理来实现的。有客户端可以看出。

除去`spring`对其的封装，客户端主要是通过`HessianProxyFactory`的`create`方法就是创建接口的代理类，该类实现了接口，JDK的`proxy`类会自动用`InvocationHandler`的实现类（该类在`Hessian`中表现为`HessianProxy`）的`invoke`方法体来填充所生成代理类的方法体。

>客户端系统启动时： 根据`serviceUrl`和`serviceInterface`创建代理。
+ `HessianProxyFactoryBean类`   
+ `HessianClientInterceptor类`
  + `createHessianProxy(HessianProxyFactory proxyFactory) `
+ `HessianProxyFactory类`
  + `public Object create(Class api, String urlName)`
 
#### 客户端调用`hessian`服务时：

```
HessianProxy类的 invoke(Object proxy, Method method, Object []args) 方法

String methodName = method.getName();// 取得方法名

Object value = args[0]; // 取得传入参数

conn = sendRequest(mangleName, args) ;// 通过该方法和服务器端取得连接

httpConn = (HttpURLConnection) conn;

code = httpConn.getResponseCode();// 发出请求
```

#### 等待服务器端返回相应

```
is = conn.getInputStream();

Object value = in.readObject(method.getReturnType()); // 取得返回值
 
HessianProxy类的URLConnection sendRequest(String methodName, Object []args) 方法：

URLConnection  conn = _factory.openConnection(_url); // 创建 

URLConnection OutputStream os = conn.getOutputStream();
// 封装为hessian自己的输入输出API
AbstractHessianOutput out = _factory.getHessianOutput(os); 

out.call(methodName, args);

return conn;
```       

### 服务器端接收请求

服务器端截获相应请求交给：`org.springframework.remoting.caucho.HessianServiceExporter`

具体处理步骤如下：
+ HessianServiceExporter 类
  + `(HessianExporter) invoke(request.getInputStream(), response.getOutputStream());`
+ HessianExporter 类
  + `(Hessian2SkeletonInvoker) this.skeletonInvoker.invoke(inputStream, outputStream);`
+ Hessian2SkeletonInvoker 类
  + 将输入输出封转化为转化为`Hessian`特有的`Hessian2Input`和`Hessian2Output`

```
Hessian2Input in = new Hessian2Input(isToUse);

in.setSerializerFactory(this.serializerFactory);

AbstractHessianOutput out = null;

int major = in.read();

int minor = in.read();

out = new Hessian2Output(osToUse);

out = new HessianOutput(osToUse);

out.setSerializerFactory(this.serializerFactory);

(HessianSkeleton) this.skeleton.invoke(in, out);
```

+ HessianSkeleton 类

```
String methodName = in.readMethod(); //读取方法名

Method method = getMethod(methodName);

Class []args = method.getParameterTypes(); //读取方法参数

Object []values = new Object[args.length];

result = method.invoke(service, values);//执行相应方法并取得结果

out.writeObject(result);//结果写入到输出流
```

---        
**总结： 由上面源码分析可知，客户端发起请求和服务器端接收处理请求都是通过 hessian 自己的 API 。**

**输入输出流都要封装为`hessian`自己的`Hessian2Input`和`Hessian2Output`，接下来一节我们将去了解`hessian`自己封装的输入输出到底做了些什么！**
 

## `Hessian`的序列化和反序列化实现
`hessian`源码中`com.caucho.hessian.io`这个包是`hessian`实现序列化与反序列化的核心包。

其中`AbstractSerializerFactory`，`AbstractHessianOutput`，`AbstractSerializer`，`AbstractHessianInput`，`AbstractDeserializer`是`hessian`实现序列化和反序列化的核心结构代码。
 
+ `AbstractSerializerFactory`，它有`2`个抽象方法：
  + 根据类来决定用哪种序列化工具类 `abstract public Serializer getSerializer(Class cl)  throws HessianProtocolException; `
  + 根据类来决定用哪种反序列化工具类`abstract public Deserializer getDeserializer(Class cl)  throws HessianProtocolException;`
+ `SerializerFactory`继承`AbstractSerializerFactory`。
  + 在`SerializerFactory`有很多静态`map`用来存放类与序列化和反序列化工具类的映射，这样如果已经用过的序列化工具就可以直接拿出来用，不必再重新实例化工具类。
 + 在`SerializerFactory`中，实现了抽象类的`getSerializer`方法，根据不同的需要被序列化的类来获得不同的序列化工具，一共有`17`种序列化工具，`hessian`为不同的类型的`java`对象实现了不同的序列化工具，默认的序列化工具是`JavaSerializer`。
 + 在`SerializerFactory`中，也实现了抽象类的`getDeserializer`方法，根据不同的需要被反序列化的类来获得不同的反序列化工具，默认的反序列化工具类是`JavaDeserializer`。
+ `HessianOutput`继承`AbstractHessianOutput`成为序列化输出流的一种实现。
它会实现很多方法，用来做流输出。
  + 需要注意的是方法，它会先调用`serializerFactory`根据类来获得`serializer`序列化工具类

```
public void writeObject(Object object) throws IOException { 
	if (object == null) { 
	writeNull(); 
	return; 
	} 
	 
	Serializer serializer; 
	 
	serializer = _serializerFactory.getSerializer(object.getClass());  
	 
	serializer.writeObject(object, this); 
} 
```

+ 现在我们来看看`AbstractSerializer`。
  + 其`writeObject`是必须在子类实现的方法，`AbstractSerializer`有`17`种子类实现，`hessian`根据不同的`java` 对象类型来实现了不同的序列化工具类，其中默认的是`JavaSerializer`。
  + 而`JavaSerializer`的`writeObject`方法的实现，遍历`java`对象的数据成员，根据数据成员的类型来获得各自的`FieldSerializer`，一共有`6`中默认的`FieldSerializer`。
  + 拿默认的`FieldSerializer`举例，还是调用`AbstractHessianOutput`的子类来`writeObject`，这个时候，肯定能找到相应的`Serializer`来做序列化
  + 同理可以反推出`hessian`的反序列化机制。`SerializerFactory`可以根据需要被反序列化的类来获得反序列化工具类来做反序列化操作。
 
**总结：得益于`hessian`序列号和反序列化的实现机制，`hessian`序列化的速度很快，而且序列化后的字节数也较其他技术少。**
 

>参考文献：
  1. 《 Java 远程通讯可选技术及原理》 http://java.chinaitlab.com/base/740383.html
  2. 《 Hessian-3.2.0 源码》
  3. 《 hessian 序列化实现初探》 http://www.javaeye.com/topic/245238
  4. 《 Hessian 2.0 序列化协议规范》http://blog.csdn.net/xpspace/archive/2007/10/05/1811603.aspx