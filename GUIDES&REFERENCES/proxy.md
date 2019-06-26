# 代理

> 本文原文链接：https://docs.konghq.com/1.1.x/proxy/

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

Route可以基于其`hosts`, `paths`, 和 `methods`字段定义匹配规则。要使Kong匹配到路由的传入请求，必须满足所有现有字段。
但是，通过允许两个或多个路由配置包含相同值的字段，Kong允许相当大的灵活性 - 当发生这种情况时，Kong应用优先级规则。

规则是：**在评估请求时，Kong将首先尝试匹配具有最多规则的路由。**

例如，如果两个路由配置如下：
```
{
    "hosts": ["example.com"],
    "service": {
        "id": "..."
    }
},
{
    "hosts": ["example.com"],
    "methods": ["POST"],
    "service": {
        "id": "..."
    }
}
```

第二个Route有一个`hosts`字段和一个`methods`字段，因此它将首先由Kong评估。通过这样做，我们避免了第一个用于第二个路径的“阴影”调用。

因此，此请求将匹配第一个Route

```
GET / HTTP/1.1
Host: example.com
```

这个请求将匹配第二个：

```
POST / HTTP/1.1
Host: example.com
```

遵循这个逻辑，如果要使用`hosts`字段，`methods`字段和`uris`字段配置第三个Route，它将首先由Kong评估。

## 代理行为

上面的代理规则详细说明了Kong如何将传入请求转发到您的上游服务。下面，我们详细说明Kong与HTTP请求与注册路由*匹配*的时间与请求的实际*转发*之间内部发生的情况。

### 1.负载均衡

Kong实现负载平衡功能，以跨上游服务实例池分发代理请求。

