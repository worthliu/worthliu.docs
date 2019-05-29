`限流`的目的是通过对并发访问或请求进行限速或者一个时间窗口内的请求进行限速来保护系统,一旦达到限制速率则可以拒绝服务,排队或等待,降级;
+ 限制总并发数(如:数据库连接池,线程池)
+ 限制瞬间并发数(如:`Nginx`的`limit-conn`模块,用来限制瞬间并发连接数)
+ 限制时间窗口内的平均速率(如:`Guava`的`RateLimiter`,`Nginx`的`limit_req`模块,用来限制每秒的平均速率)
+ 限制远程接口调用速率
+ 限制`MQ`消费速率

## `限流算法`

### `令牌桶算法`

令牌桶算法,是一个存放固定容量令牌的桶,按照固定速率往桶里添加令牌;

>算法描述:
+ 假设限制`2r/s`,则按照500毫秒的固定速率往桶总添加令牌;
+ 桶中最多存放`b`个令牌,当桶满时,新添加的令牌被丢弃或拒绝;
+ 当一个`n`个字节大小的数据包到达,将从桶中删除`n`个令牌,接着数据包被发送到网络上;
+ 如果桶中的令牌不足`n`个,则不会删除令牌,且该数据包将被限流(要么丢弃,要么在缓冲区等待)


### `漏桶算法`

漏桶作为计量工具(`The Leaky Bucket Algorithm as a Meter`)时,可以用于流量整形和流量控制;

>算法描述:
+ 一个固定容量的漏桶,按照常量固定速率流出水滴
+ 如果桶是空的,则不需流出水滴
+ 可以以任意速率流入水滴到漏桶
+ 如果流入水滴超出了桶的容量,则流入的水滴溢出了(被丢弃),而漏桶容量是不变的


两种算法的比较:
+ `令牌桶`是**按照固定速率往桶中添加令牌**,请求是否被处理需要看桶中令牌是否足够,`当令牌数减为零时,则拒绝新的请求`;
+ `漏桶`是**按照常量固定速率流出请求**,流入请求速率任意,`当流入的请求数累积到漏桶容量时,则新流入的请求被拒绝`;
+ `令牌桶`限制的是**平均流入速率(允许突发请求,只要有令牌就可以处理),并允许一定程度的突发流量**;
+ `漏桶`限制的是**常量流出速率(即流出速率是一个固定常量值)**,从而平滑突发流入速率;


**`计数器`来进行限流,主要用来限制总并发数.只要全局请求数或者一定时间段的总请求数达到设定阈值,则进行限流;**

## `应用级限流`

+ `限流总并发/连接/请求数` : **对于一个应用系统而言,一定会有极限并发/请求数,总有一个`TPS/QPS`阈值,如果超了阈值,则系统就会不响应用户请求或响应的非常慢,因此最好进行过载保护,以防止大量请求涌入击垮系统;**
  + 如`Tomcat`中`Connector`有几个配置:
    + `acceptCount` : 最大接收连接数,超出排队大小,则拒绝连接; 
    + `maxConnecions` : 瞬时最大连接数,超出的会排队等待; 
    + `maxThreads` : `Tomcat`能启动用来处理请求的最大线程数;
+ `限流总资源数`
  + 使用池化技术来限制总资源数,超出则可以等待或者异常抛出;
+ `限流某个接口的总并发/请求数`
  + 针对特定业务处理,因为粒度比较细,可以为每个接口都设置相应的阈值;
  + 使用`Java`中的`AtomicLong`或者`Semaphore`或者`Hystrix`在信号量模式下也使用`Semaphore`限制某个接口的总并发数;
+ `限流某个接口的时间窗请求数`
  + 一个时间窗口内的请求数,如想`限制某个接口/服务每秒/每分钟/每天的请求数/调用量`;
+ `平滑限流某个接口的请求数`

## `分布式限流`

分布式限流最关键是要将限流服务做成原子化,而解决方案可以使用`Redis+Lua`或者`Nginx+Lua`技术进行实现,通过这两种技术可以实现高并发和高性能;

## `接入层限流`

接入层通常指请求流量的入口,该层的主要目的有:`负载均衡,非法请求过滤,请求聚合,缓存,降级,限流,A/B测试,服务质量监控等`;

