# Servlet

## Servlet运行过程
`Servlet`是由`Servlet容器`调用的（如`Tomcat`，也称为`Web服务器`），在Web浏览器连上`Servlet容器`，并向`Servlet容器`发送`http请求`（**包括请求行，请求头，请求正文**），`Web Server`解析出想访问的**主机名，web应用，web资源**后： 

>1. `Servlet容器`先检查是否已经创建了`Servlet实例对象`，如果没有，先创建一个`Servlet实例对象`，并调用`Servlet`的`init()`方法完成对象初始化；
如果已经创建了，则直接执行下一步。因为Servet实例对象仅在第一次访问时创建，之后无论有多少客户机再次访问Servlet，都不会重复创建Servlet实例对象，也不会再次执行init()方法 （**Servlet就是一个单态实例**）
2. Servlet容器创建一个HttpRequest对象，将Web Client请求的信息封装到这个对象中 ；
3. Servlet容器创建一个HttpResponse对象 ；
4. Servlet容器调用HttpServlet对象的service方法，把HttpRequest对象与HttpResponse对象作为参数传给 HttpServlet 对象。 
5. HttpServlet调用HttpRequest对象的有关方法，获取Http请求信息。 
6. HttpServlet调用HttpResponse对象的有关方法，生成响应数据（包括响应行，响应头，响应正文） 
7. Servlet容器把HttpServlet的响应结果传给Web Client。