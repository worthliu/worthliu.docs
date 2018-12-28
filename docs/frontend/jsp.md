**`JSP`一种动态网页开发技术，它使用`JSP`标签在`HTML`网页中插入`Java`代码，标签通常以`<%%>`起始终结；**

### JSP生命周期：

>+ 编译阶段：`servlet`容器编译`servlet`源文件，生成`servlet`类；
+ 初始化阶段：加载与`JSP`对应的`Servlet`类，创建其实例，并调用它的初始化方法；
+ 执行阶段：调用与`JSP`对应的`Servlet`实例的服务方法；
+ 销毁阶段：调用与`JSP`对应的`Servlet`实例的销毁方法，然后销毁`Servlet`实例；

### JSP指令：

>+ `<%@ page ···%>`：定义页面的依赖属性，比如脚本语言、`error`页面、缓存需求等
+ `<%@ include ...%>` ：包含其他文件
+ `<%@ taglib ...%>`：引入标签库的定义，可以是自定义标签

### JSP隐含九个对象：

隐含对象|所属的类|说明|
--|--|--|
`request`| `javax.servlet.http.HttpServletRequest`| 客户端的请求信息|
`response`| `javax.servlet.http.HttpServletResponse`| 网页传回客户端的响应|
`session`| `javax.servlet.http.HttpSession` |与请求有关的会话|
`out`| `javax.servlet.jsp.JSPWriter` |向客户端浏览器输出数据的数据流|
`application`| `javax.servlet.ServletContext` |提供全局的数据，一旦创建就保持到服务器关闭|
`pageContext`| `javax.servlet.jsp.PageContext`| `JSP`页面的上下文，用于访问页面属性|
`page`| `java.lang.Object` |同`Java`中的`this`，即`JSP`页面本身|
`config`| `javax.servlet.servletConfig` |`Servlet`的配置对象|
`exception`| `java.lang.Throwable` |针对错误网页，捕捉一般网页中未捕捉的异常|

### JSTL标签：
**引用语法：`<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>`**

>核心标签：
+ `<c:out>`：用于在`JSP`中显示数据
+ `<c:set>`：用于保存数据
+ `<c:remove>`：用于删除数据
+ `<c:catch>`：用来处理产生错误的异常状况，并且将错误信息储存起来
+ `<c:import>`：检索一个绝对或相对`URL`，然后将其内容暴露出来
+ `<c:redirect>`：重定向至一个新的`URL`
+ `<c:if>`：同`if`
+ `<c:choose>`：只当做`<c:when>`和`<c:otherwise>`的父标签
+ `<c:when>`:用来判断条件是否成立，`<c:otherwise>`条件判断为`false`时操作
+ `<c:forEach>`：迭代标签








