# Zipkin 插件

> 本文原文链接：https://docs.konghq.com/hub/kong-inc/zipkin/

传播Zipkin分布式跟踪跨度，并向Zipkin服务器报告跨度。

> 注意：此插件的功能与0.14.1之前的Kong版本和0.34之前的Kong Enterprise版本捆绑在一起，与此处记录的不同。
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
- `tcp`
- `tls`

此插件与无DB模式兼容。

## 在 Service 上启用插件

**使用数据库：**

通过发出以下请求在Service上配置此插件：
```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=zipkin"  \
    --data "config.http_endpoint=http://your.zipkin.collector:9411/api/v2/spans" \
    --data "config.sample_ratio=0.001"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: zipkin
  service: {service}
  config: 
    http_endpoint: http://your.zipkin.collector:9411/api/v2/spans
    sample_ratio: 0.001
```
在这两种情况下，`{service}`是此插件配置将定位的Service的`id`或`name`。

## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=zipkin"  \
    --data "config.http_endpoint=http://your.zipkin.collector:9411/api/v2/spans" \
    --data "config.sample_ratio=0.001"
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: zipkin
  route: {route}
  config: 
    http_endpoint: http://your.zipkin.collector:9411/api/v2/spans
    sample_ratio: 0.001
```

在这两种情况下，`{route}`是此插件配置将定位的`Route`的`ID`或名称。


## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=zipkin" \
     \
    --data "config.http_endpoint=http://your.zipkin.collector:9411/api/v2/spans" \
    --data "config.sample_ratio=0.001"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: zipkin
  consumer: {consumer}
  config: 
    http_endpoint: http://your.zipkin.collector:9411/api/v2/spans
    sample_ratio: 0.001
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
| `config.http_endpoint` <br> *optional* |  `127.0.0.1` | Zipkin跨度的完整HTTP端点应该由Kong发送到该端点。 |
| `config.sample_ratio` <br> *optional* | `0.001` | 对不包含跟踪ID的请求进行采样的频率。设置为`0`以关闭采样，或设置为`1`以采样所有请求。  |

## 它是怎么工作的

启用后，此插件以与[zipkin](https://zipkin.io/)兼容的方式跟踪请求。

代码围绕一个[opentracing](http://opentracing.io/)核心构建，使用[opentracing-lua](https://github.com/Kong/opentracing-lua)库来收集每个Kong阶段的请求的时间数据。该插件使用opentracing-lua兼容的提取器、注入器和报告器来实现Zipkin的协议。

## 提取器和注入器

打开追踪“提取器”从传入的请求中收集信息。如果传入请求中不存在跟踪ID，则基于`sample_ratio`配置值概率地生成一个跟踪ID。

打开追踪“注入器”将跟踪信息添加到传出请求中。目前，仅对kong代理的请求调用注入器;它尚未用于对数据库或其他插件（例如http-log插件）的请求。

## 报告

操作员“Reporter”是如何将跟踪数据报告给另一个系统的。此插件记录给定请求的跟踪数据，并使用[Zipkin v2 API](https://zipkin.io/zipkin-api/#/default/post_spans)将其作为批处理发送到Zipkin服务器。请注意，需要zipkin 1.31或更高版本。

`http_endpoint`配置变量必须包含完整的uri，包括scheme，host，port和path部分（即你的uri可能以`/api/v2/spans`结尾）。

## FAQ

**我可以将此插件与类似Jaeger等其他跟踪系统一起使用吗？**

大概！
Jaeger接受Zipkin格式的跨度 - 请参阅https://www.jaegertracing.io/docs/features/#backwards-compatibility-with-zipkin 查看更多信息。

