# route 路由

路由实体定义规则以匹配客户端请求。每个Route与一个服务相关联，一个服务可能有多个与之关联的路由。匹配给定路由的每个请求都将代理到其关联的服务。  
Routes 和 Services 的组合（以及它们之间的关注点分离）提供了一种强大的路由机制，通过它可以在 Kong 中定义细粒度的入口点，从而导致基础架构的不同上游服务。

```
{
    "id": "51e77dc2-8f3e-4afa-9d0e-0e3bbbcfd515",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-route",
    "protocols": ["http", "https"],
    "methods": ["GET", "POST"],
    "hosts": ["example.com", "foo.test"],
    "paths": ["/foo", "/bar"],
    "regex_priority": 0,
    "strip_path": true,
    "preserve_host": false,
    "tags": ["user-level", "low-priority"],
    "service": {"id":"fc73f2af-890d-4f9b-8363-af8945001f7f"}
}


```

## 添加 route
### 创建一个route

```
POST:/routes
```

### 创建与特定服务关联的路由

```
POST:/services/{service name or id}/routes
```

| 参数 | 描述 |
| ---- | ---- |
| `service name or id` <br> **required** | 应与新创建的路由关联的服务的唯一标识符或名称属性。 |

### 请求体

| 参数 | 描述 |
| ---- | ---- |
| `name` <br> *optional* | Route 名称 |
| `protocols` | 此路由应允许的协议列表。设置为`[“https”]`时，将通过请求升级到HTTPS来回答HTTP请求。默认为`[“http”，“https”]`。 |
| `methods` <br> *semi-optional* | 与此Route匹配的HTTP方法列表。使用http或https协议时，必须至少设置一个`hosts`, `paths`, or `methods`。 |
| `hosts` <br> *semi-optional* | 与此路由匹配的域名列表。使用`http`或`https`协议时，必须至少设置一个`hosts`, `paths`, 或者 `methods`。使用表单编码时，符号是`hosts [] = example.com＆hosts [] = foo.test`。使用JSON，使用Array。 |
| `paths` <br> *semi-optional* | 与此路由匹配的路径列表。使用`http`或`https`协议时，必须至少设置一个必须至少设置一个`hosts`, `paths`, 或者 `methods`。使用表单编码时，符号是`paths [] = / foo＆paths [] = / bar`。使用JSON，使用数组。 |
| `regex_priority` <br> *optional* | 用于选择哪条路由解析给定请求的数字，当多条路由同时使用正则表达式匹配时。当两条路径匹配路径并具有相同的`regex_priority`时，将使用较旧的路径（最低的`created_at`）。请注意，非正则表达式路由的优先级不同（较长的非正则表达式路由在较短的路由之前匹配）。默认为`0`。  |
| `strip_path` <br> *optional* | 通过其中一条`path`匹配Route时，从上游请求URL中删除匹配的前缀。默认为`true`。 |
| `preserve_host` <br> *optional* | 通过其中一个主机域名匹配Route时，请使用上游请求标头中的请求主机头。如果设置为false，则上游主机头将是服务主机的头。 |
| `snis` <br> *semi-optional* | 使用流路由时与此路由匹配的SNI列表。使用`tcp`或`tls`协议时，必须至少设置一个`snis`，`sources`或`destinations`。 |PUT
| `sources` <br> *semi-optional* | 使用流路由时与此路由匹配的传入连接的IP源列表。每个条目都是一个对象，其字段为“ip”（可选地为CIDR范围表示法）和/或“port”。使用`tcp`或`tls`协议时，必须至少设置一个`snis`，`sources`或`destinations`。|
| `destinations` <br> *semi-optional* | 使用流路由时，与此路由匹配的传入连接的IP目标列表。每个条目都是一个对象，其字段为“ip”（可选地为CIDR范围表示法）和/或“port”。使用`tcp`或`tls`协议时，必须至少设置一个`snis`，`sources`或`destinations`。 |
| `service` | 此路由所关联的服务。这是Route代理流量的地方，使用表单encode。表示法是`service.id = <service_id>`。使用JSON，使用`“service”：{“id”：“<service_id>”}`。|

