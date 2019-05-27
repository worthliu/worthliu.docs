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

+ `HTTP`心跳检查


```
upstream backend{
	server xxx.xxx.xxx.1:8080 weight=1;
	server xxx.xxx.xxx.2:8080 weight=1;

	check interval=3000 rise=1 fall=3 timeout=2000 type=http;
	check_http_send "HEAD /status HTTP/1.0\r\n\r\n";
	check_http_expect_alive http_2xx http_3xx;
}
```

>`HTTP`心跳检查需要额外配置:
+ `check_http_send` : 检查时发的`HTTP`请求内容;
+ `check_http_expect_alive` : 当上游服务器返回匹配的响应状态码时,则认为上游服务器存活;

**检查间隔时间不能太短,否则可能因为心跳检查包太多造成上游服务器挂掉,同时要设置合理的超时时间;**


### `HTTP`反向代理

+ `全局配置(proxy cache)`

```
proxy_buffering on;
proxy_buffer_size 4k;
proxy_buffers 512 4k;
proxy_busy_buffers_size 64k;
proxy_temp_file_write_size 256k;
proxy_cache_lock on;
proxy_cache_lock_timeout 200ms;
proxy_temp_path /tmpfs/proxy_temp;
proxy_cache_path /tmpfs/proxy_cache levels=1:2 keysd_zone=cache:512m inactive=5m max_size=8g;

proxy_connect_timeout 3s;
proxy_read_timeout 5s;
proxy_send_timeout 5s;
```

**开启`proxy_buffer`,缓存内容将存放在`tmpfs`以提升性能,设置超时时间;**

+ `location配置`


```
location ~ ^/backend/(.*)${
	# 设置一致性哈希负载均衡key
	set_by_lua_file $consistent_key "/export/App/c.3.cn/lua/lua_balancing_backend.properties";

	#失败重试配置
	proxy_next_upstream error timeout http_500 http_502 http_504;
	proxy_next_upstream_timeout 2s;
	proxy_next_upstream+tries 2;

	#请求上游服务器使用GET方法(不管请求是什么方法)
	proxy_method GET;
	#不给上游服务器传递请求体
	proxy_pass_request_body off;
	#不给上游服务器传递请求头
	proxy_pass_request_headers off;
	#设置上游服务器的哪些响应头不发送给客户端
	proxy_hide_header Vary;
	#支持keep-alive
	proxy_http_version 1.1;
	proxy_set_header Connection "";
	#给上游服务器传递Reference,Cookie和Host(按需传递)
	proxy_set_header Referer $http_referer;
	proxy_set_header Cookie $http_cookie;
	proxy_set_header Host web.c.3.local;
	proxy_pass http://backend /$1$is_args$args;
}
```

### `HTTP动态负载均衡`

若通过`upstream`列表有变更,都需要到服务器进行修改,首先是管理容易出现问题,而且对于`upstream`服务上线无法自动注册到`nginx upstream`列表;

因此,我们需要一种服务注册与发现的系统;

**`Consul`是一款开源的分布式服务注册与发现系统,通过`HTTP API`可以使得服务注册,发现实现起来非常简单;**

>+ `服务注册` : 服务实现者可以通过`HTTP API`或`DNS`方式,将服务注册到`Consul`;
+ `服务发现` : 服务消费者可以通过`HTTP API`或`DNS`方式,从`Consul`获取服务的`IP:PORT`;
+ `故障检测` : 支持`TCP`或`HTTP`等方式的健康检查机制,从而在服务故障时自动摘除; 
+ `KV存储` : 使用KV存储实现动态配置中心,其使用`HTTP`长轮询实现变更触发和配置更改;
+ `多数据中心`
+ `Raft算法` : `Consul`使用`Raft算法`实现集群数据一致性;

![consul.png](/images/consul.png)

#### `Consul+Consul-template`

>+ `upstream`服务启动,通过管理后台向`Consule`注册服务;
+ 在`Nginx`机器上部署并启动`Consul-template Agent`,其通过长轮询监听服务变更;
+ `Consul-template`监听到变更后,动态修改`upstream`列表;
+ `Consul-template`修改完`upstream`列表后,调用重启`Nginx`脚本重启`Nginx`;

**通过`Consul+Consul-template`方式,每次发现配置变更都需要`reload nginx`,而`reload`是有一定损耗的.而且,如果需要长连接支持的话,那么当`reload nginx`时长连接所在`worker`进程会进行优雅退出,并当该`worker`进程上的所有连接都释放时,进程才真正退出;**

#### `Consul+OpenResty`
使用`Consul`注册服务,使用`OpenResty balancer_by_lua`实现无`reload`动态负载均衡;

>+ 通过`upstream server`启动或停止时注册服务,或者通过`Consul`管理后台注册服务
+ `Nginx`启动时会调用`init_by_lua`,启动时拉取配置,并更新到共享字典来存储`upstream`列表;
+ 通过`init_worker_by_lua`启动定时器,定期去`Consul`拉取配置并实时更新到共享字典;
+ `balancer_by_lua`使用共享字典存储的`upstream`列表进行动态负载均衡;

