# 无数据库模式 Admin API 

> 此页面指的是用于运行Kong的Admin API，该API配置为无数据库，通过声明性配置管理内存中的实体。
有关将Kong的Admin API与数据库一起使用的信息，请参阅 [数据库模式的Admin API](https://docs.konghq.com/1.3.x/admin-api)页面。

## 目录

- [支持的 Content Types](#支持的-Content-Types)
- [Routes 信息](#Routes-信息)
	- [检索节点信息](#检索节点信息)
	- [检索节点状态](#检索节点状态)
- [声明式配置](#声明式配置)
	- [重新加载声明性配置](#重新加载声明性配置)
- [标签](#标签)
	- [列出所有标签](#列出所有标签)
	- [按标签列出实体ID](#按标签列出实体ID)
- [Service 对象](#Service-对象)
	- [Service 列表](#Service-列表)
	- [Service 检索](#Service-列表)
- [Route 对象](#Route-对象)
	- [Route 列表](#Route-列表)
	- [Route 检索](#Route-检索)
- [Consumer 对象](#Consumer-对象)
	- [Consumer 列表](#Consumer-列表)
	- [Consumer 检索](#Consumer-检索)
- [插件对象](#插件对象)
	- [优先级](#优先级)
	- [插件列表](#插件列表)
	- [插件检索](#插件检索)
	- [已启用的插件检索](#已启用的插件检索)
	- [插件schema检索](#插件schema检索)
- [证书对象](#证书对象)
	- [证书列表](#证书列表)
	- [证书检索](#证书检索)
- [SNI 对象](#SNI-对象)
	- [SNI 列表](#SNI-列表)
	- [SNI 检索](#SNI-检索)
- [Upstream 对象](#Upstream-对象)
	- [Upstream 列表](#Upstream-列表)
	- [Upstream 检索](#Upstream-检索)
	- [显示节点的Upstream运行状况](#显示节点的Upstream运行状况)
- [Target 对象](#Target-对象)
	- [Target 列表](#Target-列表)
	- [将Target设定为健康](#将Target设定为健康)
	- [将Target设置为不健康](#将Target设置为不健康)
	- [所有Target列表](#所有Target列表)

## 支持的 Content Types

Admin API在每个端点上接受2种内容类型：

- application/x-www-form-urlencoded
- application/json

## Routes 信息

### 检索节点信息

检索有关节点的常规详细信息。

```
GET /
```

*响应*

```
HTTP 200 OK
```
```
{
    "hostname": "",
    "node_id": "6a72192c-a3a1-4c8d-95c6-efabae9fb969",
    "lua_version": "LuaJIT 2.1.0-beta3",
    "plugins": {
        "available_on_server": [
            ...
        ],
        "enabled_in_cluster": [
            ...
        ]
    },
    "configuration" : {
        ...
    },
    "tagline": "Welcome to Kong",
    "version": "0.14.0"
}
```

- `node_id`：表示正在运行的Kong节点的UUID。Kong启动时会随机生成此UUID，因此该节点在每次重新启动时将具有不同的node_id。
- `available_on_server`：节点上安装的插件的名称。
- `enabled_in_cluster`：启用/配置的插件名称。也就是说，当前所有数据节点共享的数据存储中的插件配置。

### 检索节点状态

检索有关节点的使用情况信息，以及一些有关基础nginx进程正在处理的连接的基本信息，数据库连接的状态以及节点的内存使用情况。

如果要监视Kong进程，由于Kong是在nginx之上构建的，因此可以使用每个现有的nginx监视工具或代理。

```
GET /status
```
*响应*    
```
HTTP 200 OK
```
```
{
    "database": {
      "reachable": true
    },
    "memory": {
        "workers_lua_vms": [{
            "http_allocated_gc": "0.02 MiB",
            "pid": 18477
          }, {
            "http_allocated_gc": "0.02 MiB",
            "pid": 18478
        }],
        "lua_shared_dicts": {
            "kong": {
                "allocated_slabs": "0.04 MiB",
                "capacity": "5.00 MiB"
            },
            "kong_db_cache": {
                "allocated_slabs": "0.80 MiB",
                "capacity": "128.00 MiB"
            },
        }
    },
    "server": {
        "total_requests": 3,
        "connections_active": 1,
        "connections_accepted": 1,
        "connections_handled": 1,
        "connections_reading": 0,
        "connections_writing": 1,
        "connections_waiting": 0
    }
}
```

- `memory`：有关内存使用情况的指标。
	- `workers_lua_vms`：包含Kong节点的所有worker的数组，其中每个条目包含：
	- `http_allocated_gc`：由`collectgarbage（“ count”）`报告的HTTP子模块的Lua虚拟机的内存使用情况信息，适用于每个活动的worker程序，即在最近10秒钟内收到代理调用的工作程序。
	- `pid`：工作进程id号
	- `lua_shared_dicts`：与Kong节点中所有工作人员共享的词典信息的数组，其中每个数组节点包含有多少内存专用于特定的共享字典（`capacity`）以及有多少所述内存正在使用（`allocated_slabs`）。<br>
    这些共享字典具有最新使用（LRU）的清楚功能，因此`allocated_slab == capacity`所在的完整字典将正常工作。
但是对于某些字典，例如缓存HIT/MISS共享字典，增加它们的大小对整体来说是有益的。
	- 可以使用querystring参数unit和scale更改内存使用单位和精度：
		- `unit`：`b/B`，`k/K`，`m/M`，`g/G`中，它将分别以bytes、kibibytes、mebibytes或gibibytes返回结果。当请求“bytes”时，响应中的内存值将使用数字类型而不是字符串。默认为`m`。
		- `scale`：在人类可读的存储字符串（“bytes”以外的单位）示值时小数点右边的位数。默认值为2。您可以通过以下操作获得以kibibytes为单位的共享字典内存使用情况(精度为4位):`get/status?unit=k&scale=4`
- `server`：有关Nginx HTTP/S服务器的指标。
	- `total_requests`：客户端请求总数。
    - `connections_active`：当前活动的客户端连接数，包括等待连接数。
    - `connections_accepted`：接受的客户端连接总数。
    - `connections_handled`：已处理的连接总数。通常，除非已达到某些资源限制，否则参数值与接受的值相同。
    - `connections_reading`：Kong正在读取请求header的当前连接数。
    - `connections_writing`：nginx正在将响应写回到客户端的当前连接数。
    - `connections_waiting`：当前等待请求的空闲客户端连接数。
- `database`：数据库指标
	- `reachable`：反映数据库连接状态的布尔值。请注意，此标志**不反映**数据库本身的运行状况。

## 声明式配置

可以通过两种方式将实体的声明性配置加载到Kong中：在启动时，通过`declarative_config`属性，或者在运行时，通过使用`/ config`端点的Admin API。

要开始使用声明式配置，您需要一个包含实体定义的文件（YAML或JSON格式）。
您可以使用以下命令生成示例声明式配置：
```
kong config init
```
它会在当前目录中生成一个名为`kong.yml`的文件，其中包含适当的结构和示例。

### 重新加载声明性配置

该端点允许使用新的声明性配置数据文件重置无数据库的Kong。
所有先前的内容将从内存中删除，并且在给定文件中指定的实体将取代其位置。

要了解有关文件格式的更多信息，请阅读[声明性配置](https://docs.konghq.com/1.3.x/db-less-and-declarative-config)文档。

```
POST /config
```

| 属性 | 描述 |
| ---- | --- |
| `config` <br> required |要加载的配置数据（YAML或JSON格式）。 | 

*响应*
```
HTTP 200 OK
```
```
{
    { "services": [],
      "routes": []
    }
}
```
响应包含从输入文件中解析的所有实体的列表。

## 标签

标签是与Kong中的实体相关联的字符串。每个标签必须由一个或多个字母数字字符`_`，`-`，`.`或`~`组成。

多数核心实体可以在创建或版本时通过其`tags`属性进行标签。

标签还可以通过`?tags` querystring参数用于过滤核心实体。

例如：如果通常通过执行以下操作获得所有服务的列表：
```
GET /services
```

您可以通过执行以下操作获取所有带服务标签示例的列表：
```
GET /services?tags=example
```

同样，如果您要过滤Services，以便仅获得带有标签的`example`和`admin`，则可以这样进行：
```
GET /services?tags=example,admin
```

最后，如果您想过滤带有Services标签的`example`和`admin`，则可以使用
```
GET /services?tags=example/admin
```

一些小贴士：
- 单个请求中最多可以同时使用`，`或`/`来查询5个标签。
- 不支持混合运算符：如果尝试在同一查询字符串中将`,`与`/`混合，则会收到错误消息。
- 从命令行使用某些字符时，可能需要引用和/或转义一些字符。
- 外键关系端点不支持按标签过滤。例如，在诸如`GET /services/foo/routes?tags=a,b`之类的请求中，tags参数将被忽略。
- 如果更改或删除了`tags`参数，则不能保证`offset`参数会起作用

### 列出所有标签

返回系统中所有标签的分页列表。

实体列表将不限于单个实体类型：所有标记了标签的实体都将出现在此列表中。

如果一个实体被多个标签标记，则该实体的`entity_id`将在结果列表中出现多次。
同样，如果几个实体已使用同一标签标记，则该标签将出现在此列表的多个项目中。
```
GET /tags
```
**响应**
```
HTTP 200 OK
```
```
{
    {
      "data": [
        { "entity_name": "services",
          "entity_id": "acf60b10-125c-4c1a-bffe-6ed55daefba4",
          "tag": "s1",
        },
        { "entity_name": "services",
          "entity_id": "acf60b10-125c-4c1a-bffe-6ed55daefba4",
          "tag": "s2",
        },
        { "entity_name": "routes",
          "entity_id": "60631e85-ba6d-4c59-bd28-e36dd90f6000",
          "tag": "s1",
        },
        ...
      ],
      "offset" = "c47139f3-d780-483d-8a97-17e9adc5a7ab",
      "next" = "/tags?offset=c47139f3-d780-483d-8a97-17e9adc5a7ab",
    }
}
```

### 按标签列出实体ID

返回已被指定标签标记的实体。

实体列表将不限于单个实体类型：所有标记了标签的实体都将出现在此列表中。

```
GET /tags/:tags
```
**响应**
```
HTTP 200 OK
```
```
{
    {
      "data": [
        { "entity_name": "services",
          "entity_id": "c87440e1-0496-420b-b06f-dac59544bb6c",
          "tag": "example",
        },
        { "entity_name": "routes",
          "entity_id": "8a99e4b1-d268-446b-ab8b-cd25cff129b1",
          "tag": "example",
        },
        ...
      ],
      "offset" = "1fb491c4-f4a7-4bca-aeba-7f3bcee4d2f9",
      "next" = "/tags/example?offset=1fb491c4-f4a7-4bca-aeba-7f3bcee4d2f9",
    }
}
```

## Service 对象

顾名思义，Service实体是您自己的每个上游服务的抽象。服务的示例将是数据转换微服务，计费API等。

Service的主要属性是其URL（Kong应该将流量代理到此URL），可以将其设置为单个字符串，也可以通过单独指定其`protocol`，`host`，`port`和`path`来设置。

Service与Routes关联（一个Service可以有许多与之关联的Routes）。Routes是Kong中的入口点，并定义规则以匹配客户请求。
Route匹配后，Kong将请求代理到其关联的服务。有关Kong代理流量的详细说明，请参阅[代理参考](https://docs.konghq.com/1.3.x/proxy)。

Service可以通过[标签进行标记和过滤](https://docs.konghq.com/1.3.x/db-less-admin-api/#tags)
```
{
    "id": "9748f662-7711-4a90-8186-dc02f10eb0f5",
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
    "read_timeout": 60000,
    "tags": ["user-level", "low-priority"],
    "client_certificate": {"id":"4e3ad2e4-0bc4-4638-8e34-c84a417ba39b"}
}

```


### Service 列表

#### 列出所有Service

```
GET /services
```

#### 列出与特定Certificate相关的Service

```
GET /certificates/{certificate name or id}/services
```

| 属性 | 描述 | 
| --- | ---- |
| `certificate name or id` <br> required | 要检索其Services的Certificate的唯一标识符或`name`属性。使用此端点时，将仅列出与指定证书关联的服务。 |

*响应*
```
HTTP 200 OK
```

```
{
"data": [{
    "id": "a5fb8d9b-a99d-40e9-9d35-72d42a62d83a",
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
    "read_timeout": 60000,
    "tags": ["user-level", "low-priority"],
    "client_certificate": {"id":"51e77dc2-8f3e-4afa-9d0e-0e3bbbcfd515"}
}, {
    "id": "fc73f2af-890d-4f9b-8363-af8945001f7f",
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
    "read_timeout": 60000,
    "tags": ["admin", "high-priority", "critical"],
    "client_certificate": {"id":"4506673d-c825-444c-a25b-602e3c2ec16e"}
}],

    "next": "http://localhost:8001/services?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```

### Service 检索

#### 检索Service

```
GET /services/{name or id}
```

| 属性 | 描述 | 
| --- | ---- |
| `name or id` <br> required | 要检索的Service的唯一标识符或名称。 |

#### 检索与特定Route关联的Service

```
GET /routes/{route name or id}/service
```

| 属性 | 描述 | 
| --- | ---- |
| `route name or id` <br> required | 与要检索的服务关联的唯一标识符或route的名称。 |

#### 检索与特定插件相关的Service

```
GET /plugins/{plugin id}/service
```

| 属性 | 描述 | 
| --- | ---- |
| `plugin id` <br> required | 与要检索的Service关联的插件的唯一标识符。。 |

*响应*
```
HTTP 200 OK
```

```
{
    "id": "9748f662-7711-4a90-8186-dc02f10eb0f5",
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
    "read_timeout": 60000,
    "tags": ["user-level", "low-priority"],
    "client_certificate": {"id":"4e3ad2e4-0bc4-4638-8e34-c84a417ba39b"}
}
```

## Route 对象

Route 实体定义规则以匹配客户端请求。每个 Route 都与 Service 关联，并且一个 Service 可能具有与其关联的多个 Route。
匹配给定路线的每个请求都将被代理到其关联的 Service。

Route 和 Service 的组合（以及它们之间的关注点分离）提供了一种强大的路由机制，通过它可以在Kong中定义细粒度的入口点，从而导致基础结构的不同上游服务。

您需要至少一个匹配规则，该规则适用于路由要匹配的协议。
取决于配置为与路由匹配的协议（如协议字段所定义），这意味着必须设置以下属性中的至少一个：

- 对于`http`，至少是`methods`，`hosts`，`headers`,`paths`其中之一；
- 对于`https`，至少是`methods`，`hosts`，`headers`,`paths`,`snis`其中之一；
- 对于`tcp`，至少是`sources`，`destinations`其中之一
- 对于`tls`，至少是`sources`，`destinations`，`snis`其中之一
- 对于`grpc`，`hosts`，`headers`,`paths`其中之一；
- 对于`grpcs`，`hosts`，`headers`,`paths`，`snis`其中之一。

Routes 可以通过[标签进行标记和过滤](https://docs.konghq.com/1.3.x/db-less-admin-api/#tags)。
```
{
    "id": "d35165e2-d03e-461a-bdeb-dad0a112abfe",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-route",
    "protocols": ["http", "https"],
    "methods": ["GET", "POST"],
    "hosts": ["example.com", "foo.test"],
    "paths": ["/foo", "/bar"],
    "headers": {"x-another-header":["bla"], "x-my-header":["foo", "bar"]},
    "https_redirect_status_code": 426,
    "regex_priority": 0,
    "strip_path": true,
    "preserve_host": false,
    "tags": ["user-level", "low-priority"],
    "service": {"id":"af8330d3-dbdc-48bd-b1be-55b98608834b"}
}
```

### Route 列表

#### 列出所有 Route 

```
GET /routes
```

#### 列出与特定Service关联的 Route
```
GET /services/{service name or id}/routes
```

| 属性 | 描述 | 
| --- | ---- |
| `service name or id` <br> required | 要检索其Route的service的唯一标识符或`name`属性。使用此端点时，仅列出与指定service关联的Route。 |

*响应*
```
HTTP 200 OK
```
```
{
"data": [{
    "id": "a9daa3ba-8186-4a0d-96e8-00d80ce7240b",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-route",
    "protocols": ["http", "https"],
    "methods": ["GET", "POST"],
    "hosts": ["example.com", "foo.test"],
    "paths": ["/foo", "/bar"],
    "headers": {"x-another-header":["bla"], "x-my-header":["foo", "bar"]},
    "https_redirect_status_code": 426,
    "regex_priority": 0,
    "strip_path": true,
    "preserve_host": false,
    "tags": ["user-level", "low-priority"],
    "service": {"id":"127dfc88-ed57-45bf-b77a-a9d3a152ad31"}
}, {
    "id": "9aa116fd-ef4a-4efa-89bf-a0b17c4be982",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-route",
    "protocols": ["tcp", "tls"],
    "https_redirect_status_code": 426,
    "regex_priority": 0,
    "strip_path": true,
    "preserve_host": false,
    "snis": ["foo.test", "example.com"],
    "sources": [{"ip":"10.1.0.0/16", "port":1234}, {"ip":"10.2.2.2"}, {"port":9123}],
    "destinations": [{"ip":"10.1.0.0/16", "port":1234}, {"ip":"10.2.2.2"}, {"port":9123}],
    "tags": ["admin", "high-priority", "critical"],
    "service": {"id":"ba641b07-e74a-430a-ab46-94b61e5ea66b"}
}],

    "next": "http://localhost:8001/routes?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```

### Route 检索

#### 检索 route

```
GET /routes/{name or id}
```

| 属性 | 描述 | 
| --- | ---- |
| `name or id` <br> required | 要检索的唯一标识符或路线名称。 |

#### 检索与特定插件关联的route

```
GET /plugins/{plugin id}/route
```

| 属性 | 描述 | 
| --- | ---- |
| `plugin id` <br> required | 与要检索的路线相关联的插件的唯一标识符。 |

*响应*
```
HTTP 200 OK
```
```
{
    "id": "d35165e2-d03e-461a-bdeb-dad0a112abfe",
    "created_at": 1422386534,
    "updated_at": 1422386534,
    "name": "my-route",
    "protocols": ["http", "https"],
    "methods": ["GET", "POST"],
    "hosts": ["example.com", "foo.test"],
    "paths": ["/foo", "/bar"],
    "headers": {"x-another-header":["bla"], "x-my-header":["foo", "bar"]},
    "https_redirect_status_code": 426,
    "regex_priority": 0,
    "strip_path": true,
    "preserve_host": false,
    "tags": ["user-level", "low-priority"],
    "service": {"id":"af8330d3-dbdc-48bd-b1be-55b98608834b"}
}
```

## Consumer 对象

Consumer对象代表服务的消费者或用户。您可以依靠Kong作为主要数据存储，也可以将使用者列表与数据库进行映射，以保持Kong和现有主要数据存储之间的一致性。

Consumer 可以通过[标签进行标记和过滤](https://docs.konghq.com/1.3.x/db-less-admin-api/#tags)。

```
{
    "id": "ec1a1f6f-2aa4-4e58-93ff-b56368f19b27",
    "created_at": 1422386534,
    "username": "my-username",
    "custom_id": "my-custom-id",
    "tags": ["user-level", "low-priority"]
}
```

### Consumer 列表

#### 列出所有 Consumers

```
GET /consumers
```
*响应*
```
HTTP 200 OK
```
```
{
"data": [{
    "id": "a4407883-c166-43fd-80ca-3ca035b0cdb7",
    "created_at": 1422386534,
    "username": "my-username",
    "custom_id": "my-custom-id",
    "tags": ["user-level", "low-priority"]
}, {
    "id": "01c23299-839c-49a5-a6d5-8864c09184af",
    "created_at": 1422386534,
    "username": "my-username",
    "custom_id": "my-custom-id",
    "tags": ["admin", "high-priority", "critical"]
}],

    "next": "http://localhost:8001/consumers?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```

### Consumer 检索

#### 检索 Consumers


```
GET /consumers/{username or id}
```

| 属性 | 描述 | 
| --- | ---- |
| `username or id` <br> required | 要检索的consumer的唯一标识符或用户名。 |

#### 检索与特定插件相关的使用者

| 属性 | 描述 | 
| --- | ---- |
| `plugin id` <br> required | 与要检索的consumer相关联的插件的唯一标识符。 |


*响应*
```
HTTP 200 OK
```
```
{
    "id": "ec1a1f6f-2aa4-4e58-93ff-b56368f19b27",
    "created_at": 1422386534,
    "username": "my-username",
    "custom_id": "my-custom-id",
    "tags": ["user-level", "low-priority"]
}
```


## 插件对象

插件实体表示将在HTTP请求/响应生命周期内执行的插件配置。
通过这种方法，您可以为在Kong后面运行的服务添加功能，例如身份验证或速率限制。
您可以通过访问[Kong Hub](https://docs.konghq.com/hub/)来找到有关如何安装以及每个插件采用什么值的更多信息。

当向service添加插件配置时，客户端对该service的每个请求都将运行所述插件。
如果某个插件需要针对某些特定使用者调整为不同的值，则可以通过在service和使用者字段中创建一个单独的插件实例来指定`service`和`consumer`，从而做到这一点。

插件可以通过[标签进行标记和过滤](https://docs.konghq.com/1.3.x/db-less-admin-api/#tags)。

```
{
    "id": "ce44eef5-41ed-47f6-baab-f725cecf98c7",
    "name": "rate-limiting",
    "created_at": 1422386534,
    "route": null,
    "service": null,
    "consumer": null,
    "config": {"minute":20, "hour":500},
    "run_on": "first",
    "protocols": ["http", "https"],
    "enabled": true,
    "tags": ["user-level", "low-priority"]
}

```

有关更多详细信息，请参见下面的“优先级”部分。

### 优先级

插件将始终运行一次，并且每个请求只能运行一次。
但是它将运行的配置取决于为其配置的实体。

可以为各种实体，实体组合甚至全局配置插件。
例如，当您希望以某种方式为大多数请求配置插件，使经过*身份验证*的请求的行为略有不同时。

因此，当插件被应用到具有不同配置的不同实体时，它的优先级是有顺序的。经验法则是:插件配置的实体越多，它的优先级就越高。

多次配置插件后，完整的优先级顺序为：

1. 在以下各项的组合上配置的插件：Route，Service 和 Consumer。（Consumer 意味着必须对请求进行身份验证）。
2. 在 Route 和 Consumer 的组合上配置的插件。（Consumer 意味着必须对请求进行身份验证）。
3. 在 Service 和 Consumer 的组合上配置的插件。（Consumer 意味着必须对请求进行身份验证）。
4. 在 Route 和 Service 的组合上配置的插件。
5. 在 Consumer 者上配置的插件。（Consumer 意味着必须对请求进行身份验证）。
6. 在 Route 上配置的插件。
7. 在 Service 上配置的插件。
8. 配置为全局运行的插件。

**例子：**如果速率限制插件应用了两次（使用不同的配置）：对于Service（插件配置A）和Consumer（插件配置B），则请求对此消Consumer者进行身份验证的请求将运行插件配置B并忽略A。但是，不验证此Consumer的请求将回退到运行插件configA。请注意，如果禁用了config B（其启用标志设置为false），则config A将应用于与config B匹配的请求。

### 插件列表

#### 列出所有插件

```
GET /plugins
```

#### 列出与指定 Route 关联的插件

```
GET /routes/{route id}/plugins
```
| 属性 | 描述 | 
| --- | ---- |
| `route id` <br> required | 要获取其插件的Route的唯一标识符。使用此端点时，将仅列出与指定Route关联的插件。 |

#### 列出与指定 Service 关联的插件

```
GET /services/{service id}/plugins
```

| 属性 | 描述 | 
| --- | ---- |
| `service id` <br> required | 要检索其插件的service的唯一标识符。使用此端点时，将仅列出与指定service关联的插件。 |

#### 列出与指定 Consumer 关联的插件

```
GET /consumers/{consumer id}/plugins
```

| 属性 | 描述 | 
| --- | ---- |
| `consumer id` <br> required | 要检索其插件的Consumer的唯一标识符。使用此端点时，将仅列出与指定Consumer相关联的插件。 |

*响应*
```
HTTP 200 OK
```
```
{
"data": [{
    "id": "02621eee-8309-4bf6-b36b-a82017a5393e",
    "name": "rate-limiting",
    "created_at": 1422386534,
    "route": null,
    "service": null,
    "consumer": null,
    "config": {"minute":20, "hour":500},
    "run_on": "first",
    "protocols": ["http", "https"],
    "enabled": true,
    "tags": ["user-level", "low-priority"]
}, {
    "id": "66c7b5c4-4aaf-4119-af1e-ee3ad75d0af4",
    "name": "rate-limiting",
    "created_at": 1422386534,
    "route": null,
    "service": null,
    "consumer": null,
    "config": {"minute":20, "hour":500},
    "run_on": "first",
    "protocols": ["tcp", "tls"],
    "enabled": true,
    "tags": ["admin", "high-priority", "critical"]
}],

    "next": "http://localhost:8001/plugins?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```

### 插件检索
#### 插件检索
```
GET /plugins/{plugin id}
```
| 属性 | 描述 | 
| --- | ---- |
| `plugin id` <br> required | 要检索的插件的唯一标识符。 |

*响应*
```
HTTP 200 OK
```
```
{
    "id": "ce44eef5-41ed-47f6-baab-f725cecf98c7",
    "name": "rate-limiting",
    "created_at": 1422386534,
    "route": null,
    "service": null,
    "consumer": null,
    "config": {"minute":20, "hour":500},
    "run_on": "first",
    "protocols": ["http", "https"],
    "enabled": true,
    "tags": ["user-level", "low-priority"]
}
```

### 已启用的插件检索

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
### 插件schema检索

检索插件配置的schema。
这有助于了解插件接受哪些字段，并且可用于与Kong的插件系统建立第三方集成。
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

## 证书对象

证书对象表示一个公共证书，可以选择与对应的私钥配对。Kong使用这些对象来处理加密请求的SSL/TLS终止，或在验证客户端/服务的对等证书时用作受信任的CA存储。证书可选地与SNI对象相关联，以将证书/密钥对绑定到一个或多个主机名。

如果除了主证书之外还需要中间证书，那么应该按照以下顺序将它们连接到一个字符串中:主证书在顶部，然后是任何中间证书。

证书可以通过[标签进行标记和过滤](https://docs.konghq.com/1.3.x/db-less-admin-api/#tags)。
```
{
    "id": "7fca84d6-7d37-4a74-a7b0-93e576089a41",
    "created_at": 1422386534,
    "cert": "-----BEGIN CERTIFICATE-----...",
    "key": "-----BEGIN RSA PRIVATE KEY-----...",
    "tags": ["user-level", "low-priority"]
}
```

### 证书列表

#### 列出所有证书
```
GET /certificates
```
*响应*
```
HTTP 200 OK
```
```
{
"data": [{
    "id": "d044b7d4-3dc2-4bbc-8e9f-6b7a69416df6",
    "created_at": 1422386534,
    "cert": "-----BEGIN CERTIFICATE-----...",
    "key": "-----BEGIN RSA PRIVATE KEY-----...",
    "tags": ["user-level", "low-priority"]
}, {
    "id": "a9b2107f-a214-47b3-add4-46b942187924",
    "created_at": 1422386534,
    "cert": "-----BEGIN CERTIFICATE-----...",
    "key": "-----BEGIN RSA PRIVATE KEY-----...",
    "tags": ["admin", "high-priority", "critical"]
}],

    "next": "http://localhost:8001/certificates?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```

### 证书检索
```
GET /certificates/{certificate id}
```
| 属性 | 描述 | 
| --- | ---- |
| `certificate id` <br> required | 要检索的证书的唯一标识符。 |

*响应*
```
HTTP 200 OK
```
```
{
    "id": "7fca84d6-7d37-4a74-a7b0-93e576089a41",
    "created_at": 1422386534,
    "cert": "-----BEGIN CERTIFICATE-----...",
    "key": "-----BEGIN RSA PRIVATE KEY-----...",
    "tags": ["user-level", "low-priority"]
}
```

## SNI 对象

### SNI 列表
#### 列出所有 SNIs
```
GET /snis
```
#### 列出与特定证书关联的SNIs
```
GET /certificates/{certificate name or id}/snis
```

| 属性 | 描述 | 
| --- | ---- |
| `certificate name or id` <br> required | 要检索其SNI的证书的唯一标识符或`name`属性。使用此端点时，将仅列出与指定证书关联的SNI。 |
*响应*
```
HTTP 200 OK
```
```
{
"data": [{
    "id": "a9b2107f-a214-47b3-add4-46b942187924",
    "name": "my-sni",
    "created_at": 1422386534,
    "tags": ["user-level", "low-priority"],
    "certificate": {"id":"04fbeacf-a9f1-4a5d-ae4a-b0407445db3f"}
}, {
    "id": "43429efd-b3a5-4048-94cb-5cc4029909bb",
    "name": "my-sni",
    "created_at": 1422386534,
    "tags": ["admin", "high-priority", "critical"],
    "certificate": {"id":"d26761d5-83a4-4f24-ac6c-cff276f2b79c"}
}],

    "next": "http://localhost:8001/snis?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```

### SNI 检索

#### 检索 SNIs
```
GET /snis/{name or id}
```

| 属性 | 描述 | 
| --- | ---- |
| `name or id` <br> required | 要检索的SNI的唯一标识符或名称。 |

*响应*
```
HTTP 200 OK
```
```
{
    "id": "7fca84d6-7d37-4a74-a7b0-93e576089a41",
    "name": "my-sni",
    "created_at": 1422386534,
    "tags": ["user-level", "low-priority"],
    "certificate": {"id":"d044b7d4-3dc2-4bbc-8e9f-6b7a69416df6"}
}

```
## Upstream 对象

上游对象代表虚拟主机名，可用于对多个服务（目标）上的传入请求进行负载平衡。
因此，例如，上游主机名为`service.v1.xyz`的Service对象的`host`机是`service.v1.xyz`。
对该服务的请求将被代理到上游定义的目标。

上游还包括运行[状况检查器](https://docs.konghq.com/1.1.x/health-checks-circuit-breakers)，该检查器能够根据目标是否能够满足请求来启用和禁用目标。健康状况检查器的配置存储在上游对象中，并应用于其所有目标。

上游可以通过[标签进行标记和过滤](https://docs.konghq.com/1.1.x/db-less-admin-api/#tags)。

```
{
    "id": "91020192-062d-416f-a275-9addeeaffaf2",
    "created_at": 1422386534,
    "name": "my-upstream",
    "hash_on": "none",
    "hash_fallback": "none",
    "hash_on_cookie_path": "/",
    "slots": 10000,
    "healthchecks": {
        "active": {
            "https_verify_certificate": true,
            "unhealthy": {
                "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505],
                "tcp_failures": 0,
                "timeouts": 0,
                "http_failures": 0,
                "interval": 0
            },
            "http_path": "/",
            "timeout": 1,
            "healthy": {
                "http_statuses": [200, 302],
                "interval": 0,
                "successes": 0
            },
            "https_sni": "example.com",
            "concurrency": 10,
            "type": "http"
        },
        "passive": {
            "unhealthy": {
                "http_failures": 0,
                "http_statuses": [429, 500, 503],
                "tcp_failures": 0,
                "timeouts": 0
            },
            "type": "http",
            "healthy": {
                "successes": 0,
                "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]
            }
        }
    },
    "tags": ["user-level", "low-priority"]
}
```
### Upstream 列表

#### 列出所有Upstreams
```
GET /upstreams
```
*响应*
```
HTTP 200 OK
```
```
{
"data": [{
    "id": "a2e013e8-7623-4494-a347-6d29108ff68b",
    "created_at": 1422386534,
    "name": "my-upstream",
    "hash_on": "none",
    "hash_fallback": "none",
    "hash_on_cookie_path": "/",
    "slots": 10000,
    "healthchecks": {
        "active": {
            "https_verify_certificate": true,
            "unhealthy": {
                "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505],
                "tcp_failures": 0,
                "timeouts": 0,
                "http_failures": 0,
                "interval": 0
            },
            "http_path": "/",
            "timeout": 1,
            "healthy": {
                "http_statuses": [200, 302],
                "interval": 0,
                "successes": 0
            },
            "https_sni": "example.com",
            "concurrency": 10,
            "type": "http"
        },
        "passive": {
            "unhealthy": {
                "http_failures": 0,
                "http_statuses": [429, 500, 503],
                "tcp_failures": 0,
                "timeouts": 0
            },
            "type": "http",
            "healthy": {
                "successes": 0,
                "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]
            }
        }
    },
    "tags": ["user-level", "low-priority"]
}, {
    "id": "147f5ef0-1ed6-4711-b77f-489262f8bff7",
    "created_at": 1422386534,
    "name": "my-upstream",
    "hash_on": "none",
    "hash_fallback": "none",
    "hash_on_cookie_path": "/",
    "slots": 10000,
    "healthchecks": {
        "active": {
            "https_verify_certificate": true,
            "unhealthy": {
                "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505],
                "tcp_failures": 0,
                "timeouts": 0,
                "http_failures": 0,
                "interval": 0
            },
            "http_path": "/",
            "timeout": 1,
            "healthy": {
                "http_statuses": [200, 302],
                "interval": 0,
                "successes": 0
            },
            "https_sni": "example.com",
            "concurrency": 10,
            "type": "http"
        },
        "passive": {
            "unhealthy": {
                "http_failures": 0,
                "http_statuses": [429, 500, 503],
                "tcp_failures": 0,
                "timeouts": 0
            },
            "type": "http",
            "healthy": {
                "successes": 0,
                "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]
            }
        }
    },
    "tags": ["admin", "high-priority", "critical"]
}],

    "next": "http://localhost:8001/upstreams?offset=6378122c-a0a1-438d-a5c6-efabae9fb969"
}
```

### Upstream 检索

#### 检索 Upstreams
```
GET /upstreams/{name or id}
```
| 属性 | 描述 | 
| --- | ---- |
| `name or id` <br> required | 要检索的Upstream的唯一标识符或名称。 |

### 检索与指定Target相关的Upstream

```
GET /targets/{target host:port or id}/upstream
```
| 属性 | 描述 | 
| --- | ---- |
| `target host:port or id` <br> required | 与要检索的上游关联的目标的唯一标识符或host：port。 |

*响应*
```
HTTP 200 OK
```
```
{
    "id": "91020192-062d-416f-a275-9addeeaffaf2",
    "created_at": 1422386534,
    "name": "my-upstream",
    "hash_on": "none",
    "hash_fallback": "none",
    "hash_on_cookie_path": "/",
    "slots": 10000,
    "healthchecks": {
        "active": {
            "https_verify_certificate": true,
            "unhealthy": {
                "http_statuses": [429, 404, 500, 501, 502, 503, 504, 505],
                "tcp_failures": 0,
                "timeouts": 0,
                "http_failures": 0,
                "interval": 0
            },
            "http_path": "/",
            "timeout": 1,
            "healthy": {
                "http_statuses": [200, 302],
                "interval": 0,
                "successes": 0
            },
            "https_sni": "example.com",
            "concurrency": 10,
            "type": "http"
        },
        "passive": {
            "unhealthy": {
                "http_failures": 0,
                "http_statuses": [429, 500, 503],
                "tcp_failures": 0,
                "timeouts": 0
            },
            "type": "http",
            "healthy": {
                "successes": 0,
                "http_statuses": [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]
            }
        }
    },
    "tags": ["user-level", "low-priority"]
}
```

### 显示节点的Upstream运行状况

根据特定Kong节点的透视图显示给定Upstream的所有Target的健康状态。注意，作为特定于节点的信息，对Kong集群的不同节点发出相同的请求可能会产生不同的结果。例如,Kong 的一个特定节点集群可能遇到网络问题,导致无法连接到一些Target:这些Target将由该节点标记为不健康(将此节点的流量引导到它可以成功到达的其他Target),但健康的所有其他Kong节点(使用这一Target没有问题)。

响应的`data`字段包含Target对象的数组。
每个Target的运行状况在其`health`字段中返回：

- 如果由于DNS问题而无法在环形负载均衡器中激活目标，则其状态将显示为`DNS_ERROR`。
- 如果在上游配置中未启用运行[健康检查](https://docs.konghq.com/1.1.x/health-checks-circuit-breakers)，则活动目标的运行状况将显示为`HEALTHCHECKS_OFF`。
- 启用健康检查并自动或[手动](https://docs.konghq.com/1.1.x/db-less-admin-api/#set-target-as-healthy)确定目标为健康后，其状态将显示为`HEALTHY`。这意味着此目标当前已包含在此上游的负载均衡器环中。
- 通过主动或被动运行状况检查（断路器）或手动禁用目标后，其状态将显示为`UNHEALTHY`。负载平衡器不会通过此上游将任何流量定向到该目标。

```
GET /upstreams/{name or id}/health/
```
| 属性 | 描述 | 
| --- | ---- |
| `name or id` <br> required | 要为其显示目标运行状况的唯一标识符或上游名称。 |

*响应*
```
HTTP 200 OK
```
```
{
    "total": 2,
    "node_id": "cbb297c0-14a9-46bc-ad91-1d0ef9b42df9",
    "data": [
        {
            "created_at": 1485524883980,
            "id": "18c0ad90-f942-4098-88db-bbee3e43b27f",
            "health": "HEALTHY",
            "target": "127.0.0.1:20000",
            "upstream_id": "07131005-ba30-4204-a29f-0927d53257b4",
            "weight": 100
        },
        {
            "created_at": 1485524914883,
            "id": "6c6f34eb-e6c3-4c1f-ac58-4060e5bca890",
            "health": "UNHEALTHY",
            "target": "127.0.0.1:20002",
            "upstream_id": "07131005-ba30-4204-a29f-0927d53257b4",
            "weight": 200
        }
    ]
}
```

## Target 对象
### Target 列表
### 将Target设定为健康
### 将Target设置为不健康
### 所有Target列表
















