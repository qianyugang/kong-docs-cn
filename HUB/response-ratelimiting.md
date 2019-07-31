# Response Rate Limiting 响应率限制插件

此插件允许您根据上游服务返回的自定义响应头限制开发人员可以发出的请求数。您可以根据需要随意设置任意数量的限速对象（或配额），并指示Kong按任意数量的单位增加或减少它们。每个自定义速率限制对象可以限制每秒，分钟，小时，天，月或年的入站请求。

如果底层 Service/Route（或已弃用的API实体）没有身份验证层，则将使用客户端IP地址，否则，如果已配置身份验证插件，则将使用Consumer。


> 注意：此插件的功能与0.13.1之前的Kong版本和0.32之前的Kong Enterprise版本捆绑在一起，与此处记录的不同。
有关详细信息，请参阅[CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md)。

## 术语

- `plugin`: 在请求被代理到上游API之前或之后，在Kong内部执行操作的插件。
- `Service`: 表示外部 *upstream* API或微服务的Kong实体。
- `Route`: 表示将下游请求映射到上游服务的方法的Kong实体。
- `Consumer`: 代表使用API的开发人员或机器的Kong实体。当使用Kong时，Consumer 仅与Kong通信，其代理对所述上游API的每次调用。
- `Credential`: 与Consumer关联的唯一字符串，也称为API密钥。
- `upstream service`: 这是指位于Kong后面的您自己的 API/service，转发客户端请求。
- `api`：用于表示上游服务的遗留实体。自CE 0.13.0和EE 0.32被弃用。

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
    --data "name=response-ratelimiting"  \
    --data "config.limits.{limit_name}=" \
    --data "config.limits.{limit_name}.minute=10"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: response-ratelimiting
  service: {service}
  config: 
    limits.{limit_name}: 
    limits.{limit_name}.minute: 10
```
在这两种情况下，`{service}`都是此插件配置将定位的服务的`id`或`name`。

## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=response-ratelimiting"  \
    --data "config.limits.{limit_name}=" \
    --data "config.limits.{limit_name}.minute=10"
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: response-ratelimiting
  route: {route}
  config: 
    limits.{limit_name}: 
    limits.{limit_name}.minute: 10
```
在这两种情况下，`{route}`是此插件配置将定位的`Route`的`ID`或名称。

## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=request-size-limiting" \
     \
    --data "config.allowed_payload_size=128"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: response-ratelimiting
  consumer: {consumer}
  config: 
    limits.{limit_name}: 
    limits.{limit_name}.minute: 10
