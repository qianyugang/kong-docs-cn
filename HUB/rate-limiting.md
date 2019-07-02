# 速率限制

速率限制插件就是限定了开发人员在给定的秒，分钟，小时，天，月或年中可以进行的HTTP请求数。如果底层  Service/Route （或已弃用的API实体）没有身份验证层，则将使用Client IP地址，否则，如果已配置身份验证插件，则将使用Consumer。

> 注意：此插件的功能与0.13.1之前的Kong版本和0.32之前的Kong Enterprise版本捆绑在一起，与此处记录的不同。
有关详细信息，请参阅[CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md)。

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

此插件与无DB模式部分兼容。

该插件将使用`local`策略（不使用数据库）或`redis`策略（使用独立的Redis，因此它与无DB的兼容）运行良好。该插件不适用于`cluster`策略，该策略需要写入数据库。

## 在 Service 上启用插件

通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=rate-limiting"  \
    --data "config.second=5" \
    --data "config.hour=10000"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: rate-limiting
  service: {service}
  config: 
    second: 5
    hour: 10000
```
在这两种情况下，`{service}`都是此插件配置将定位的服务的`id`或`name`。

## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=rate-limiting"  \
    --data "config.second=5" \
    --data "config.hour=10000"
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: rate-limiting
  route: {route}
  config: 
    second: 5
    hour: 10000
```

在这两种情况下，`{route}`是此插件配置将定位的`Route`的`ID`或名称。

在这两种情况下，`{route}`是此插件配置将定位的`Route`的`ID`或名称。

## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=rate-limiting" \
     \
    --data "config.second=5" \
    --data "config.hour=10000"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: rate-limiting
  consumer: {consumer}
  config: 
    second: 5
    hour: 10000
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
| `config.second` <br> *semi-optional* | | 每秒可以发出的HTTP请求数量。必须至少存在一个限制参数。 |
| `config.minute` <br> *semi-optional* | | 每分钟可以发出的HTTP请求数量。必须至少存在一个限制参数。 |
| `config.hour` <br> *semi-optional* | | 每小时可以发出的HTTP请求数量。必须至少存在一个限制参数。 |
| `config.day` <br> *semi-optional* | | 每天可以发出的HTTP请求数量。必须至少存在一个限制参数。 |
| `config.month` <br> *semi-optional* | | 每月可以发出的HTTP请求数量。必须至少存在一个限制参数。 |
| `config.year` <br> *semi-optional* | | 每年可以发出的HTTP请求数量。必须至少存在一个限制参数。 |
| `config.limit_by` <br> *optional* | `consumer` | 聚合限制时将使用的实体:`consumer`, `credential`, `ip`。<br>如果无法确定`consumer`或`credential` ，系统将始终回退到`ip`。 |
| `config.policy` <br> *optional* | `cluster` |  用于检索和增加限制的速率限制策略。 可用值是`local`（计数器将存储在节点上的本地内存中），`cluster`（计数器存储在数据存储区中并在节点之间共享）和`redis`（计数器存储在Redis服务器上，并将在节点之间共享）。| 
| `config.fault_tolerant` <br> *optional* | `true` | 一个布尔值，用于确定是否应该代理请求，即使Kong在连接第三方数据存储区时遇到问题。如果真正的请求将被代理，则无论如何都会有效地禁用速率限制功能，直到数据存储再次工作。如果为`false`，则客户端将看到`500`错误。 | 
| `config.hide_client_headers` <br> *optional* | `false` | （可选）隐藏信息响应header。  | 
| `config.redis_host` <br> *optional* |  | 使用redis策略时，此属性指定Redis服务器的地址。 | 
| `config.redis_port` <br> *optional* | `6379` | 使用redis策略时，此属性指定Redis服务器的端口。默认为6379。 | 
| `config.redis_password` <br> *optional* |  | 使用redis策略时，此属性指定连接到Redis服务器的密码。 | 
| `config.redis_timeout` <br> *optional* | `2000` | 使用`redis`策略时，此属性指定提交给Redis服务器的任何命令的超时（以毫秒为单位）。 | 
| `config.redis_database` <br> *optional* | `0` | 使用redis策略时，此属性指定要使用的Redis数据库。 | 


## 给客户端发送headers

## 实施注意事项

## 每笔交易都很重要

## 后端保护













