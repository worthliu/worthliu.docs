## 协议

`dubbo`中,对于远程调用请求访问提供协议封装转发;

其提供的`Protocol`接口定义,默认实现的协议为`dubbo`;

```
@SPI("dubbo")
public interface Protocol {

     // 默认端口
    int getDefaultPort();

    /**
     * 远程调用服务出口
     * 1. 接收到请求时,协议需记录请求方地址
     * 2. export()具备幂等性
     * 3. invoker对象由框架级别传入,协议层无须关注
     */
    @Adaptive
    <T> Exporter<T> export(Invoker<T> invoker) throws RpcException;

    /**
     * 远程调用服务相关
     */
    @Adaptive
    <T> Invoker<T> refer(Class<T> type, URL url) throws RpcException;

    /**
     * 回收协议对象,回收此协议对象所有export和refers,回收相关的资源.即使回收也可重新创建一个服务
     */
    void destroy();

}
```

`dubbo`框架中提供四种协议类型:
+ `RedisProtocol`  : Redis协议
+ `DubboProtocol` : Dubbo协议
+ `InjvmProtocol` : JVM内部协议
+ `MemcachedProtocol` : Memcached协议

### `RedisProtocol`

```RedisProtocol
	public <T> Invoker<T> refer(final Class<T> type, final URL url) throws RpcException {
        try {
            GenericObjectPoolConfig config = new GenericObjectPoolConfig();
            config.setTestOnBorrow(url.getParameter("test.on.borrow", true));
            config.setTestOnReturn(url.getParameter("test.on.return", false));
            config.setTestWhileIdle(url.getParameter("test.while.idle", false));
            if (url.getParameter("max.idle", 0) > 0) {
                config.setMaxIdle(url.getParameter("max.idle", 0));
            }
            if (url.getParameter("min.idle", 0) > 0) {
                config.setMinIdle(url.getParameter("min.idle", 0));
            }
            if (url.getParameter("max.active", 0) > 0) {
                config.setMaxTotal(url.getParameter("max.active", 0));
            }
            if (url.getParameter("max.total", 0) > 0) {
                config.setMaxTotal(url.getParameter("max.total", 0));
            }
            if (url.getParameter("max.wait", 0) > 0) {
                config.setMaxWaitMillis(url.getParameter("max.wait", 0));
            }
            if (url.getParameter("num.tests.per.eviction.run", 0) > 0) {
                config.setNumTestsPerEvictionRun(url.getParameter("num.tests.per.eviction.run", 0));
            }
            if (url.getParameter("time.between.eviction.runs.millis", 0) > 0) {
                config.setTimeBetweenEvictionRunsMillis(url.getParameter("time.between.eviction.runs.millis", 0));
            }
            if (url.getParameter("min.evictable.idle.time.millis", 0) > 0) {
                config.setMinEvictableIdleTimeMillis(url.getParameter("min.evictable.idle.time.millis", 0));
            }
            final JedisPool jedisPool = new JedisPool(config, url.getHost(), url.getPort(DEFAULT_PORT),
                    url.getParameter(TIMEOUT_KEY, DEFAULT_TIMEOUT),
                    StringUtils.isBlank(url.getPassword()) ? null : url.getPassword(),
                    url.getParameter("db.index", 0));
            final int expiry = url.getParameter("expiry", 0);
            final String get = url.getParameter("get", "get");
            final String set = url.getParameter("set", Map.class.equals(type) ? "put" : "set");
            final String delete = url.getParameter("delete", Map.class.equals(type) ? "remove" : "delete");
            return new AbstractInvoker<T>(type, url) {
                @Override
                protected Result doInvoke(Invocation invocation) throws Throwable {
                    Jedis jedis = null;
                    try {
                        jedis = jedisPool.getResource();

                        if (get.equals(invocation.getMethodName())) {
                            if (invocation.getArguments().length != 1) {
                                throw new IllegalArgumentException("The redis get method arguments mismatch, must only one arguments. interface: " + type.getName() + ", method: " + invocation.getMethodName() + ", url: " + url);
                            }
                            byte[] value = jedis.get(String.valueOf(invocation.getArguments()[0]).getBytes());
                            if (value == null) {
                                return new RpcResult();
                            }
                            ObjectInput oin = getSerialization(url).deserialize(url, new ByteArrayInputStream(value));
                            return new RpcResult(oin.readObject());
                        } else if (set.equals(invocation.getMethodName())) {
                            if (invocation.getArguments().length != 2) {
                                throw new IllegalArgumentException("The redis set method arguments mismatch, must be two arguments. interface: " + type.getName() + ", method: " + invocation.getMethodName() + ", url: " + url);
                            }
                            byte[] key = String.valueOf(invocation.getArguments()[0]).getBytes();
                            ByteArrayOutputStream output = new ByteArrayOutputStream();
                            ObjectOutput value = getSerialization(url).serialize(url, output);
                            value.writeObject(invocation.getArguments()[1]);
                            jedis.set(key, output.toByteArray());
                            if (expiry > 1000) {
                                jedis.expire(key, expiry / 1000);
                            }
                            return new RpcResult();
                        } else if (delete.equals(invocation.getMethodName())) {
                            if (invocation.getArguments().length != 1) {
                                throw new IllegalArgumentException("The redis delete method arguments mismatch, must only one arguments. interface: " + type.getName() + ", method: " + invocation.getMethodName() + ", url: " + url);
                            }
                            jedis.del(String.valueOf(invocation.getArguments()[0]).getBytes());
                            return new RpcResult();
                        } else {
                            throw new UnsupportedOperationException("Unsupported method " + invocation.getMethodName() + " in redis service.");
                        }
                    } catch (Throwable t) {
                        RpcException re = new RpcException("Failed to invoke redis service method. interface: " + type.getName() + ", method: " + invocation.getMethodName() + ", url: " + url + ", cause: " + t.getMessage(), t);
                        if (t instanceof TimeoutException || t instanceof SocketTimeoutException) {
                            re.setCode(RpcException.TIMEOUT_EXCEPTION);
                        } else if (t instanceof JedisConnectionException || t instanceof IOException) {
                            re.setCode(RpcException.NETWORK_EXCEPTION);
                        } else if (t instanceof JedisDataException) {
                            re.setCode(RpcException.SERIALIZATION_EXCEPTION);
                        }
                        throw re;
                    } finally {
                        if (jedis != null) {
                            try {
                                jedis.close();
                            } catch (Throwable t) {
                                logger.warn("returnResource error: " + t.getMessage(), t);
                            }
                        }
                    }
                }

                @Override
                public void destroy() {
                    super.destroy();
                    try {
                        jedisPool.destroy();
                    } catch (Throwable e) {
                        logger.warn(e.getMessage(), e);
                    }
                }
            };
        } catch (Throwable t) {
            throw new RpcException("Failed to refer redis service. interface: " + type.getName() + ", url: " + url + ", cause: " + t.getMessage(), t);
        }
    }
```