```
在这两种情况下，`{consumer`}都是此插件配置将定位的`Consumer`的`id`或`username`。  
您可以组合`consumer_id`和`service_id` 。 
在同一个请求中，进一步缩小插件的范围。

## 在 API 上启用插件

如果您使用旧版本的Kong与旧版API实体（自CE 0.13.0和EE 0.32弃用。），您可以通过发出以下请求在此类API之上配置此插件：
```
$ curl -X POST http://kong:8001/apis/{api}/plugins \
    --data "name=response-ratelimiting"  \
    --data "config.limits.{limit_name}=" \
    --data "config.limits.{limit_name}.minute=10"
```

- `api`：此插件配置将定位的API的ID或名称。

## 全局插件

- **使用数据库：** 可以使用`http://kong:8001/plugins/`配置所有插件。
- **不使用数据库：** 可以通过`plugins: `配置所有插件：声明性配置文件中的条目。

与任何 Service ，Route 或 Consumer （或API，如果您使用旧版本的Kong）无关的插件被视为“全局”，并将在每个请求上运行。有关更多信息，请阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分。

## 参数

以下是可在此插件配置中使用的所有参数的列表：

| 参数 | 默认值 | 描述 |
| ---- | ------ | ---- |
| `name` |  |  要使用的插件的名称，在本例中为`response-ratelimiting`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `consumer_id` |  | 此插件将定位的Consumer的id  |
| `api_id` | | 此插件将定位的API的ID。注意：自CE 0.13.0和EE 0.32以来，不推荐使用API​​实体来支持服务。 | 
| `config.limits.{limit_name}` <br> *semi-optional* |  | 开发人员每秒可以发出的HTTP请求数量，必须至少存在一个限制。|
| `config.limits.{limit_name}.second` <br> *semi-optional* |  | 开发人员每秒可以发出的HTTP请求数量，必须至少存在一个限制。|
| `config.limits.{limit_name}.minute` <br> *semi-optional* |  | 开发人员每分钟可以发出的HTTP请求数量，必须至少存在一个限制。|
| `config.limits.{limit_name}.hour` <br> *semi-optional* |  | 开发人员每小时可以发出的HTTP请求数量，必须至少存在一个限制。|
| `config.limits.{limit_name}.day` <br> *semi-optional* |  | 开发人员每天可以发出的HTTP请求数量，必须至少存在一个限制。|
| `config.limits.{limit_name}.month` <br> *semi-optional* |  | 开发人员每月可以发出的HTTP请求数量，必须至少存在一个限制。|
| `config.limits.{limit_name}.year` <br> *semi-optional* |  | 开发人员每年可以发出的HTTP请求数量，必须至少存在一个限制。|
| `config.header_name` <br> *optional* | `X-Kong-Limit` | 用于递增计数器的响应头的名称　|
| `config.block_on_first_violation` <br> *optional* | `false` | 用于递增计数器的响应头的名称　|
| `config.limit_by` <br> *optional* | `consumer` | 聚合限制时将使用的实体：`consumer`, `credential`, `ip`。如果无法确定`consumer`或`credential`，系统将始终回退到`ip`。 |
| `config.policy` <br> *optional* | `cluster` | 用于检索和增加限制的速率限制策略。可用值是:<br>`local`（计数器将存储在节点上的本地内存中），<br> `cluster`（计数器存储在数据存储区中并在节点之间共享）<br>`redis`（计数器存储在Redis服务器上并将在节点之间共享）　|
| `config.fault_tolerant` <br> *optional* | `true` |  一个布尔值，用于确定是否应该代理请求，即使Kong在连接第三方数据存储区时遇到问题。如果`true`请求将被代理，则无论如何都会有效地禁用速率限制功能，直到数据存储再次工作。
如果为`false`，则客户端将看到500个错误。　|
| `config.hide_client_headers` <br> *optional* | `false` | 可选）隐藏信息响应 header |
| `config.redis_host` <br> *optional* |  | 使用`redis`策略时，此属性指定Redis服务器的地址。　|
| `config.redis_port` <br> *optional* | `6379` | 使用`redis`策略时，此属性指定Redis服务器的端口。　|
| `config.redis_password` <br> *optional* | `true` | 使用`redis`策略时，此属性指定连接到Redis服务器的密码。　|
| `config.redis_timeout` <br> *optional* | `2000` | 使用`redis`策略时，此属性指定提交给Redis服务器的任何命令的超时（以毫秒为单位）。　|
| `config.redis_database` <br> *optional* | `0` | 使用`redis`策略时，此属性指定要使用的Redis数据库。　|

## 配置额度

添加插件后，您可以通过添加以下响应标头来增加配置的限制：
```
Header-Name: Limit=Value [,Limit=Value]
```
由于`X-Kong-Limit`是默认的header名（您可以选择更改它），它看起来像：
```
X-Kong-Limit: limitname1=2, limitname2=4
```
这将限制`limitname1`增加2个单位，`limitname2`增加4个单位。

您可以选择通过逗号分隔条目来增加多个限制。
在将响应返回给原始客户端之前，将删除header。

## Headers 发送给客户端

启用此插件后，Kong会向客户端发送一些额外的 headers，告知可用的单元数量和允许的数量。
例如，如果您创建了一个名为“视频”的限制/配额，每分钟限制：
```
X-RateLimit-Limit-Videos-Minute: 10
X-RateLimit-Remaining-Videos-Minute: 9
```
或者，如果设置了多个时间限制，它将返回更多时间限制的组合：
```
X-RateLimit-Limit-Videos-Second: 5
X-RateLimit-Remaining-Videos-Second: 5
X-RateLimit-Limit-Videos-Minute: 10
X-RateLimit-Remaining-Videos-Minute: 10
```

如果达到任何配置的限制，插件将返回`HTTP/1.1 429`状态代码和空体。

## 上游 Headers

在将代理转发到上游服务之前，插件将附加每个限制的使用 headers，以便在没有剩余限制时可以正确拒绝处理请求。
标题采用`X-RateLimit-Remaining- {limit_name}`的形式，如：
```
X-RateLimit-Remaining-Videos: 3
X-RateLimit-Remaining-Images: 0
```










