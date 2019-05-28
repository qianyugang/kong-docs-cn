# Service 服务

顾名思义，服务实体是每个上游服务的抽象。举个例子，services 可以是一个数据转换微服务，一个计费api等等。

Service 的主要属性是其URL（Kong应该将流量代理到的地方），可以设置为单个字符串，也可以单独指定其`protocol`, `host`, `port` 和 `path`。

Service 与 router 相关联（一个 Service 可以有许多与之关联的 router）。router 是Kong的入口点，并定义匹配客户端请求的规则。一旦 router 匹配，Kong就会将请求代理到其关联的服务。有关Kong代理流量的详细说明，请参阅[代理参考](https://docs.konghq.com/1.0.x/proxy)。

```
{
    "id": "0c61e164-6171-4837-8836-8f5298726d53",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-service",
    "retries": 5,
    "protocol": "http",
    "host": "example.com",
    "port": 80,
    "path": "/some_api",
    "connect_timeout": 60000,
    "write_timeout": 60000,
    "read_timeout": 60000
}

Permalink
```

### 添加一个 Service

#### 创建一个service

```
POST:/services
```

#### 请求体

| 参数 | 描述 |
| ---- | ---- |
| `name`<br> *optional* | Service 名称 |
| `retries`<br> *optional* | 代理失败时要执行的重试次数。默认为 5 |
| `protocol`<br>   | 用于与上游通信的协议。它可以是`http`或`https`之一。默认为“`http`”。 |
| `host`<br>   | 上游服务的 host |
| `port`<br>   | 上游服务端口。默认为80。  |
| `path`<br> *optional*  | 在上游服务器的请求中使用的路径。 |
| `connect_timeout`<br> *optional*  | 建立与上游服务器的连接的超时时间（以毫秒为单位）。默认为 `60000` |
| `write_timeout`<br> *optional*  | 用于向上游服务器发送请求的两次连续写操作之间的超时（以毫秒为单位）。默认为`60000`。 |
| `read_timeout`<br> *optional*  | 用于向上游服务器发送请求的两次连续读取操作之间的超时（以毫秒为单位）。默认为`60000`。 |
| `url`<br> *shorthand-attribute*  | 用于同时设置`protocol`，`host`，`port` 和 `path` 的速记属性。此属性是只写的（Admin API永远不会“返回”该URL）。 |

#### 响应

```
HTTP 201 Created
```

```
{
    "id": "0c61e164-6171-4837-8836-8f5298726d53",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-service",
    "retries": 5,
    "protocol": "http",
    "host": "example.com",
    "port": 80,
    "path": "/some_api",
    "connect_timeout": 60000,
    "write_timeout": 60000,
    "read_timeout": 60000
}

```

### Services 列表

#### 查询所有的 Services

```
GET:/services
```

#### 响应

```
HTTP 200 OK
```

```
{
"data": [{
    "id": "f00c6da4-3679-4b44-b9fb-36a19bd3ae83",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-service",
    "retries": 5,
    "protocol": "http",
    "host": "example.com",
    "port": 80,
    "path": "/some_api",
    "connect_timeout": 60000,
    "write_timeout": 60000,
    "read_timeout": 60000
}, {
    "id": "bdab0e47-4e37-4f0b-8fd0-87d95cc4addc",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-service",
    "retries": 5,
    "protocol": "http",
    "host": "example.com",
    "port": 80,
    "path": "/another_api",
    "connect_timeout": 60000,
    "write_timeout": 60000,
    "read_timeout": 60000
}],
    "next": "http://localhost:8001/services?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```

### 查询 Services

#### 查询

```
GET:/services/{name or id}
```

| 参数 | 描述 |
| ---- | ---- |
| `name or id`<br>**required** | 要检索的服务的唯一标识符或名称。 |

#### 查询与特定路由关联的服务

```
GET:/routes/{route name or id}/service
```
| 参数 | 描述 |
| ---- | ---- |
| `route name or id`<br>**required** | 与要检索的服务关联的唯一标识符或Route的名称。 |

#### 查询特定插件关联的服务

```
GET:/plugins/{plugin id}/service
```
| 参数 | 描述 |
| ---- | ---- |
| `plugin id`<br>**required** | 与要检索的服务关联的插件的唯一标识符。 |

#### 响应

```
HTTP 200 OK
```

```
{
    "id": "0c61e164-6171-4837-8836-8f5298726d53",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-service",
    "retries": 5,
    "protocol": "http",
    "host": "example.com",
    "port": 80,
    "path": "/some_api",
    "connect_timeout": 60000,
    "write_timeout": 60000,
    "read_timeout": 60000
}

```


### 更新 service

#### 更新

```
PATCH:/services/{name or id}
```
| 参数 | 描述 |
| ---- | ---- |
| `name or id`<br>**required** | 要更新的服务的唯一标识符或名称。 |

#### 更新与特定路由关联的服务

```
PATCH:/routes/{route name or id}/service
```
| 参数 | 描述 |
| ---- | ---- |
| `route name or id`<br>**required** | 与要更新的服务关联的唯一标识符或Route的名称。 |

#### 更新与特定插件关联的服务

```
PATCH:/plugins/{plugin id}/service
```
| 参数 | 描述 |
| ---- | ---- |
| `plugin id`<br>**required** | 与要更新的服务关联的插件的唯一标识符。 |

#### 请求体

| 参数 | 描述 |
| ---- | ---- |
| `name`<br> *optional* | Service 名称 |
| `retries`<br> *optional* | 代理失败时要执行的重试次数。默认为 5 |
| `protocol`<br>   | 用于与上游通信的协议。它可以是`http`或`https`之一。默认为“`http`”。 |
| `host`<br>   | 上游服务的 host |
| `port`<br>   | 上游服务端口。默认为80。  |
| `path`<br> *optional*  | 在上游服务器的请求中使用的路径。 |
| `connect_timeout`<br> *optional*  | 建立与上游服务器的连接的超时时间（以毫秒为单位）。默认为 `60000` |
| `write_timeout`<br> *optional*  | 用于向上游服务器发送请求的两次连续写操作之间的超时（以毫秒为单位）。默认为`60000`。 |
| `read_timeout`<br> *optional*  | 用于向上游服务器发送请求的两次连续读取操作之间的超时（以毫秒为单位）。默认为`60000`。 |
| `url`<br> *shorthand-attribute*  | 用于同时设置`protocol`，`host`，`port` 和 `path` 的速记属性。此属性是只写的（Admin API永远不会“返回”该URL）。 |

#### 响应

```
HTTP 200 OK
```

```
{
    "id": "0c61e164-6171-4837-8836-8f5298726d53",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-service",
    "retries": 5,
    "protocol": "http",
    "host": "example.com",
    "port": 80,
    "path": "/some_api",
    "connect_timeout": 60000,
    "write_timeout": 60000,
    "read_timeout": 60000
}
```

### 更新或创建服务

#### 创建或更新

```
PUT:/services/{name or id}
```

| 参数 | 描述 |
| ---- | ---- |
| `route name or id`<br>**required** | 与要更新或创建的服务关联的唯一标识符或Route的名称。 |

#### 创建或更新与特定路由关联的服务

```
PUT:/routes/{route name or id}/service
```
| 参数 | 描述 |
| ---- | ---- |
| `route name or id`<br>**required** | 与要更新或创建的服务关联的唯一标识符或Route的名称。 |

#### 创建或更新与特定插件关联的服务

```
PUT:/plugins/{plugin id}/service
```
| 参数 | 描述 |
| ---- | ---- |
| `plugin id`<br>**required** | 与要更新或创建的服务关联的插件的唯一标识符。 |

#### 请求体

| 参数 | 描述 |
| ---- | ---- |
| `name`<br> *optional* | Service 名称 |
| `retries`<br> *optional* | 代理失败时要执行的重试次数。默认为 5 |
| `protocol`<br>   | 用于与上游通信的协议。它可以是`http`或`https`之一。默认为“`http`”。 |
| `host`<br>   | 上游服务的 host |
| `port`<br>   | 上游服务端口。默认为80。  |
| `path`<br> *optional*  | 在上游服务器的请求中使用的路径。 |
| `connect_timeout`<br> *optional*  | 建立与上游服务器的连接的超时时间（以毫秒为单位）。默认为 `60000` |
| `write_timeout`<br> *optional*  | 用于向上游服务器发送请求的两次连续写操作之间的超时（以毫秒为单位）。默认为`60000`。 |
| `read_timeout`<br> *optional*  | 用于向上游服务器发送请求的两次连续读取操作之间的超时（以毫秒为单位）。默认为`60000`。 |
| `url`<br> *shorthand-attribute*  | 用于同时设置`protocol`，`host`，`port` 和 `path` 的速记属性。此属性是只写的（Admin API永远不会“返回”该URL）。 |

使用body中指定的参数在请求的资源下插入（或替换）服务。Service 将通过`name`或`id`属性标识。

当name或id属性具有UUID的结构时，插入/替换 的服务将由其id标识。否则将通过其名称识别。

在创建新服务而不指定id（既不在URL中也不在body中）时，它将自动生成。

请注意，请注意，URL中的name和请求体中的name名称必须一样。

#### 响应
 	
```
HTTP 201 Created or HTTP 200 OK
```
请参阅POST和PATCH响应

### 删除 service

#### 删除

```
DELETE:/services/{name or id}
```
| 参数 | 描述 |
| ---- | ---- |
| `name or id`<br>**required** | 要删除的服务的唯一标识符或名称。 |

#### 删除与特定路由关联的服务

```
DELETE:/routes/{route name or id}/service
```
| 参数 | 描述 |
| ---- | ---- |
| `route name or id`<br>**required** | 与要删除的服务关联的唯一标识符或Route的名称。 |

#### 响应

```
HTTP 204 No Content
```








