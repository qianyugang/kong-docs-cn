# 插件

插件实体表示将在HTTP请求/响应生命周期期间执行的插件配置。它是如何为在Kong后面运行的服务添加功能的，例如 Authentication 或 Rate Limiting 。您可以访问[Kong Hub](https://docs.konghq.com/hub/)，获取有关如何安装以及每个插件所需值的更多信息。

将插件配置添加到服务时，客户端向该服务发出的每个请求都将运行所述插件。如果某个特定消费者需要将插件调整为不同的值，您可以通过创建一个单独的插件实例来实现，该实例通过`service` 和 `consumer`这两个字段指定服务和消费者。

插件可以通过[标签进行标记和过滤](https://docs.konghq.com/1.1.x/admin-api/#tags)。
```
{
    "id": "ec1a1f6f-2aa4-4e58-93ff-b56368f19b27",
    "name": "rate-limiting",
    "created_at": 1422386534,
    "route": null,
    "service": null,
    "consumer": null,
    "config": {"hour":500, "minute":20},
    "run_on": "first",
    "protocols": ["http", "https"],
    "enabled": true,
    "tags": ["user-level", "low-priority"]
}
```

有关详细信息，请参阅下面的优先级部分。

## 优先级

插件将始终运行一次，每次请求只运行一次。它运行的配置取决于它所针对的实体。

可以为各种实体，实体组合甚至全局配置插件。这很有用，例如，当您希望为大多数请求以某种方式配置插件，但是要使经过*身份验证的请求*的行为略有不同时。

因此，当插件应用于具有不同配置的不同实体时，存在一个优先顺序来运行插件。经验法则是：插件关于配置的实体数量越多，其优先级越高。

多次配置插件时的完整优先顺序是：

1. 在以下组合上配置的插件：Route，Service 和 Consumer。（Consumer意味着必须对请求进行身份验证）。
2. 在 Route 和 Consumer 的组合上配置的插件。（Consumer意味着必须对请求进行身份验证）。
3. 在 Service 和 Consumer 的组合上配置的插件。（Consumer意味着必须对请求进行身份验证）。
4. 在 Route 和 Service 的组合上配置的插件。
5. 在 Consumer 上配置的插件。（Consumer 意味着必须对请求进行身份验证）。
6. 在 Route 上配置的插件。
7. 在 Service 上配置的插件。
8. 配置为全局运行的插件。

**例如：**如果`rate-limiting`速率限制插件应用了两次（且都具有不同的配置）：对于一个 Service（插件配置A）和 Consumer（插件配置B），然后请求验证此消费者将运行插件配置B并忽略A。但是，不对此Consumer进行身份验证的请求将回退到运行Plugin配置A。请注意，如果禁用配置B（其启用标志设置为false），配置A将应用于本来匹配配置B的请求。

## 添加插件

### 创建一个插件

```
POST /plugins
```
### 创建与特定 Route 关联的插件

```
POST /routes/{route id}/plugins
```
| 参数 | 描述 | 
| ---- | ---- |
| `route id`<br> required | 应与新创建的插件关联的 Route 的唯一标识符。|

### 创建与特定 Service 关联的插件

```
POST /routes/{service id}/plugins
```
| 参数 | 描述 | 
| ---- | ---- |
| `service id`<br> required | 应与新创建的插件关联的 Service 的唯一标识符。|

### 创建与特定 Consumer 关联的插件

```
POST /routes/{consumer id}/plugins
```
| 参数 | 描述 | 
| ---- | ---- |
| `consumer id`<br> required | 应与新创建的插件关联的 consumer 的唯一标识符。|

*请求体*

| 参数 | 描述 | 
| ---- | ---- |
| `name` | 要添加的插件的名称。目前，插件必须分别安装在每个Kong实例中。 |
| `route` <br> *optional* | 如果设置，插件将仅在通过指定路由接收请求时激活。不管使用什么路由，都不要设置插件来激活它。 默认值为`null`。使用form-encoded时候，用`route.id=<route_id>`；使用JSON的时候，用`"route":{"id":"<route_id>"}`。 | 
| `service` <br> *optional* | 如果设置，插件将仅在通过属于指定服务的路由之一接收请求时激活。无论服务是否匹配，都不要设置插件激活。 默认值为`null`。使用form-encoded时候，用`service.id=<service_id>`；使用JSON的时候，用`"service":{"id":"<service_id>"}`。 | 
| `consumer` <br> *optional* | 如果设置，则插件仅对指定已经过身份验证的请求激活。（请注意，某些插件不能以这种方式限制在消费者身上。）无论经过身份验证的使用者是什么，都不要设置插件激活。默认值为`null`。使用form-encoded时候，用`consumer.id=<consumer_id>`；使用JSON的时候，用`"consumer":{"id":"<consumer_id>"}`。 | 
| `config` <br> *optional* | 插件的配置属性，可以在[Kong Hub](https://docs.konghq.com/hub/)的插件文档页面找到。 | 
| `run_on` <br> *optional* | 在给定Service Mesh场景的情况下，控制此插件将运行的Kong节点。可接受的值为：`* first`，表示“在请求遇到的第一个Kong节点上运行”。 在API Getaway场景中，这是常用操作，因为源和目标之间只有一个Kong节点。在sidecar-to-sidecar Service Mesh场景中，这意味着仅在出站连接的Kong边车上运行插件。`* second`，意思是“在请求遇到的第二个节点上运行”。此选项仅适用于sidecar-to-sidecar Service Mesh场景：这意味着仅在入站连接的Kong sidecar 上运行插件。`* all`，意味着“在所有节点上运行”，这意味着 sidecar-to-sidecar 场景中的所有 sidecars。这对 tracing/logging 插件很有用。默认为`“first”`。|  
| `protocols` <br> *optional* | 将触发此插件的请求协议列表。可能的值为`“http”`，`“https”`，`“tcp”`和`“tls”`。默认值以及此字段上允许的可能值可能会根据插件类型而更改。例如，仅在流模式下工作的插件可能只支持`“tcp”`和`“tls”`。默认为`[“http”，“https”]`。	  | 
| `enabled` <br> *optional* | 是否启用插件。默认为`true` | 
| `tags` <br> *optional* | 与插件关联的一组可选字符串，用于分组和过滤。 | 

*响应*

```
HTTP 201 Created
```
```
{
    "id": "ec1a1f6f-2aa4-4e58-93ff-b56368f19b27",
    "name": "rate-limiting",
    "created_at": 1422386534,
    "route": null,
    "service": null,
    "consumer": null,
    "config": {"hour":500, "minute":20},
    "run_on": "first",
    "protocols": ["http", "https"],
    "enabled": true,
    "tags": ["user-level", "low-priority"]
}

```

## 插件列表

### 列出所有插件
```
GET /plugins
```

### 列出与特定 Route 关联的插件
```
GET /routes/{route id}/plugins
```
| 参数 | 描述 | 
| ---- | ---- |
| `route id`<br> required | 要检索其插件的Route的唯一标识符。使用此端点时，仅列出与指定Route关联的插件。|

### 列出与特定 Service 关联的插件
```
GET /routes/{service id}/plugins
```
| 参数 | 描述 | 
| ---- | ---- |
| `service id`<br> required | 要检索其插件的Service的唯一标识符。使用此端点时，仅列出与指定Service关联的插件。|

### 列出与特定 Consumer 关联的插件
```
GET /routes/{consumer id}/plugins
```
| 参数 | 描述 | 
| ---- | ---- |
| `consumer id`<br> required | 要检索其插件的Consumer的唯一标识符。使用此端点时，仅列出与指定Consumer关联的插件。|

*响应*

```
HTTP 200 OK
```
```
{
"data": [{
    "id": "a4407883-c166-43fd-80ca-3ca035b0cdb7",
    "name": "rate-limiting",
    "created_at": 1422386534,
    "route": null,
    "service": null,
    "consumer": null,
    "config": {"hour":500, "minute":20},
    "run_on": "first",
    "protocols": ["http", "https"],
    "enabled": true,
    "tags": ["user-level", "low-priority"]
}, {
    "id": "01c23299-839c-49a5-a6d5-8864c09184af",
    "name": "rate-limiting",
    "created_at": 1422386534,
    "route": null,
    "service": null,
    "consumer": null,
    "config": {"hour":500, "minute":20},
    "run_on": "first",
    "protocols": ["tcp", "tls"],
    "enabled": true,
    "tags": ["admin", "high-priority", "critical"]
}],

    "next": "http://localhost:8001/plugins?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```

## 查询插件

### 查询插件

```
GET /plugins/{plugin id}
```
| 参数 | 描述 | 
| ---- | ---- |
| `plugin id`<br> required | 要检索的插件的唯一标识符。|

*响应*

```
HTTP 200 OK
```
```
{
    "id": "ec1a1f6f-2aa4-4e58-93ff-b56368f19b27",
    "name": "rate-limiting",
    "created_at": 1422386534,
    "route": null,
    "service": null,
    "consumer": null,
    "config": {"hour":500, "minute":20},
    "run_on": "first",
    "protocols": ["http", "https"],
    "enabled": true,
    "tags": ["user-level", "low-priority"]
}

```


## 更新插件

### 更新插件

```
PATCH /plugins/{plugin id}
```
| 参数 | 描述 | 
| ---- | ---- |
| `plugin id`<br> required | 要更新的插件的唯一标识符。|

*请求体*

| 参数 | 描述 | 
| ---- | ---- |
| `name` | 要添加的插件的名称。目前，插件必须分别安装在每个Kong实例中。 |
| `route` <br> *optional* | 如果设置，插件将仅在通过指定路由接收请求时激活。不管使用什么路由，都不要设置插件来激活它。 默认值为`null`。使用form-encoded时候，用`route.id=<route_id>`；使用JSON的时候，用`"route":{"id":"<route_id>"}`。 | 
| `service` <br> *optional* | 如果设置，插件将仅在通过属于指定服务的路由之一接收请求时激活。无论服务是否匹配，都不要设置插件激活。 默认值为`null`。使用form-encoded时候，用`service.id=<service_id>`；使用JSON的时候，用`"service":{"id":"<service_id>"}`。 | 
| `consumer` <br> *optional* | 如果设置，则插件仅对指定已经过身份验证的请求激活。（请注意，某些插件不能以这种方式限制在消费者身上。）无论经过身份验证的使用者是什么，都不要设置插件激活。默认值为`null`。使用form-encoded时候，用`consumer.id=<consumer_id>`；使用JSON的时候，用`"consumer":{"id":"<consumer_id>"}`。 | 
| `config` <br> *optional* | 插件的配置属性，可以在[Kong Hub](https://docs.konghq.com/hub/)的插件文档页面找到。 | 
| `run_on` <br> *optional* | 在给定Service Mesh场景的情况下，控制此插件将运行的Kong节点。可接受的值为：`* first`，表示“在请求遇到的第一个Kong节点上运行”。 在API Getaway场景中，这是常用操作，因为源和目标之间只有一个Kong节点。在sidecar-to-sidecar Service Mesh场景中，这意味着仅在出站连接的Kong边车上运行插件。`* second`，意思是“在请求遇到的第二个节点上运行”。此选项仅适用于sidecar-to-sidecar Service Mesh场景：这意味着仅在入站连接的Kong sidecar 上运行插件。`* all`，意味着“在所有节点上运行”，这意味着 sidecar-to-sidecar 场景中的所有 sidecars。这对 tracing/logging 插件很有用。默认为`“first”`。|  
| `protocols` <br> *optional* | 将触发此插件的请求协议列表。可能的值为`“http”`，`“https”`，`“tcp”`和`“tls”`。默认值以及此字段上允许的可能值可能会根据插件类型而更改。例如，仅在流模式下工作的插件可能只支持`“tcp”`和`“tls”`。默认为`[“http”，“https”]`。	  | 
| `enabled` <br> *optional* | 是否启用插件。默认为`true` | 
| `tags` <br> *optional* | 与插件关联的一组可选字符串，用于分组和过滤。 | 

*响应*

```
HTTP 200 OK
```
```
{
    "id": "ec1a1f6f-2aa4-4e58-93ff-b56368f19b27",
    "name": "rate-limiting",
    "created_at": 1422386534,
    "route": null,
    "service": null,
    "consumer": null,
    "config": {"hour":500, "minute":20},
    "run_on": "first",
    "protocols": ["http", "https"],
    "enabled": true,
    "tags": ["user-level", "low-priority"]
}
```
## 更新或创建插件

### 更新或创建一个插件

```
PUT /plugins/{plugin id}
```
| 参数 | 描述 | 
| ---- | ---- |
| `plugin id`<br> required | 要更新的插件的唯一标识符。|

*请求体*

| 参数 | 描述 | 
| ---- | ---- |
| `name` | 要添加的插件的名称。目前，插件必须分别安装在每个Kong实例中。 |
| `route` <br> *optional* | 如果设置，插件将仅在通过指定路由接收请求时激活。不管使用什么路由，都不要设置插件来激活它。 默认值为`null`。使用form-encoded时候，用`route.id=<route_id>`；使用JSON的时候，用`"route":{"id":"<route_id>"}`。 | 
| `service` <br> *optional* | 如果设置，插件将仅在通过属于指定服务的路由之一接收请求时激活。无论服务是否匹配，都不要设置插件激活。 默认值为`null`。使用form-encoded时候，用`service.id=<service_id>`；使用JSON的时候，用`"service":{"id":"<service_id>"}`。 | 
| `consumer` <br> *optional* | 如果设置，则插件仅对指定已经过身份验证的请求激活。（请注意，某些插件不能以这种方式限制在消费者身上。）无论经过身份验证的使用者是什么，都不要设置插件激活。默认值为`null`。使用form-encoded时候，用`consumer.id=<consumer_id>`；使用JSON的时候，用`"consumer":{"id":"<consumer_id>"}`。 | 
| `config` <br> *optional* | 插件的配置属性，可以在[Kong Hub](https://docs.konghq.com/hub/)的插件文档页面找到。 | 
| `run_on` <br> *optional* | 在给定Service Mesh场景的情况下，控制此插件将运行的Kong节点。可接受的值为：`* first`，表示“在请求遇到的第一个Kong节点上运行”。 在API Getaway场景中，这是常用操作，因为源和目标之间只有一个Kong节点。在sidecar-to-sidecar Service Mesh场景中，这意味着仅在出站连接的Kong边车上运行插件。`* second`，意思是“在请求遇到的第二个节点上运行”。此选项仅适用于sidecar-to-sidecar Service Mesh场景：这意味着仅在入站连接的Kong sidecar 上运行插件。`* all`，意味着“在所有节点上运行”，这意味着 sidecar-to-sidecar 场景中的所有 sidecars。这对 tracing/logging 插件很有用。默认为`“first”`。|  
| `protocols` <br> *optional* | 将触发此插件的请求协议列表。可能的值为`“http”`，`“https”`，`“tcp”`和`“tls”`。默认值以及此字段上允许的可能值可能会根据插件类型而更改。例如，仅在流模式下工作的插件可能只支持`“tcp”`和`“tls”`。默认为`[“http”，“https”]`。	  | 
| `enabled` <br> *optional* | 是否启用插件。默认为`true` | 
| `tags` <br> *optional* | 与插件关联的一组可选字符串，用于分组和过滤。 | 

使用正文中指定的定义在所请求的资源下插入（或替换）插件。插件将通过`name or id`属性进行标识。

当`name or id`属性具有UUID的结构时，插入/替换的插件将由其`id`标识。否则将通过其名称识别。

在创建新插件而不指定id（既不在URL中也不在正文中）时，它将自动生成。

请注意，不允许在URL中指定`name`，也不允许在请求正文中指定其他名称。

*响应*
```
HTTP 201 Created or HTTP 200 OK
```
请参阅POST和PATCH响应。

## 删除插件

## 删除一个插件

```
DELETE /plugins/{plugin id}
```
| 参数 | 描述 | 
| ---- | ---- |
| `plugin id`<br> required | 要删除的插件的唯一标识符。|

*响应*
```
HTTP 204 No Content
```

## 查询可使用的插件

检索Kong节点上所有已安装插件的列表。
```
GET /plugins/enabled
```
*响应*
```
HTTP 200 OK
```
```
{
    "enabled_plugins": [
        "jwt",
        "acl",
        "cors",
        "oauth2",
        "tcp-log",
        "udp-log",
        "file-log",
        "http-log",
        "key-auth",
        "hmac-auth",
        "basic-auth",
        "ip-restriction",
        "request-transformer",
        "response-transformer",
        "request-size-limiting",
        "rate-limiting",
        "response-ratelimiting",
        "aws-lambda",
        "bot-detection",
        "correlation-id",
        "datadog",
        "galileo",
        "ldap-auth",
        "loggly",
        "statsd",
        "syslog"
    ]
}
```

## 查询插件schema

检索插件配置的schema。这有助于了解插件接受哪些字段，并可用于构建Kong插件系统的第三方集成。
```
GET /plugins/schema/{plugin name}
```

*响应*
```
HTTP 200 OK
```
```
{
    "fields": {
        "hide_credentials": {
            "default": false,
            "type": "boolean"
        },
        "key_names": {
            "default": "function",
            "required": true,
            "type": "array"
        }
    }
}
```
