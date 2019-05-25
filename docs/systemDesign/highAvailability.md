## `负载均衡`与`反向代理`

用户访问时通过如`www.qianshenghua.com`的方式访问,在请求时,浏览器首先会查询`DNS`服务器获取对应`IP`,然后通过此`IP`访问对应的服务;

对此,是将`www.qianshenghua.com`域名映射多个`IP`,但是,存在一个最简单的问题,假设某台服务器重启或者出现故障,`DNS`会有一定的缓存时间,故障后切换时间长,而且没有对后端服务进行心跳检查和失败重试的机制;

+ 外网`DNS`应该用来实现用`GSLB(全局负载均衡)`进行流量调度,如将用户分配到离他最近的服务器上以提升体验.而且当某一区域的机房出现问题时,可以通过`DNS`指向其他区域的`IP`来使服务可用;
+ 内网`DNS`,可以实现简单的轮询负载均衡.考虑选择`HAProxy`和`Nginx`
  + `Nginx`一般用于七层负载均衡,其吞吐量有一定限制的;
    + 为了提升整体吞吐量,会在`DNS`和`Nginx`之间引入接入层;如`LVS`或`F5`;
    + `DNS`解析到`LVS/F5`,然后`LVS/F5`转发给`Nginx`,再由`Nginx`转发给后端`RealServer`;


>+ `二层负载均衡` : 通过改写报文的目标`MAC`地址为上游服务器`MAC`地址,源`IP`地址和目标`IP`地址是没有变的,负载均衡服务器和真实服务器共享同一个`VPN`;
  + 如`LVS DR`工作模式;
+ `四层负载均衡` : 根据端口将报文转发到上游服务(不同的`IP`地址和端口)
  + 如`LVS NAT`工作模式,`HAProxy`;
+ `七层负载均衡` : 根据端口号和应用层协议如`HTTP`协议的主机名,`URL`,转发报文到上游服务器(`不同的IP地址+端口`);
  + 如`HAProxy`,`Nginx`;

### `负载均衡`

+ **`upstream`配置**
  + `Nginx`配置上游服务器,即负载均衡到的真实处理业务的服务器,通过在`http`指令下配置`upstream`即可;

```
upstream backend{
	server xxx.xxx.xxx.1:9080 weight=1;
	server xxx.xxx.xxx.2:9080 weight=2;
}
```

>主要配置项说明:
1. `IP地址和端口` : 配置上游服务器的`IP`地址和端口;
2. `权重` : weight用来配置权重,默认都是1,权重越高分配给这台服务器的请求就越来越多;

+ **`负载均衡算法`**
  + `round-robin` : 轮询,默认负载均衡算法,即以轮询的方式将请求转发到上游服务器,通过配合`weight`配置可以实现基于权重的轮询;
  + `ip_hash` : 根据客户`IP`进行负载均衡,即相同的IP将负载均衡到同一个`upstream server`;
  + `hash key [consistent]` : 对某一个`key`进行哈希或者使用一致性哈希算法进行负载均衡.
    + 使用`Hash`算法存在的问题是,当添加或删除一台服务器时,将导致很多`Key`被重新负载均衡到不同的服务器;
    + 一致性哈希算法,当添加或删除一台服务器时,只有少数`key`将被重新负载均衡到不同的服务器;
  + `哈希算法` : 根据请求`uri`进行负载均衡,可以使用`Nginx`变量;
  + `least_conn` : 将请求负载均衡到最少活跃连接的上游服务器,如果配置的服务器较少,则将转而使用基于权重的轮询算法;


+ **`失败重试`**

两部分配置:`upstream server`和`proxy_pass`:

```
upstream backend{
	server xxx.xxx.xxx.1:8080 max_fails=2 fail_timeout=10s weight=1;
	server xxx.xxx.xxx.2:8080 max_fails=2 fail_timeout=10s weight=1;
}
```

+ 通过配置上游服务器的`max_fails`和`fail_timeout`,来指定每个上游服务器;
+ 当`fail_timeout`时间内失败了`max_fails`次请求,则认为该上游服务器不可用或不存活;
+ 然后将摘掉该上游服务器,`fail_timeout`时间后会再次将该服务器加入到存活上游服务器列表进行重试;

```
location /test{
	proxy_connect_timeout 5s;
	proxy_read_timeout 5s;
	proxy_send_timeout 5s;

	proxy_next_upstream error timeout;
	proxy_next_upstream_timeout 10s;
	proxy_next_upstream_tries 2;
	proxy_pass http://backend;
	add_headere upstream_addr $upstream_addr;
}
```

通过`proxy_next_upstream`相关配置,当遇到配置的错误时,会重试下一台上游服务器;

+ **`健康检查`**
  
`Nginx`对上游服务器的健康检查默认采用的是惰性策略.
1. `Nginx`商业版提供了`health_check`进行主动健康检查;
2. 集成`nginx_upstream_check_module`模块进行主动健康检查;

+ `TCP`心跳检查

```
upstream backend{
	server xxx.xxx.xxx.1:8080 weight=1;
	server xxx.xxx.xxx.2:8080 weight=1;
	check interval=3000 rise=1 fall=3 timeout=2000 type=tcp;
}
```

>`TCP`进行心跳检测配置项:
+ `interval` : 检测间隔时间
+ `fall` : 检测失败多少次后,上游服务器被标识为不存活;
+ `rise` : 检测成功多少次后,上游服务器标记为存活,并可以处理请求;
+ `timeout` : 检测请求超时时间配置;