>`Nginx`接入层限流使用自带两个模块:
+ `ngx_http_limit_conn_module`,连接数限流模块;
  + 用来对某个`key`对应的总的网络连接数进行限流,如`IP，域名`
+ `ngx_http_limit_req_module`,漏桶算法实现的请求限流模块;
　+ 用来对某个`key`对应的请求的平均速率进行限流,`平滑模式(delay)`和`允许突发模式(nodelay)`;

### `ngx_http_limit_conn_module`

```
http{
	limit_conn_zone $binary_remote_addr zone=addr:10m;
	limit_conn_log_level error;
	limit_conn_status 503;

	...
	server{
		...
		location /limit{
			limit_conn addr 1;
		}
		...
	}
	...
}
```

+ `limit_conn` : 要配置存放`key`和计数器的共享内存区域和指定`key`的最大连接数;
+ `limit_conn_zone` : 用来配置限流`key`及存放`key`对应信息的共享内存区域大小;
  + `$binary_remote_addr`,表示`IP地址`
  + `$server_name`,表示`域名`
+ `limit_conn_status` : 配置被限流后返回的状态码,默认返回503
+ `limit_conn_log_level` : 配置记录被限流后的日志级别,默认error级别


>`limit_conn`的主要执行过程:
+ 请求进入后首先判断当前`limit_conn_zone`中相应`key`的连接数是否超出了配置的最大连接数;
+ 如果超过了配置的最大大小,则被限流,返回`limit_conn_status`定义的错误状态码.
  + 否则相应`key`的连接数加1,并注册请求处理完成的回调函数;
+ 进行请求处理
+ 在结束请求阶段会调用注册的回调函数对相应`key`的连接数减1;

### `ngx_http_limit_req_module`

```
http{
	limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
	limit_conn_log_level error;
	limit_conn_status 503;
	...
	server{
		...
		location /limit{
			limit_req zone=one burst=5 nodelay;
		}
	}
}
```

+ `limit_req` : 配置限流区域,桶容量(突发容量,默认为0),是否延迟模式(默认延迟)
+ `limit_req_zone` : 配置限流`key`,存放`key`对应信息的共享内存区域大小,固定请求速率.
+ `limit_conn_status` : 配置被限流后返回的状态码,默认返回503
+ `limit_conn_log_level` : 配置记录被限流后的日志级别,默认级别为error;

>`limit_req`执行过程:
+ 请求进入后首先判断最后一次请求时间相对于当前时间(第一次是0)是否需要限流,如果需要限流,则执行步骤2,否则执行步骤3;
+ 如果没有配置桶容量(`burst`),则桶容量为`0`,按照固定速率处理请求.如果请求被限流,则直接返回相应的错误码(默认为`503`)
  + 如果配置了桶容量(`burst>0`)及延迟模式(没有配置`nodelay`).
    + 如果桶满了,则新进入的请求被限流.
    + 如果没有满,则请求会以固定平均速率被处理(按照固定速率并根据需要延迟处理请求,延迟使用休眠实现);
  + 如果配置了桶容量(`burst>0`)及非延迟模式(配置了`nodelay`),则不会按照固定速率处理请求,而是允许突发处理请求.
    + 如果桶满了,则请求被限流,直接返回相应的错误码;
+ 如果没有被限流,则正常处理请求;
+ `Nginx`会在相应时机选择一些(`3个节点`)限流`key`进行过期处理,进行内存回收;


## `节流`

想在特定时间窗口内对重复的相同事件最多只处理一次,或者想限制多个连续相同事件最小执行时间间隔,那么可使用`节流(Throttle)`实现,其防止多个相同事件连续重复执行;

### `throttleFirst/throttleLast`

`throttleFirst/throttleLast`是指在一个时间窗口内,如果有重复的多个相同事件要处理,则只处理第一个或最后一个.

其相当于一个事件频率控制器,把一段时间内重复的多个相同事件变为一个,减少事件处理频率,从而减少无用处理,提升性能;

+ `throttleFirst` : 在一个时间窗口内只会处理该时间窗口内的第一个事件.
+ `throttleLast` : 会处理该时间窗口内的最后一个事件;

### `throttleWithTimeout`

`throttleWithTimeout`叫做`debounce(去抖)`,限制两个连续事件的先后执行时间不得小于某个时间窗口;