### 响应

```
HTTP 201 Created
```

```
{
    "id": "173a6cee-90d1-40a7-89cf-0329eca780a6",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-route",
    "protocols": ["http", "https"],
    "methods": ["GET", "POST"],
    "hosts": ["example.com", "foo.test"],
    "paths": ["/foo", "/bar"],
    "regex_priority": 0,
    "strip_path": true,
    "preserve_host": false,
    "service": {"id":"f5a9c0ca-bdbb-490f-8928-2ca95836239a"}
}
```


## 路由列表
### 所有路由列表

```
GET:/routes
```

### 列出与特定服务关联的路由列表

```
GET:/services/{service name or id}/routes
```

| 参数 | 描述 |
| ---- | ---- |
| `service name or id` <br> **required** | 要检索其路由的服务的唯一标识符或`name`属性。仅列出与指定服务关联的路由。 |

### 响应

```
HTTP 200 OK
```

```
{
"data": [{
    "id": "885a0392-ef1b-4de3-aacf-af3f1697ce2c",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-route",
    "protocols": ["http", "https"],
    "methods": ["GET", "POST"],
    "hosts": ["example.com", "foo.test"],
    "paths": ["/foo", "/bar"],
    "regex_priority": 0,
    "strip_path": true,
    "preserve_host": false,
    "service": {"id":"a3395f66-2af6-4c79-bea2-1b6933764f80"}
}, {
    "id": "4fe14415-73d5-4f00-9fbc-c72a0fccfcb2",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-route",
    "protocols": ["tcp", "tls"],
    "regex_priority": 0,
    "strip_path": true,
    "preserve_host": false,
    "snis": ["foo.test", "example.com"],
    "sources": [{"ip":"10.1.0.0/16", "port":1234}, {"ip":"10.2.2.2"}, {"port":9123}],
    "destinations": [{"ip":"10.1.0.0/16", "port":1234}, {"ip":"10.2.2.2"}, {"port":9123}],
    "service": {"id":"ea29aaa3-3b2d-488c-b90c-56df8e0dd8c6"}
}],

    "next": "http://localhost:8001/routes?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```


## 查询路由

### 查询路由

```
GET:/routes/{name or id}
```

| 参数 | 描述 |
| ---- | ---- |
| `service name or id` <br> **required** | 要检索其路由的服务的唯一标识符或`name`属性。仅列出与指定服务关联的路由。 |


### 查询与特定插件关联的路由

```
GET:/plugins/{plugin id}/route
```

| 参数 | 描述 |
| ---- | ---- |
| `plugin id` <br> ** required ** | 与要更新的路由关联的插件的唯一标识符。 |

### 响应

```
HTTP 200 OK
```

```
{
    "id": "173a6cee-90d1-40a7-89cf-0329eca780a6",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-route",
    "protocols": ["http", "https"],
    "methods": ["GET", "POST"],
    "hosts": ["example.com", "foo.test"],
    "paths": ["/foo", "/bar"],
    "regex_priority": 0,
    "strip_path": true,
    "preserve_host": false,
    "service": {"id":"f5a9c0ca-bdbb-490f-8928-2ca95836239a"}
}
```

PUT
## 更新路由

### 更新路由

```
PATCH:/routes/{name or id}
```

| 参数 | 描述 |
| ---- | ---- |
| `name or id` <br> ** required ** | 唯一标识符或要更新的路由的名称。 |


### 更新与特定插件关联的路由

```
PATCH:/plugins/{plugin id}/route
```

| 参数 | 描述 |
| ---- | ---- |
| `plugin id` <br> ** required ** | 与要更新的路由关联的插件的唯一标识符。 |

