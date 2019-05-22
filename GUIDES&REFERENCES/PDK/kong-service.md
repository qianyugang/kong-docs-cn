# kong.service

service 模块包含一组函数来操作对service的请求的连接，例如连接到给定主机，IP地址/端口，或选择给定的 Upstream 实体以进行负载平衡和健康检查。

## kong.service.set_upstream(host)

设置所需的Upstream实体，以处理此请求的负载平衡步骤。使用此方法等效于创建主机属性等于上游实体的服务(在这种情况下，请求将被代理到与该上游相关联的目标之一)。

`host`参数应该接收一个等于当前配置的上游实体之一的字符串。

- 阶段
	- access
- 参数
	- host (string):
- 返回
	1. `boolean|nil` 如果成功返回`true`，如果如果找不到上游实体返回`nil`
	2. `string|nil` 描述错误的错误消息（如果有）。
- 用法
	```
    local ok, err = kong.service.set_upstream("service.prod")
    if not ok then
      kong.log.err(err)
      return
    end
    ```
    
## kong.service.set_target(host, port)

设置要连接的主机和端口以代理请求。使用此方法相当于要求Kong不为此请求运行负载平衡阶段，并考虑手动覆盖它。此请求也将忽略重试和健康检查等负载平衡组件。

`hos`t参数需要一个包含上游服务器（IPv4 / IPv6）IP地址的字符串，而port参数必须包含一个表示要连接到的端口的数字。

- 阶段
	- access
- 参数
	- host (string):
	- port (number):
- 用法
	```
    kong.service.set_target("service.local", 443)
	kong.service.set_target("192.168.130.1", 80)
    ```
















