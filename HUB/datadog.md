# Datadog 插件

记录Service的指标，Route到本地[Datadog](https://docs.datadoghq.com/agent/basic_agent_usage/?tab=chefcookbook)代理。

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

此插件与无DB模式兼容。

## 在 Service 上启用插件

**使用数据库：**

通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=datadog"  \
    --data "config.host=127.0.0.1" \
    --data "config.port=8125"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: datadog
  service: {service}
  config: 
    host: 127.0.0.1
    port: 8125
```
在这两种情况下，`{service}`是此插件配置将定位的Service的`id`或`name`。

## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=datadog"  \
    --data "config.host=127.0.0.1" \
    --data "config.port=8125"
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: datadog
  route: {route}
  config: 
    host: 127.0.0.1
    port: 8125
```

在这两种情况下，`{route}`是此插件配置将定位的Route的`id`或`name`。


## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=datadog" \
     \
    --data "config.host=127.0.0.1" \
    --data "config.port=8125"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: datadog
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
| `name` |  |  要使用的插件的名称，在本例中为`datadog`  |
| `service_id` |  | 此插件将定位的 Service 的ID。|
| `route_id` |  |  此插件将定位的 Route 的ID。 |
| `enabled` |  `true` | 是否将应用此插件。  |
| `consumer_id` |  | 此插件将定位的Consumer的id  |
| `config.host` <br> *optional* |  `127.0.0.1` | 要发送数据的IP地址或主机名。 |
| `config.port` <br> *optional* | `8125` | 将数据发送到上游服务器的端口  |
| `config.metrics` <br> All metrics are logged | `8125` | 要记录的指标列表。指标中描述了可用值。  |
| `config.prefix` <br> *kong* | `8125` |要附加为指标名称前缀的字符串。  |

## 指标 Metrics

插件当前将以下指标记录到Datadog服务器有关服务或路由的指标。

| 指标 | 描述 | 命名空间 | 
| ---- | ---- | -------- |
| `request_count` | 跟踪请求 | `kong.<service_name>.request.count` | 
| `request_size` | 跟踪请求body大小（以bytes为单位）| `kong.<service_name>.request.size` |
| `response_size` | 跟踪响应body大小（以bytes为单位）| `kong.<service_name>.response.size` |
| `latency` | 跟踪请求启动和从上游服务器接收的响应之间的时间间隔 | `kong.<service_name>.latency` |
| `status_count` | 跟踪作为响应返回的每个状态代码 | `kong.<service_name>.status.<status>.count` <br> and `kong.<service_name>.status.<status>.total` |
| `unique_users` | 跟踪唯一用户提出的请求 |  `kong.<service_name>.user.uniques` | 
| `request_per_user` | 跟踪请求/用户 | `kong.<service_name>.user.<consumer_id>.count` | 
| `upstream_latency` | 跟踪最终服务处理请求所花费的时间 | `kong.<service_name>.upstream_latency` | 
| `kong_latency` | 跟踪运行所有插件所需的内部Kong延迟 | `kong.<service_name>.kong_latency` | 
| `status_count_per_user` | 跟踪请求/状态/用户 |  `kong.<service_name>.user.<customer_id>.status.<status>` <br> and `kong.<service_name>.user.<customer_id>.status.total`| 

### 指标字段

可以使用Metrics的任意组合配置插件，每个条目包含以下字段。

| 字段 | 描述 | 允许值 |
| ---- | ---- | ------ |
| `name` | Datadog指标的名称 | 	Metrics | 
| `stat_type` | 确定指标表示的事件类型 | `gauge`, `timer`, `counter`, `histogram`, `meter` and `set`  |
| `sample_rate` <br> *conditional* | 采样率 | `number` |
| `customer_identifier`  <br> *conditional*  | 经过身份验证的用户详请 | `consumer_id`, `custom_id`, `username` |
| `tags` <br> *optional* | 可选的标签列表 | `key[:value]` |

### 指标要求

1. 默认情况下，会记录所有指标。
2. 使用`stat_type`作为`counter`或`gauge`的度量标准也必须定义`sample_rate`。
3. `unique_users`指标仅适用于`set`的`stat_type`。
4. `status_count`，`status_count_per_user`和`request_per_user`仅适用于`stat_type`作为`conter`。
5. `status_count_per_user`，`request_per_user`和`unique_users`必须定义`customer_identifier`。

## Kong执行过程错误

此日志记录插件仅记录HTTP请求和响应数据。如果您正在寻找Kong执行过程错误文件（是一个nginx错误文件），那么您可以在以下路径找到它`：{prefix}/logs/error.log`



