### 请求体


| 参数 | 描述 |
| ---- | ---- |
| `name` <br> *optional* | Route 名称 |
| `protocols` | 此路由应允许的协议列表。设置为`[“https”]`时，将通过请求升级到HTTPS来回答HTTP请求。默认为`[“http”，“https”]`。 |
| `methods` <br> *semi-optional* | 与此Route匹配的HTTP方法列表。使用http或https协议时，必须至少设置一个`hosts`, `paths`, or `methods`。 |
| `hosts` <br> *semi-optional* | 与此路由匹配的域名列表。使用`http`或`https`协议时，必须至少设置一个`hosts`, `paths`, 或者 `methods`。使用表单编码时，符号是`hosts [] = example.com＆hosts [] = foo.test`。使用JSON，使用Array。 |
| `paths` <br> *semi-optional* | 与此路由匹配的路径列表。使用`http`或`https`协议时，必须至少设置一个必须至少设置一个`hosts`, `paths`, 或者 `methods`。使用表单编码时，符号是`paths [] = / foo＆paths [] = / bar`。使用JSON，使用数组。 |
| `regex_priority` <br> *optional* | 用于选择哪条路由解析给定请求的数字，当多条路由同时使用正则表达式匹配时。当两条路径匹配路径并具有相同的`regex_priority`时，将使用较旧的路径（最低的`created_at`）。请注意，非正则表达式路由的优先级不同（较长的非正则表达式路由在较短的路由之前匹配）。默认为`0`。  |
| `strip_path` <br> *optional* | 通过其中一条`path`匹配Route时，从上游请求URL中删除匹配的前缀。默认为`true`。 |
| `preserve_host` <br> *optional* | 通过其中一个主机域名匹配Route时，请使用上游请求标头中的请求主机头。如果设置为false，则上游主机头将是服务主机的头。 |
| `snis` <br> *semi-optional* | 使用流路由时与此路由匹配的SNI列表。使用`tcp`或`tls`协议时，必须至少设置一个`snis`，`sources`或`destinations`。 |
| `sources` <br> *semi-optional* | 使用流路由时与此路由匹配的传入连接的IP源列表。每个条目都是一个对象，其字段为“ip”（可选地为CIDR范围表示法）和/或“port”。使用`tcp`或`tls`协议时，必须至少设置一个`snis`，`sources`或`destinations`。|
| `destinations` <br> *semi-optional* | 使用流路由时，与此路由匹配的传入连接的IP目标列表。每个条目都是一个对象，其字段为“ip”（可选地为CIDR范围表示法）和/或“port”。使用`tcp`或`tls`协议时，必须至少设置一个`snis`，`sources`或`destinations`。 |
| `service` | 此路由所关联的服务。这是Route代理流量的地方，使用表单encode。表示法是`service.id = <service_id>`。使用JSON，使用`“service”：{“id”：“<service_id>”}`。|

### 响应

```
HTTP 200 OK
```

```
{
    "id": "173a6cee-90d1-40a7-89cf-0329eca780a6",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-route",
    "protocols": ["http", "https"],
    "methods": ["GET", "POST"],
    "hosts": ["example.com", "foo.test"],
    "paths": ["/foo", "/bar"],
    "regex_priority": 0,
    "strip_path": true,
    "preserve_host": false,
    "service": {"id":"f5a9c0ca-bdbb-490f-8928-2ca95836239a"}
}
```
| 参数 | 描述 |
| ---- | ---- |
| `plugin id` <br> ** required ** | 与要更新的路由关联的插件的唯一标识符。 |

## 更新或创建路由

### 更新或创建一个路由

```
PUT:/routes/{name or id}
```

```
| 参数 | 描述 |
| ---- | ---- |
| `name or id` <br> ** required ** | 要创建或更新的路由的唯一标识符或名称。 |
```

### 创建或更新与特定插件关联的路由

```
PUT:/plugins/{plugin id}/route
```

