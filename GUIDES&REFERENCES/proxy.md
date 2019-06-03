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
    
    	#### 在路径中使用正则表达式
        	
            ##### 评估订单
            ##### 捕获团体
            ##### 规避特殊字符
            
        #### strip_path属性
        
    ### 请求HTTP方法
    
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














    
    