您可以通过查看[负载平衡](https://docs.konghq.com/1.1.x/loadbalancing)来查找有关配置负载平衡的更多信息

### 2.插件执行

Kong可通过“插件”进行扩展，这些“插件”将自己挂载在代理请求的请求/响应生命周期中。插件可以在您的环境中执行各种操作 和/或 在代理请求上进行转换。

可以将插件配置为全局（针对所有代理流量）或特定 Routes 和 Services运行。
在这两种情况下，您都必须通过Admin API创建[插件配置](https://docs.konghq.com/1.1.x/admin-api#plugin-object)。

一旦路由匹配（及其关联的服务实体），Kong将运行与这些实体中的任何一个相关联的插件。在路由上配置的插件在服务上配置的插件之前运行，否则，通常的[插件关联](https://docs.konghq.com/1.1.x/admin-api/#precedence)规则适用。

这些配置的插件将运行其`access`阶段，您可以在[插件开发指南](https://docs.konghq.com/1.1.x/plugin-development)中找到更多相关信息。

### 3.代理和上游超时

一旦Kong执行了所有必要的逻辑（包括插件），它就可以将请求转发给您的上游服务。这是通过Nginx的[ngx_http_proxy_module](http://nginx.org/en/docs/http/ngx_http_proxy_module.html)完成的。
您可以通过以下服务属性为Kong和给定上游之间的连接配置所需的超时：

- `upstream_connect_timeout`:以毫秒为单位定义建立与上游服务的连接的超时。默认为`60000`。
- `upstream_send_timeout`:以毫秒为单位定义用于向上游服务发送请求的两个连续写入操作之间的超时。默认为`60000`。
- `upstream_read_timeout`:以毫秒为单位定义用于接收来自上游服务的请求的两个连续读取操作之间的超时。默认为`60000`。

Kong将通过 HTTP/1.1 发送请求，并设置以下headers：

- `Host: <your_upstream_host>`，如前文所述。
- `Connection: keep-alive`，允许重用上游连接。
- `X-Real-IP: <remote_addr>`，其中`$remote_addr是`与[ngx_http_core_module](http://nginx.org/en/docs/http/ngx_http_core_module.html#var_remote_addr)提供的名称相同的变量。请注意，`$remote_addr`可能被[ngx_http_realip_module](http://nginx.org/en/docs/http/ngx_http_realip_module.html)覆盖。
- `X-Forwarded-For: <address>`，其中`<address>`是由附加到具有相同名称的请求标头的[ngx_http_realip_module](http://nginx.org/en/docs/http/ngx_http_realip_module.html)提供的`$realip_remote_addr`的内容。
- `X-Forwarded-Proto: <protocol>`，其中`<protocol>`是客户端使用的协议。在`$realip_remote_addr`是可信地址之一的情况下，如果提供，则转发具有相同名称的请求头。否则，将使用[ngx_http_core_module](http://nginx.org/en/docs/http/ngx_http_core_module.html#var_scheme)提供的`$scheme`变量的值。
- `X-Forwarded-Host: <host>`，其中`<host>`是客户端发送的主机名。在`$realip_remote_addr`是可信地址之一的情况下，如果提供，则转发具有相同名称的请求头。否则，将使用[ngx_http_core_module](http://nginx.org/en/docs/http/ngx_http_core_module.html#var_host)提供的`$host`变量的值。
- `X-Forwarded-Port: <port>`，其中`<port>`是接受请求的服务器的端口。在`$realip_remote_addr`是可信地址之一的情况下，如果提供，则转发具有相同名称的请求头。否则，将使用[ngx_http_core_module](http://nginx.org/en/docs/http/ngx_http_core_module.html#var_server_port)提供的`$server_port`变量的值。

所有其他请求headers都由Kong转发。

使用WebSocket协议时会出现一个例外。如果是这样，Kong将设置以下标头以允许升级客户端和上游服务之间的协议：

- `Connection: Upgrade`
- `Upgrade: websocket`

有关此主题的更多信息，请参见[Proxy WebSocket流量] [proxy-websocket]部分。

### 4.错误和重试

每当代理期间发生错误时，Kong将使用底层的Nginx[重试机制](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_next_upstream_tries)将请求传递给下一个上游。

这里有两个可配置元素：

1. 重试次数：可以使用`retries`属性为每个服务配置。有关详细信息，请参阅[Admin API](https://docs.konghq.com/1.1.x/admin-api)。
2. 究竟是什么构成错误：这里Kong使用Nginx默认值，这意味着在与服务器建立连接，向其传递请求或读取响应头时发生错误或超时。

第二个选项基于Nginx的`proxy_next_upstream`指令。此选项不能通过Kong直接配置，但可以使用自定义Nginx配置添加。有关详细信息，请参阅配置参考。

### 5.响应

Kong接收来自上游服务的响应，并以流方式将其发送回下游客户端。此时，Kong将执行添加到 Route 和/或 Service 的后续插件，这些插件在`header_filter`阶段实现一个钩子。

一旦执行了所有已注册插件的`header_filter`阶段，Kong将添加以下headers，并将完整的headers发送到客户端：

- `Via: kong/x.x.x`，其中`x.x.x`是正在使用的Kong版本。
- `X-Kong-Proxy-Latency: <latency>`，其中`latency`是Kong收到客户端请求和向上游服务发送请求之间的时间（以毫秒为单位）。
- `X-Kong-Upstream-Latency: <latency>`，其中`latency`是Kong等待上游服务响应的第一个字节的时间（以毫秒为单位）。

将标题发送到客户端后，Kong将开始为实现`body_filter`钩子的 Route和/或Service 执行已注册的插件。由于Nginx的流媒体特性，可以多次调用此钩子。由这样的`body_filter`挂钩成功处理的上游响应的每个块被发送回客户端。您可以在[插件开发指南](https://docs.konghq.com/1.1.x/plugin-development)中找到有关`body_filter`钩子的更多信息。
    
## 配置一个备用路由

作为Kong的代理功能提供的灵活性的实际用例和示例，让我们尝试实现“后备路线”，因此，为了避免Kong响应HTTP `404`，“找不到路由”，我们可以捕获这些请求并将它们代理到特殊的上游服务，或者向它应用插件（例如，这样的插件可以使用不同的状态代码或响应终止请求，而不代理请求）。

以下是此类后备路由的示例：
```
{
    "paths": ["/"],
    "service": {
        "id": "..."
    }
}
```

正如您所猜测的，任何向Kong发出的HTTP请求实际上都会匹配此Route，因为所有URI都以根字符`/`为前缀。正如我们从[请求路径] [代理请求路径]部分所知，最长的URL路径首先由Kong评估，因此`/`路径最终将由Kong最后评估，并有效地提供“后备”路由，仅作为最后的手段。

## 为路由配置SSL

Kong提供了一种基于每个连接动态提供SSL证书的方法。SSL证书由核心直接处理，并可通过Admin API进行配置。通过TLS连接到Kong的客户端必须支持服务器名称指示扩展才能使用此功能。

SSL证书由Kong Admin API中的两个资源处理：

- `/certificates`，存储您的密钥和证书。
- `/snis`，将注册证书与Server Name 指示相关联。

您可以在[Admin API参考](https://docs.konghq.com/1.1.x/admin-api)中找到这两种资源的文档。

以下是在给定路由上配置SSL证书的方法：首先，通过Admin API上传您的SSL证书和密钥：

```
curl -i -X POST http://localhost:8001/certificates \
    -F "cert=@/path/to/cert.pem" \
    -F "key=@/path/to/cert.key" \
    -F "snis=ssl-example.com,other-ssl-example.com"
HTTP/1.1 201 Created
...
```

`snis`表单参数是糖参数，直接插入SNI并将上传的证书与其关联。

您现在必须在Kong内注册以下Route。
为方便起见，我们仅使用Hos header 匹配对此Route的请求：
```
curl -i -X POST http://localhost:8001/routes \
    -d 'hosts=ssl-example.com,other-ssl-example.com' \
    -d 'service.id=d54da06c-d69f-4910-8896-915c63c270cd'
HTTP/1.1 201 Created
...
```

您现在可以期望Kong通过HTTPS提供路由：
```
curl -i https://localhost:8443/ \
  -H "Host: ssl-example.com"
HTTP/1.1 200 OK
...
```

建立连接并协商SSL握手时，如果您的客户端发送`ssl-example.com`作为SNI扩展的一部分，Kong将提供先前配置的`cert.pem`证书。

### 限制客户端协议（HTTP/HTTPS/TCP/TLS）
    
路由具有`protocols`属性，以限制他们应该侦听的客户端协议。此属性接受一组值，可以是`“http”`，`“https”`，`“tcp”`或`“tls”`。

具有`http`和`https`的路由将接受两种协议中的流量。
```
{
    "hosts": ["..."],
    "paths": ["..."],
    "methods": ["..."],
    "protocols": ["http", "https"],
    "service": {
        "id": "..."
    }
}
```

未指定任何协议具有相同的效果，因为路由默认为`[“http”，“https”]`。

但是，仅使用`https`的路由*只*接受通过HTTPS的流量。如果以前从受信任的IP发生SSL终止，它也会接受未加密的流量。当请求来自[trusted_ip](https://docs.konghq.com/1.1.x/configuration/#trusted_ips)中的一个配置的IP并且如果设置了`X-Forwarded-Proto:https` header时，SSL终止被认为是有效的：
```
{
    "hosts": ["..."],
    "paths": ["..."],
    "methods": ["..."],
    "protocols": ["https"],
    "service": {
        "id": "..."
    }
}
```

如果上述路由与请求匹配，但该请求是纯文本而没有有效的先前SSL终止，则Kong响应：

```
HTTP/1.1 426 Upgrade Required
Content-Type: application/json; charset=utf-8
Transfer-Encoding: chunked
Connection: Upgrade
Upgrade: TLS/1.2, HTTP/1.1
Server: kong/x.y.z

{"message":"Please use HTTPS protocol"}
```

从Kong 1.0开始，可以使用`protocols`属性中的`“tcp”`为原始TCP（不一定是HTTP）连接创建路由：
```
{
    "hosts": ["..."],
    "paths": ["..."],
    "methods": ["..."],
    "protocols": ["tcp"],
    "service": {
        "id": "..."
    }
}
```

同样，我们可以使用`“tls”`值创建接受原始TLS流量（不一定是HTTPS）的路由：
```
{
    "hosts": ["..."],
    "paths": ["..."],
    "methods": ["..."],
    "protocols": ["tls"],
    "service": {
        "id": "..."
    }
}
```

仅具有`TLS`的路由仅接受通过TLS的流量。
也可以同时接受TCP和TLS：
```
{
    "hosts": ["..."],
    "paths": ["..."],
    "methods": ["..."],
    "protocols": ["tcp", "tls"],
    "service": {
        "id": "..."
    }
}
```

## 代理WebSocket流量

由于底层的Nginx实现，Kong支持WebSocket流量。如果希望通过Kong在客户端和上游服务之间建立WebSocket连接，则必须建立WebSocket握手。这是通过HTTP升级机制完成的。这是您的客户要求对Kong的看法：
```
GET / HTTP/1.1
Connection: Upgrade
Host: my-websocket-api.com
Upgrade: WebSocket
```

这将使Kong将`Connection`和`Upgrade` header 转发到您的上游服务，而不是由于标准HTTP代理的逐跳特性而将其解除。

### WebSocket和TLS

Kong将在其各自的`http`和`https`端口接受`ws`和`wss`连接。要从客户端强制执行TLS连接，请将Route的`protocols`属性设置为**仅**`https`。

将 Service 设置为指向上游WebSocket服务时，应仔细选择要在Kong和上游之间使用的协议。如果要使用TLS（`wss`），则必须使用服务`protocol`属性中的`https`协议和正确的端口（通常为443）定义上游WebSocket服务。要在没有TLS（`ws`）的情况下进行连接，则应在协议中使用`http`协议和端口（通常为80）。

如果您希望Kong终止SSL/TLS，您只能从客户端接受`wss`，而是通过纯文本或`ws`代理上游服务。

## 结论

通过本指南，我们希望您了解Kong的基础代理机制，从请求如何匹配路由到其关联的服务，到如何允许使用WebSocket协议或设置动态SSL证书。

该网站是开源的，可以在 https://github.com/Kong/docs.konghq.com 找到。
如果您还没有，我们建议您还阅读[负载平衡参考](https://docs.konghq.com/1.1.x/loadbalancing)，因为它与我们刚刚介绍的主题密切相关。

 