| 参数 | 描述 |
| ---- | ---- |
| `plugin id` <br> ** required ** | 与要更新的路由关联的插件的唯一标识符。 |


### 请求体

| 参数 | 描述 |
| ---- | ---- |
| `name` <br> *optional* | Route 名称 |
| `protocols` | 此路由应允许的协议列表。设置为`[“https”]`时，将通过请求升级到HTTPS来回答HTTP请求。默认为`[“http”，“https”]`。 |
| `methods` <br> *semi-optional* | 与此Route匹配的HTTP方法列表。使用http或https协议时，必须至少设置一个`hosts`, `paths`, or `methods`。 |
| `hosts` <br> *semi-optional* | 与此路由匹配的域名列表。使用`http`或`https`协议时，必须至少设置一个`hosts`, `paths`, 或者 `methods`。使用表单编码时，符号是`hosts [] = example.com＆hosts [] = foo.test`。使用JSON，使用Array。 |
| `paths` <br> *semi-optional* | 与此路由匹配的路径列表。使用`http`或`https`协议时，必须至少设置一个必须至少设置一个`hosts`, `paths`, 或者 `methods`。使用表单编码时，符号是`paths [] = / foo＆paths [] = / bar`。使用JSON，使用数组。 |
| `regex_priority` <br> *optional* | 用于选择哪条路由解析给定请求的数字，当多条路由同时使用正则表达式匹配时。当两条路径匹配路径并具有相同的`regex_priority`时，将使用较旧的路径（最低的`created_at`）。请注意，非正则表达式路由的优先级不同（较长的非正则表达式路由在较短的路由之前匹配）。默认为`0`。  |
| `strip_path` <br> *optional* | 通过其中一条`path`匹配Route时，从上游请求URL中删除匹配的前缀。默认为`true`。 |
| `preserve_host` <br> *optional* | 通过其中一个主机域名匹配Route时，请使用上游请求标头中的请求主机头。如果设置为false，则上游主机头将是服务主机的头。 |
| `snis` <br> *semi-optional* | 使用流路由时与此路由匹配的SNI列表。使用`tcp`或`tls`协议时，必须至少设置一个`snis`，`sources`或`destinations`。 |
| `sources` <br> *semi-optional* | 使用流路由时与此路由匹配的传入连接的IP源列表。每个条目都是一个对象，其字段为“ip”（可选地为CIDR范围表示法）和/或“port”。使用`tcp`或`tls`协议时，必须至少设置一个`snis`，`sources`或`destinations`。|
| `destinations` <br> *semi-optional* | 使用流路由时，与此路由匹配的传入连接的IP目标列表。每个条目都是一个对象，其字段为“ip”（可选地为CIDR范围表示法）和/或“port”。使用`tcp`或`tls`协议时，必须至少设置一个`snis`，`sources`或`destinations`。 |
| `service` | 此路由所关联的服务。这是Route代理流量的地方，使用表单encode。表示法是`service.id = <service_id>`。使用JSON，使用`“service”：{“id”：“<service_id>”}`。|

使用请求提中指定的参数插入(或替换)请求资源下的路由。Route将通过`name`或`id`属性进行标识。  
当`name`或`id`属性具有UUID的结构时，插入/替换的Route将由其`id`标识。否则将通过其`name`识别。  
在创建新路由而不指定id（既不在URL中也不在主体中）时，它将自动生成。  
请注意，不允许在URL中指定`name`，在请求正文中指定其他名称。  

### 响应

```
HTTP 201 Created or HTTP 200 OK
```
参考 POST 和 PATCH 的响应。

## 删除路由

### 删除一个路由

```
DELETE:/routes/{name or id}
```

```
| 参数 | 描述 |
| ---- | ---- |
| `name or id` <br> ** required ** | 要删除的路由的唯一标识符或名称。 |
```

### 响应

```
HTTP 204 No Content
```



















