# kong.client

> 本文原文链接：https://docs.konghq.com/1.1.x/pdk/kong.client/

客户信息模块一组函数，用于查询在给定请求的上下文中连接到Kong的客户端的信息。

另见：[nginx.org/en/docs/http/ngx_http_realip_module.html](http://nginx.org/en/docs/http/ngx_http_realip_module.html)

## kong.client.get_ip()

返回发出请求的客户端的远程地址。将始终返回直接连接到Kong的客户端的地址。也就是说，在负载均衡器位于Kong前面的情况下，此函数将返回负载均衡器的地址，而不是下游客户端的地址。

- 阶段
	- certificate, rewrite, access, header_filter, body_filter, log
- 返回
	- `string`ip发出请求的客户端的远程地址
- 用法
	```
    -- 给定一个IP 127.0.0.1的客户机，通过一个IP 10.0.0.1的负载均衡器连接到Kong，以响应
	-- https://example.com:1234/v1/movies
	kong.client.get_ip() -- "10.0.0.1"
    ```

## kong.client.get_forwarded_ip()

返回发出请求的客户端的远程地址。不同于`kong.client.get_ip`，当负载均衡器位于Kong前面时，此方法将考虑转发地址。此函数是否返回转发地址取决于多个Kong配置参数：

[trusted_ips](https://getkong.org/docs/latest/configuration/#trusted_ips)  
[real_ip_header](https://getkong.org/docs/latest/configuration/#real_ip_header)  
[real_ip_recursive](https://getkong.org/docs/latest/configuration/#real_ip_recursive)  

- 阶段
	- certificate, rewrite, access, header_filter, body_filter, log
- 返回
	- `string`ip发出请求的客户端的远程地址，考虑转发的地址
- 用法
	```
    -- 假设一个IP为127.0.0.1的客户机通过一个IP为10.0.0.1的负载均衡器连接到Kong，响应		
    --https://username:password@example.com:1234/v1/movies的请求
    
	kong.request.get_forwarded_ip() -- "127.0.0.1"
    
    -- 提示：假设10.0.0.1是受信任的ip之一，
    -- 并且负载均衡器添加了与“real_ip_header”配置匹配的正确头文件，例如“proxy_protocol”。
    ```
## kong.client.get_port()

返回发出请求的客户端的远程端口。这将始终返回直接连接到Kong的客户端口。也就是说，在负载均衡器位于Kong前面的情况下，此功能将返回负载均衡器的端口，而不是下游客户端的端口。

- 阶段
	- certificate, rewrite, access, header_filter, body_filter, log
- 返回
	- `number`远程客户端端口
- 用法
	```
    -- [client]:40000 <-> 80:[balancer]:30000 <-> 80:[kong]:20000 <-> 80:[service]
	kong.client.get_port() -- 30000
    ```

## kong.client.get_forwarded_port()

返回发出请求的客户端的远程端口。不同于`kong.client.get_port`，当负载均衡器位于Kong前面时，此功能将考虑转发端口。
此函数是否返回转发端口取决于多个Kong配置参数：

[trusted_ips](https://getkong.org/docs/latest/configuration/#trusted_ips)  
[real_ip_header](https://getkong.org/docs/latest/configuration/#real_ip_header)  
[real_ip_recursive](https://getkong.org/docs/latest/configuration/#real_ip_recursive)  

- 阶段
	- certificate, rewrite, access, header_filter, body_filter, log
- 返回
	- `number`远程客户端端口,考虑转发端口
- 用法
	```
    -- [client]:40000 <-> 80:[balancer]:30000 <-> 80:[kong]:20000 <-> 80:[service]
kong.client.get_forwarded_port() -- 40000
    -- 注意:假设[balancer]是受信任的ip之一，并且负载均衡器添加了与' real_ip_header '配置匹配的正确头文件，例如。“proxy_protocol”。
    ```

## kong.client.get_credential()

返回当前经过身份验证的使用者的凭据。如果尚未设置，则返回`nil`。

- 阶段
	- access, header_filter, body_filter, log
- 返回
	- 经过身份验证的凭据
- 用法
	```
    local credential = kong.client.get_credential()
    if credential then
      consumer_id = credential.consumer_id
    else
      -- 请求尚未通过身份验证
    end
    ```

## kong.client.get_consumer()

返回当前经过身份验证的使用者的`consumer`。如果尚未设置，则返回`nil`。

- 阶段
	- access, header_filter, body_filter, log
- 返回
	- `table`经过身份验证的消费者实体
- 用法
	```
    local consumer = kong.client.get_consumer()
    if consumer then
      consumer_id = consumer.id
    else
      -- 尚未验证的请求，或没有使用者的凭据(外部验证)
    end
    ```

## kong.client.authenticate(consumer, credential)

为当前请求设置经过身份验证的 consumer and/or credential。虽然`consumer`和`credential`都可以是`nil`，但要求至少存在其中一个。否则此函数将抛出错误。

- 阶段
	- access
- 参数
	- **consumer**(table|nil) :经过身份验证的消费者实体
	- **credential**(table|nil) :要设置的凭据。注意：如果未提供任何值，则将清除任何现有值！
- 用法
	```
    -- 假设某些身份验证代码设置了`credential`和`consumer`
    kong.client.authenticate(consumer, credentials)
    ```

## kong.client.get_subsystem()

返回客户端使用的Nginx子系统。它可以是“http”或“stream”

- 阶段
	- access, header_filter, body_filter, log
- 返回
	- `string` 一个带有“http”或“stream”的字符串
- 用法
	```
    kong.client.get_subsystem() -- "http"
    ```

## _CLIENT.get_protocol(allow_terminated)

- 阶段
	- access, header_filter, body_filter, log
- 参数
	- allow_terminated[opt]:boolean.如果设置，则在检查https时将检查 `X-Forwarded-Proto` 的请求头
- 返回
	1. `string|nil`，`"http"`，`"https"`，`"tcp"`，`"tls"` 如果失败就返回`nil`
	2. `nil|err`发生故障时的错误消息。否则`nil`
- 用法
	```
    kong.client.get_protocol() -- "http"
    ```








