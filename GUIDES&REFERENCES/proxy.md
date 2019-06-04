# 代理

## 简介

在本文档中，我们将通过详细解释其路由功能和内部工作原理，来了解Kong的代理功能。

Kong公开了几个可以通过两个配置属性调整的接口：

- `proxy_listen`：它定义了一个地址/端口列表，Kong将接受来自客户端的公共流量并将其代理到您的上游服务（默认为`8000`）。
- `admin_listen`：它还定义了一个地址和端口列表，但是这些应该被限制为仅由管理员访问，因为它们暴露了Kong的配置功能：Admin API（默认为`8001`）。

> 注意：从1.0.0开始，API实体已被删除。本文档将介绍使用新路由和服务实体进行代理。  
> 如果您使用的是0.12或更低版本，请参阅本文档的旧版本。

## 相关术语

- `client`：指下游 downstream 客户向Kong的代理端口发出请求。
- `upstream service`：指位于Kong后面的您自己的 API/service ，转发客户端请求。
- `Service`：顾名思义，服务实体是每个上游服务的抽象。比如说服务可以是数据转换微服务，一个计费API等。
- `Route`：这是指Kong Routes实体。路由是进入Kong的入口点，并定义要匹配的请求的规则，并路由到给定的服务。
- `Plugin`：这指的是Kong“插件”，它们是在代理生命周期中运行的业务逻辑。可以通过Admin API配置插件 - 全局（所有传入流量）或特定路由和服务。

## 概览

从高层次的角度来看，Kong在其配置的代理端口上监听HTTP流量（默认情况下为`8000`和`8443`）。Kong将根据您配置的路由评估任何传入的HTTP请求，并尝试查找匹配的路由。如果给定的请求与特定Route的规则匹配，Kong将处理代理请求。由于每个Route都链接到一个Service，因此Kong将运行您在Route及其相关服务上配置的插件，然后在上游代理请求。

您可以通过Kong的Admin API管理Routes。Routes 的机 `hosts`，`psths`和 `methods` 属性定义用于匹配传入HTTP请求的规则。

如果Kong收到的请求无法与任何已配置的路由匹配（或者如果没有配置路由），它将响应：
```
HTTP/1.1 404 Not Found
Content-Type: application/json
Server: kong/<x.x.x>

{
    "message": "no route and no Service found with those values"
}
```

## 提醒：如何配置服务