`Redis`通过`jedisPool`连接池形式建立请求连接;

### `DubboProtocol`

```
	public <T> Exporter<T> export(Invoker<T> invoker) throws RpcException {
        URL url = invoker.getUrl();

        // export service.
        String key = serviceKey(url);
        DubboExporter<T> exporter = new DubboExporter<T>(invoker, key, exporterMap);
        exporterMap.put(key, exporter);

        //export an stub service for dispatching event
        Boolean isStubSupportEvent = url.getParameter(Constants.STUB_EVENT_KEY, Constants.DEFAULT_STUB_EVENT);
        Boolean isCallbackservice = url.getParameter(Constants.IS_CALLBACK_SERVICE, false);
        if (isStubSupportEvent && !isCallbackservice) {
            String stubServiceMethods = url.getParameter(Constants.STUB_EVENT_METHODS_KEY);
            if (stubServiceMethods == null || stubServiceMethods.length() == 0) {
                if (logger.isWarnEnabled()) {
                    logger.warn(new IllegalStateException("consumer [" + url.getParameter(INTERFACE_KEY) +
                            "], has set stubproxy support event ,but no stub methods founded."));
                }

            } else {
                stubServiceMethodsMap.put(url.getServiceKey(), stubServiceMethods);
            }
        }

        openServer(url);
        optimizeSerialization(url);

        return exporter;
    }
```

### `InjvmProtocol`

```
	public <T> Exporter<T> export(Invoker<T> invoker) throws RpcException {
        return new InjvmExporter<T>(invoker, invoker.getUrl().getServiceKey(), exporterMap);
    }
```

### `MemcachedProtocol`

```
	public <T> Exporter<T> export(final Invoker<T> invoker) throws RpcException {
        throw new UnsupportedOperationException("Unsupported export memcached service. url: " + invoker.getUrl());
    }
```
