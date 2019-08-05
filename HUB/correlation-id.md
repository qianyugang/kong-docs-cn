# Correlation ID 关联 ID插件

使用通过HTTP header 传输的唯一ID关联请求和响应。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `Route`: 表示将下游请求映射到上游服务的方法的Kong实体。
- `Consumer`: 代表使用API的开发人员或机器的Kong实体。当使用Kong时，Consumer 仅与Kong通信，其代理对所述上游API的每次调用。
- `Credential`: 与Consumer关联的唯一字符串，也称为API密钥。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。

## 配置

此插件与具有以下协议的请求兼容：

- `http`
- `https`

此插件与无DB模式兼容。

## 在 Service 上启用插件

**使用数据库：**

通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=correlation-id"  \
    --data "config.header_name=Kong-Request-ID" \
    --data "config.generator=uuid#counter" \
    --data "config.echo_downstream=false"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: correlation-id
  route: {route}
  config: 
    header_name: Kong-Request-ID
    generator: uuid#counter
    echo_downstream: false
```
在这两种情况下，`{service}`是此插件配置将定位的`Route`的`ID`或名称。

## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=correlation-id"  \
    --data "config.header_name=Kong-Request-ID" \
    --data "config.generator=uuid#counter" \
    --data "config.echo_downstream=false"
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: correlation-id
  route: {route}
  config: 
    header_name: Kong-Request-ID
    generator: uuid#counter
    echo_downstream: false
```

在这两种情况下，`{route}`是此插件配置将定位的Route的`id`或`name`。


## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=correlation-id" \
     \
    --data "config.header_name=Kong-Request-ID" \
    --data "config.generator=uuid#counter" \
    --data "config.echo_downstream=false"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: correlation-id
  consumer: {consumer}
  config: 
    header_name: Kong-Request-ID
    generator: uuid#counter
    echo_downstream: false
```
在这两种情况下，`{consumer`}都是此插件配置将定位的`Consumer`的`id`或`username`。  
您可以组合`consumer_id`和`service_id` 。 
在同一个请求中，进一步缩小插件的范围。

## 全局插件

- **使用数据库：**可以使用`http://kong:8001/plugins/`配置所有插件。
- **不使用数据库：**可以通过`plugins: `配置所有插件：声明性配置文件中的条目。

与任何 Service ，Route 或 Consumer （或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。

## 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `name` |  |  要使用的插件的名称，在本例中为`ip-restriction`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `consumer_id` |  | 此插件将定位的Consumer的id  |
| `config.header_name` <br> *optional* | `Kong-Request-ID` | 用于关联ID的HTTP header 名称。 |
| `config.generator` <br> *optional* | `uuid#counter` |用于相关ID的生成器。接受的值是`uuid`，`uuid#counter`和`tracker`参见[Generators](https://docs.konghq.com/hub/kong-inc/correlation-id/#generators)。 | 
| `config.echo_downstream` <br> *optional* | `false` | 是否将header回送到下游（客户端）。|

## 工作原理

启用后，此插件将为Kong处理的所有请求添加新header。此header带有`config.header_name`中配置的名称，以及根据`config.generator`生成的唯一值。

此header始终添加到对上游服务的调用中，并根据`config.echo_downstream`设置选择性地回显给您的客户端。

如果客户端请求中已经存在具有相同名称的header，则会遵守该header，并且此插件不会对其进行更改。

## 生成器

### uuid
格式：
```
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```
使用此格式，为每个请求以十六进制形式生成UUID。


### uuid#counter
格式：
```
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx#counter
```

在这种格式中，基于每个工作者生成单个UUID，并且进一步的请求仅在`#`字符之后将计数器附加到UUID。
每个工人的`counter`值从`0`开始，并且独立于其他工人增加。

这种格式提供了更好的性能，但可能更难以存储或处理分析（由于其格式和低基数）。

### tracker
格式：
```
ip-port-pid-connection-connection_requests-timestamp
```

在这种格式中，相关id包含对每个请求更实际的含义。

以下是该字段的详细说明：

| 参数 | 描述 |
| --- | ---- |
| `ip` | 接受请求的服务器的地址 | 
| `port` | 接受请求的服务器的端口 | 
| `pid` | nginx工作进程的pid | 
| `connection` | 连接序列号 | 
| `connection_requests` | 当前通过连接发出的请求数 | 
| `timestamp` | 从nginx缓存时间开始的当前时间戳的的经过时间（以秒为单位）（包括作为小数部分的毫秒）的浮点数 | 

## 常见问题

### 可以在Kong日志中看到关联ID吗？

相关ID不会显示在Nginx访问或错误日志中。
因此，我们建议您将此插件与其中一个Logging插件一起使用，或将此ID存储在您的后端。