[配置服务](https://docs.konghq.com/1.1.x/getting-started/configuring-a-service)快速入门指南介绍了如何通过[Admin API]配置Kong。

通过向Admin API发送HTTP请求来向Kong添加服务：
```
curl -i -X POST http://localhost:8001/services/ \
    -d 'name=foo-service' \
    -d 'url=http://foo-service.com'
HTTP/1.1 201 Created
...

{
    "connect_timeout": 60000,
    "created_at": 1515537771,
    "host": "foo-service.com",
    "id": "d54da06c-d69f-4910-8896-915c63c270cd",
    "name": "foo-service",
    "path": "/",
    "port": 80,
    "protocol": "http",
    "read_timeout": 60000,
    "retries": 5,
    "updated_at": 1515537771,
    "write_timeout": 60000
}
```

该请求指示Kong注册一个名为“foo-service”的服务，该服务指向`http://foo-service.com`（上游）。

注意：`url`参数是一个简化参数，用于一次性添加`protocol`，`host`，`port`和`path`。

现在，为了通过Kong向这个服务发送流量，我们需要指定一个Route，它作为Kong的入口点：
```
curl -i -X POST http://localhost:8001/routes/ \
    -d 'hosts[]=example.com' \
    -d 'paths[]=/foo' \
    -d 'service.id=d54da06c-d69f-4910-8896-915c63c270cd'
HTTP/1.1 201 Created
...

{
    "created_at": 1515539858,
    "hosts": [
        "example.com"
    ],
    "id": "ee794195-6783-4056-a5cc-a7e0fde88c81",
    "methods": null,
    "paths": [
        "/foo"
    ],
    "preserve_host": false,
    "priority": 0,
    "protocols": [
        "http",
        "https"
    ],
    "service": {
        "id": "d54da06c-d69f-4910-8896-915c63c270cd"
    },
    "strip_path": true,
    "updated_at": 1515539858
}
```

我们现在已经配置了一个Route来匹配与给定`host`和`path`匹配的传入请求，并将它们转发到我们配置的`foo-service`，从而将此流量代理到`http://foo-service.com`。

## 路由和匹配功能

现在让我们讨论Kong如何匹配针对路由的已配置`host`，`path`和`methods`属性（或字段）的请求。请注意，所有这三个字段都是可选的，但必须至少指定其中一个。

对于匹配路线的请求：
- 请求必须包含所有已配置的字段
- 请求中的字段值必须至少与其中一个配置值匹配（当字段配置接受一个或多个值时，请求只需要其中一个值被视为匹配）

我们来看几个例子。考虑如下配置的路由：

```
{
    "hosts": ["example.com", "foo-service.com"],
    "paths": ["/foo", "/bar"],
    "methods": ["GET"]
}
```

与此Route匹配的一些可能请求如下所示：

```
GET /foo HTTP/1.1
Host: example.com
```
```
GET /bar HTTP/1.1
Host: foo-service.com
```
```
GET /foo/hello/world HTTP/1.1
Host: example.com
```

所有这三个请求都满足路径定义中设置的所有条件。但是，以下请求与配置的条件不匹配：
```
GET / HTTP/1.1
Host: example.com
```
```
POST /foo HTTP/1.1
Host: example.com
```
```
GET /foo HTTP/1.1
Host: foo.com
```

所有这三个请求仅满足两个配置条件。第一个请求的路径不匹配配置的路径，第二个请求的HTTP方法和第三个请求的host头也均不匹配。

现在我们了解了`hosts`, `paths`, 和 `methods`属性如何协同工作，让我们分别来看每个属性。

### host 请求头

基于其host header 来路由请求是通过Kong代理流量的最直接方式，特别是因为这是HTTP host header 的预期用途。Kong可以通过Route实体的`hosts`字段轻松完成。

`hosts`接受多个值，在通过Admin API指定它们时必须以逗号分隔：

`hosts`接受多个值，这些值很容易在JSON有效负载中表示：
```
curl -i -X POST http://localhost:8001/routes/ \
    -H 'Content-Type: application/json' \
    -d '{"hosts":["example.com", "foo-service.com"]}'
HTTP/1.1 201 Created
...
```

但由于Admin API还支持form-urlencoded内容类型，因此您可以通过`[]`表示法指定数组：

```
curl -i -X POST http://localhost:8001/routes/ \
    -d 'hosts[]=example.com' \
    -d 'hosts[]=foo-service.com'
HTTP/1.1 201 Created
...
```

要满足此Route的`hosts`条件，来自客户端的任何传入请求现在必须将其Host header 设置为以下之一：
```
Host: example.com
```

或者

```
Host: foo-service.com
```

#### 使用通配符主机名

为了提供灵活性，Kong允许您在`hosts`字段中指定带通配符的主机名。通配符主机名允许任何匹配的host满足条件，从而匹配给定的Route。

通配符主机名**必须**在域的最左侧或最右侧标签中**仅包含**一个星号。例子：

- `*.example.com `将匹配诸如`a.example.com` 和 `x.y.example.com`
- `example.*` 将匹配诸如`example.com` 和 `example.org`

一个完整的例子如下所示：
```
{
    "hosts": ["*.example.com", "service.com"]
}
```

将允许以下请求匹配此路由：
```
GET / HTTP/1.1
Host: an.example.com
```
```
GET / HTTP/1.1
Host: service.com
```

#### `preserve_host`属性

代理时，Kong的默认行为是将上游请求的主机头设置为服务主机中指定的`host`。`preserve_host`字段接受一个布尔标志，指示Kong不要这样做。

例如，当preserve_host属性未更改且Route配置如下：
```
{
    "hosts": ["service.com"],
    "service": {
        "id": "..."
    }
}
```
client对Kong的可能请求可能是：
```
GET / HTTP/1.1
Host: service.com
```

Kong将从Service的主机属性中提取Host头值，并将发送以下上游请求：
```
GET / HTTP/1.1
Host: <my-service-host.com>
```

但是，通过使用`preserve_host=true`配置Route：

```
{
    "hosts": ["service.com"],
    "preserve_host": true,
    "service": {
        "id": "..."
    }
}
```

并假设来自客户的相同请求：

```
GET / HTTP/1.1
Host: service.com
```

Kong将根据客户端请求保留Host，并将发送以下上游请求：

```
GET / HTTP/1.1
Host: service.com
```

### 请求路径

路由匹配的另一种方式是通过请求路径。
要满足此路由条件，客户端请求的路径必须以`paths`属性的值之一为前缀。
例如，使用如下配置的Route：
```
{
    "paths": ["/service", "/hello/world"]
}
```
以下请求将被匹配：
```
GET /service HTTP/1.1
Host: example.com
```
```
GET /service/resource?param=value HTTP/1.1
Host: example.com
```
```
GET /hello/world/resource HTTP/1.1
Host: anything.com
```

对于这些请求中的每一个，Kong检测到其URL路径以路由的`paths`之一为前缀。默认情况下，Kong会在不更改URL路径的情况下代理上游请求。

使用路径前缀进行代理时，**首先评估最长路径**。这允许您定义两个具有两个路径的Routes：`/service`和`/service/resource`，并确保前者不会“遮蔽”后者。

#### 在路径中使用正则表达式

Kong通过PCRE（Perl兼容正则表达式）支持Route的路径字段的正则表达式模式匹配。您可以同时将路径作为前缀和正则表达式分配给Route。例如，如果我们考虑以下Route：
```
{
    "paths": ["/users/\d+/profile", "/following"]
}
```

此Route将匹配以下请求：
```
GET /following HTTP/1.1
Host: ...
```
```
GET /users/123/profile HTTP/1.1
Host: ...
```

使用PCRE标志（`PCRE_ANCHORED`）评估提供的正则表达式，这意味着它们将被约束为在路径中的第一个匹配点（root`/`character）匹配。
        	
##### 评估顺序

如前所述，Kong按长度评估前缀路径：首先评估最长前缀路径。
但是，Kong将根据路由的`regex_priority`属性从最高优先级到最低优先级来评估正则表达式路径。这意味着考虑以下Routes：
```
[
    {
        "paths": ["/status/\d+"],
        "regex_priority": 0
    },
    {
        "paths": ["/version/\d+/status/\d+"],
        "regex_priority": 6
    },
    {
        "paths": ["/version"],
    },
    {
        "paths": ["/version/any/"],
    }
]
```
在这种情况下，Kong将按以下顺序评估针对以下定义的URI的传入请求：

1. `/version/any/`
2. `/version`
3. `/version/\d+/status/\d+`
4. `/status/\d+`

始终在正则表达式路径之前评估前缀路径。

像往常一样，请求仍然必须匹配Route的机`hosts`和`methods`属性，并且Kong将遍历您的Routes，直到找到匹配最多规则的路由（请参阅[路由优先级] [代理路由优先级]）。

##### 捕获组

也支持正则的捕获组，匹配的组将从路径中提取并可用于插件使用。
如果我们考虑以下正则表达式：
```
/version/(?<version>\d+)/users/(?<user>\S+)
```

以及以下请求路径：
```
/version/1/users/john
```
Kong会将请求路径视为匹配，如果匹配整个Route（考虑`hosts`和`methods`字段），则可以从`ngx.ctx`变量中的插件获取提取的捕获组：

```
local router_matches = ngx.ctx.router_matches

-- router_matches.uri_captures is:
-- { "1", "john", version = "1", user = "john" }
```

##### 规避特殊字符

接下来，值得注意的是，根据[RFC 3986](https://tools.ietf.org/html/rfc3986)，在正则表达式中找到的字符通常是保留字符，因此应该是百分比编码（URL编码）。**通过Admin API配置具有正则表达式路径的路由时，请务必在必要时对您的有效负载进行URL编码**。例如，使用`curl`并使用`application/x-www-form-urlencode`MIME类型：
```
curl -i -X POST http://localhost:8001/routes \
    --data-urlencode 'uris[]=/status/\d+'
HTTP/1.1 201 Created
...
```

请注意，`curl`不会自动对您的有效负载进行URL编码，并注意使用`--data-urlencode`，它可以防止Kong的Admin API对`+`字符进行URL解码，并将其解码为一个空的``。

#### `strip_path`属性

可能需要指定路径前缀以匹配路由，但不将其包括在上游请求中。为此，请通过配置如下所示的Route来使用`strip_path`布尔属性：
```
{
    "paths": ["/service"],
    "strip_path": true,
    "service": {
        "id": "..."
    }
}
```

启用此标志会指示Kong在匹配此路由并继续代理服务时，不应在上游请求的URL中包含URL路径的匹配部分。例如，以下客户端对上述路由的请求：
```
GET /service/path/to/resource HTTP/1.1
Host: ...
```

将导致Kong发送以下上游请求：
```
GET /path/to/resource HTTP/1.1
Host: ...
```

同样，如果在启用了`strip_path`的Route上定义了正则表达式路径，则将剥离整个请求URL匹配序列。
例：
```
{
    "paths": ["/version/\d+/service"],
    "strip_path": true,
    "service": {
        "id": "..."
    }
}
```

以下HTTP请求与提供的正则表达式路径匹配：

```
GET /version/1/service/path/to/resource HTTP/1.1
Host: ...
```

### 请求HTTP方法

`methods`字段允许根据HTTP方法匹配请求。它接受多个值。其默认值为空（HTTP方法不用于路由）。
以下路由允许通过`GET`和`HEAD`进行路由：
```
{
    "methods": ["GET", "HEAD"],
    "service": {
        "id": "..."
    }
}
```
这样的Route将符合以下要求：
```
GET / HTTP/1.1
Host: ...
```
```
HEAD /resource HTTP/1.1
Host: ...
```
    
但它与`POST`或`DELETE`请求不匹配。在路由上配置插件时，这允许更多粒度。例如，可以想象两个指向同一服务的路由：一个具有无限制的未经身份验证的`GET`请求，另一个仅允许经过身份验证和速率限制的`POST`请求（通过将身份验证和速率限制插件应用于此类请求）。
    
## 匹配优先事项

## 代理行为

	### 负载均衡
    ### 插件执行
    ### 代理和上游超时
    ### 错误和重试
    ### 响应
    
## 配置一个回调路由

## 为路由配置SSL

	### 限制客户端协议（HTTP / HTTPS / TCP / TLS）
    
## 代理WebSocket流量

	### WebSocket和TLS
    
## 结论














    
    
