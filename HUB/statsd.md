# StatsD

为  Service Route 记录日志[指标](https://docs.konghq.com/hub/kong-inc/statsd/#metrics)到一个StatsD 服务器。
通过启用它的[Statsd插件](https://collectd.org/wiki/index.php/Plugin:StatsD)，还可用于在Collected守护程序上记录指标。

> 注意：此插件的功能与0.11.0之前的Kong版本捆绑在一起，与此处记录的不同。
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
- `grpc`
- `grpcs`

此插件与无DB模式兼容。

## 在 Service 上启用插件

**使用数据库：**

通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=statsd"  \
    --data "config.host=127.0.0.1" \
    --data "config.port=8125"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: statsd
  service: {service}
  config: 
    host: 127.0.0.1
    port: 8125
```
在这两种情况下，`{service}`是此插件配置将定位的 Service 的`id`或`name`。

## 在 Route 上启用插件

**使用数据库：**

通过发出以下请求在 Route 上配置此插件：
```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=statsd"  \
    --data "config.host=127.0.0.1" \
    --data "config.port=8125"
```

**不使用数据库：**

通过添加此部分在 Route 上配置此插件执行声明性配置文件：

```
plugins:
- name: statsd
  route: {route}
  config: 
    host: 127.0.0.1
    port: 8125
```
在这两种情况下，，`{route}`是此插件配置将定位的 route 的`id`或`name`。

## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=statsd" \
     \
    --data "config.host=127.0.0.1" \
    --data "config.port=8125"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: statsd
  consumer: {consumer}
  config: 
    host: 127.0.0.1
    port: 8125
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
| `config.host` <br> *optional*  |`127.0.0.1` | 要将数据发送到的IP地址或主机名。 | 
| `config.port` <br> *optional* | `8125` | 将数据发送到上游服务器上的端口。 |
| `config.metrics` <br> *optional* | 所有被记录的指标 | 将要被记录的指标列表。可用值的描述可在[ Metrics ](https://docs.konghq.com/hub/kong-inc/statsd/#metrics)中查看。|
| `config.prefix` <br> *optional* | `kong` | 要在每个指标名称前添加字符串。 |

## 指标

插件支持登录到StatsD服务器。

| 指标 | 描述 | 命名空间 | 
| --- | ---- | ------ |
| `request_count` | 跟踪请求 | `kong.<service_name>.request.count` | 
| `request_size` | 以字节为单位跟踪请求的正文大小 | `kong.<service_name>.request.size` | 
| `response_size` | 以字节为单位跟踪响应的正文大小 | `kong.<service_name>.response.size` | 
| `latency` | 跟踪启动请求和从上游服务器收到响应之间的时间间隔  | `kong.<service_name>.latency` | 
| `status_count` | 跟踪响应中返回的每个状态代码  | `kong.<service_name>.status.<status>.count` <br> `kong.<service_name>.status.<status>.total` | 
| `unique_users` | 跟踪向基础 Service/Route 发出请求的唯一用户 | `kong.<service_name>.user.uniques` | 
| `request_per_user` | 跟踪请求/用户 | `kong.<service_name>.user.<consumer_id>.count` | 
| `upstream_latency` | 跟踪最终服务处理请求所花费的时间 | `kong.<service_name>.upstream_latency` | 
| `kong_latency` | 跟踪运行所有插件所需的内部Kong延迟 | `kong.<service_name>.kong_latency` | 
| `status_count_per_user` | 跟踪请求/状态/用户 | `kong.<service_name>.user.<customer_id>.status.<status> ` <br> `kong.<service_name>.user.<customer_id>.status.total` | 

## 指标字段

可以使用指标的任意组合来配置插件，每个条目都包含以下字段。

| 字段 | 描述 | 被允许的值 | 
| --- | ---- | -------- |
| `name` | StatsD指标的名称 | [Metrics](https://docs.konghq.com/hub/kong-inc/statsd/#metrics) |
| `stat_type` | 确定指标代表哪种事件 | `gauge`, `timer`, `counter`, `histogram`, `meter` 和 `set` |
| `sample_rate` <br> *conditional* |   采样率 | `number` | 
| `customer_identifier` <br> *conditional* | 认证的用户详细信息 | `consumer_id`, `custom_id`, `username`|

## 指标要求

1. 默认情况下，将记录所有指标。
2. `stat_type`设置为`counter`或`gauge`的时候，指标也必须定义`sample_rate`。
3. `unique_users`指标仅适用于设置为`stat_type`的情况。
4. `status_count`，`status_count_per_user`和`request_per_user`仅以`stat_type`作为计数器起作用。
5. `status_count_per_user`，`request_per_user`和`unique_users`必须定义有`customer_identifier`。

## Kong Process Errors

此日志记录插件将仅记录HTTP请求和响应数据。
如果要查找Kong进程错误文件（即nginx错误文件），则可以在以下路径中找到它：`$KONG_PREFIX/logs/error.log`，其中`$ KONG_PREFIX`表示[配置的前缀](https://docs.konghq.com/1.3.x/configuration/#prefix)。

status_count_per_user，request_per_user和unique_users必须定义有customer_identifier。















