如果应用不设置超时,则可能会导致请求响应慢,慢请求累积导致连锁反应,甚至造成应用雪崩.而有些中间件或者框架在超时后进行重试(如设置超时重试两次),读服务天然适合重试,但写服务大多不能重试(如写订单,如果写服务是幂等的,则重试是允许的),重试次数太多会导致多倍请求流量,即模拟了`DDOS`攻击,后果可能是灾难;

因此,务必设置合理的重试机制,并且应该和熔断,快速失败机制配合.

+ `代理层超时与重试` : 如`HAProxy,Nginx,Twemproxy`,这些组件可实现代理功能;
  + `HAProxy,Nginx`实现请求的负载均衡;
  + `Twemproxy`实现`Redis`的分片代理;
+ `Web容器超时` : 如`Tomcat`,`Jetty`等,提供`Http`服务运行环境的;
  + 需要设置客户端和容器之间的网络连接/读/写超时时间
  + 和在此容器中默认`Socket`网络连接/读/写超时时间; 
+ `中间件客户端超时与重试` : 如`JSF`,`Dubbo`,`JMQ`,`CXF`,`HttpClinet`等
  + 需要设置客户的网络连接/读/写超时时间与失败重试机制;
+ `数据库客户端超时` : 如`MySQL`,`Oracle`
  + 设置`JDBC Connection`,`Statement`的网络连接/读/写超时时间,事务超时时间,获取连接池连接等待时间; 
+ `NoSQL客户端超时` : 如`Mongo`,`Redis`
  + 需要设置其网络连接/读/写超时时间,获取连接池连接等待时间; 
+ `业务超时` : 如订单取消任务,超时活动关闭,还有如通过`Future.get(timeout,unit)`限制某个接口的超时时间;
+ `前端Ajax超时` : 浏览器通过`Ajax`访问时的网络连接/读/写超时时间;


## `代理层超时与重试`

### `Nginx`

`Nginx`主要有4类超时设置:

+ `客户端超时设置` : 通过客户端超时设置避免客户端恶意或者网络状况不佳造成连接长期被占用,影响服务器的可处理能力;
  + `client_header_timeout time` : 设置读取客户端请求头超时时间,默认为`60s`.
    + 超时时间内客户端没有发送完请求头,则响应`408(Request Time-out)`状态码给客户端;
  + `client_body_timeout time` : 设置读取客户端内容体超时时间,默认为`60s`
    + 此超时时间指的是两次成功读操作间隔时间,而不是发送整个请求体的超时时间;
    + 如果再此超时时间内客户端没有发送任何请求体,则响应`408(Request Time-out)`
  + `send_timeout time` : 设置发送响应到客户端的超时时间,默认为`60s`;
    + 此超时时间指的也是两次成功写操作间隔时间,而不是发送整个响应的超时时间.
    + 如果在此超时时间内客户端没有接收任何响应,则`Nginx`关闭此连接;
  + `keepalive_timeout timeout [header_timeout]` : 设置`HTTP`长连接超时时间.

+ `DNS解析超时设置`
  + `resolver_timeout 30s` : 设置`DNS`解析超时时间,默认为`30s`.

+ `代理超时设置`

### `Twemproxy`

`Twemproxy`是`Twitter`开源的`Redis`和`Memcache`代理中间件,其目的是减少与后端缓存服务器的连接数;

+ `timeout` : 表示与后端服务器建立连接,接收响应的超时时间,默认永不超时;
+ `server_retry_timeout`和`server_failure_limit`:
  + 当开启`auto_eject_hosts`,即当后端服务器不可用时自动摘除这些节点并在一定时间后进行重试;
  + `server_failure_limit` : 设置连续失败多少次后将节点临时摘除;
  + `server_retry_timeout` : 设置摘除节点后等待多久进行重试,从而保证不永久性地将节点摘除;

## `Web容器超时`

现在大部分`Web容器`都是`Tomcat`:

+ `connectionTimeout` : 配置与客户端建立连接的超时时间,从接收到连接后,在配置的时间内没有接收到客户端请求行,将被认定为连接超时,默认为`60s` 
+ `socket.soTimeout` : 从客户端读取请求数据的超时时间,默认同`connectionTimeout`,`NIO`和`NIO2`支持该配置;
+ `asyncTimeout` : `Servlet3`异步请求的超时时间,默认`30s` 
+ `disableUploadTimeout`和`connectionUploadTimeout` : 当配置`disableUploadTimeout`为`false`时,文件上传将使用`connectionUploadTimeout`作为超时时间; 
+ `keepAliveTimeout`和`maxKeepAliveRequests` : 和`Nginx`配置类似;
  + `keepAliveTimeout`默认为`connectionTimeout`,配置为`-1`表示永不超时;
  + `maxKeepAliveRequests`默认为`100`; 


## `业务超时`

+ `任务型` : 
  + 可以通过`Worker`定期扫描数据库修改状态;
  + 需要调用的远程服务超时了,可以考虑使用队列或者暂时记录到本地稍后重试;
+ `服务调用型`:
  + 每处服务调用的超时时间可能不一样,可以简单地使用`Future`来解决问题;

