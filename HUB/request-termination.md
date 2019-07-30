# Request Termination 请求终止插件

> 本文原文链接：https://docs.konghq.com/hub/kong-inc/request-termination/

此插件使用指定的状态代码和消息终止传入请求。这允许（暂时）停止 Service 或 Route 上的流量，甚至阻止 Consumer。

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
    --data "name=request-termination"  \
    --data "config.status_code=403" \
    --data "config.message=So long and thanks for all the fish!"
```

**不使用数据库：**

通过添加此部分在服务上配置此插件执行声明性配置文件：

```
plugins:
- name: request-termination
  service: {service}
  config: 
    status_code: 403
    message: So long and thanks for all the fish!
```
在这两种情况下，`{service}`都是此插件配置将定位的服务的`id`或`name`。

## 在 Route 上启用插件

**使用数据库：**

在Route上配置此插件：

```
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=request-termination"  \
    --data "config.status_code=403" \
    --data "config.message=So long and thanks for all the fish!"
```

**不使用数据库：**

通过添加此部分在路由上配置此插件执行声明性配置文件：

```
plugins:
- name: request-termination
  route: {route}
  config: 
    status_code: 403
    message: So long and thanks for all the fish!
```

在这两种情况下，`{route}`是此插件配置将定位的`Route`的`ID`或名称。

## 在 Consumer 上启用插件

**使用数据库：**

您可以使用`http://localhost:8001/plugins`在特定的Consumers上启用此插件:

```
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=request-termination" \
     \
    --data "config.status_code=403" \
    --data "config.message=So long and thanks for all the fish!"
```

**不使用数据库：**

通过添加此部分在Consumer上配置此插件执行声明性配置文件：

```
plugins:
- name: request-termination
  consumer: {consumer}
  config: 
    status_code: 403
    message: So long and thanks for all the fish!
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
| `config.status_code` <br> *optional* |  | 要发送的响应代码。|
| `config.message` <br> *optional* |  | 要使用默认响应生成器发送的消息。|
| `config.body` <br> *optional* |  | 要发送的原始响应body，这与`config.message`字段互斥。|
| `config.content_type` <br> *optional* | `application/json; charset=utf-8` | 使用`config.body`配置的原始响应的Content type。|

使用后，将通过发送配置的响应立即终止每个请求（在 Service, Route, Consumer, 或全局的已配置插件范围内）。

## 使用示例

- 暂时禁用 Service（例如，它正在维护中）。
- 暂时禁用 Route（例如，服务的其余部分已启动并正在运行，但必须禁用特定端点）。
- 暂时禁用 Consumer（例如过度消费）。
- 在逻辑`OR`设置中使用多个auth插件阻止匿名访问。




















