# Health Checks and Circuit Breakers

## 简介

您可以使用Kong代理的API使用[环状负载均衡(ring-balancer)](https://docs.konghq.com/1.1.x/loadbalancing#ring-balancer)，通过添加包含一个或多个[目标](https://docs.konghq.com/1.1.x/loadbalancing#target)实体的[上游](https://docs.konghq.com/1.1.x/loadbalancing#upstream)实体进行配置，每个目标指向不同的IP地址（或主机名）和端口。环状负载均衡(ring-balancer)将平衡各种目标之间的负载，并且基于上游配置，将对目标执行健康检查，不论它们健康或不健康，无论它们是否响应。
然后，环状负载均衡(ring-balancer)仅将流量路由到健康的目标。

Kong支持两种健康检查，可以单独使用或结合使用：

- 主动检查(active checks):定期请求目标中的特定HTTP或HTTPS端点，并根据其响应情况确定目标的运行状况;
- 被动检查(passive checks):也称为断路器(circuit breakers)，Kong分析正在进行的代理流量，并根据其行为响应请求确定目标的运行状况。

## 健康和不健康的目标

健康检查功能的目的是为**给定的Kong节点**，动态地将目标标记为健康或不健康。没有群集范围(cluster-wide)的健康信息同步：每个Kong节点分别确定其目标的健康状况。这是可取的，因为在给定点，一个Kong节点可能能够成功连接到目标而另一个节点未能成功链接它：第一个节点将认为它是健康的，而第二个节点将其标记为不健康并开始将流量路由到上游的其他目标。

主动探测（在主动健康检查上）或代理请求（在被动健康检查上）会生成用于确定目标是健康还是不健康的数据。请求可能会产生TCP错误，超时或产生HTTP状态代码。根据此信息，运行状况检查器会更新一系列内部计数器：

- 如果返回的状态代码是一个配置为“healthy”的状态代码，它将递增目标的“Successes”计数器，并清除所有其他计数器;
- 如果连接失败，它将递增目标的“TCP failure”计数器，并清除“Successes”计数器;
- 如果超时，它将递增目标的“超时”计数器并清除“成功”计数器;
- 如果返回的状态代码是配置为“unhealthy”的状态代码，它将递增目标的“HTTP failure”计数器并清除“成功”计数器。

如果任何“TCP failures”，“HTTP failures”或“timeouts”计数器达到其配置的阈值，则目标将被标记为不健康。

如果“Successes”计数器达到其配置的阈值，则目标将标记为健康。

HTTP状态代码的列表是“healthy”或“unhealthy”，并且每个计数器的各个阈值可以基于每个上游进行配置。下面，我们有一个Upstream实体的配置示例，展示了可用于配置运行状况检查的各个字段的默认值。Admin API参考文档中包含每个字段的说明。

```
{
    "name": "service.v1.xyz",
    "healthchecks": {
        "active": {
            "concurrency": 10,
            "healthy": {
                "http_statuses": [ 200, 302 ],
                "interval": 0,
                "successes": 0
            },
            "http_path": "/",
            "timeout": 1,
            "unhealthy": {
                "http_failures": 0,
                "http_statuses": [ 429, 404, 500, 501,
                                   502, 503, 504, 505 ],
                "interval": 0,
                "tcp_failures": 0,
                "timeouts": 0
            }
        },
        "passive": {
            "healthy": {
                "http_statuses": [ 200, 201, 202, 203,
                                   204, 205, 206, 207,
                                   208, 226, 300, 301,
                                   302, 303, 304, 305,
                                   306, 307, 308 ],
                "successes": 0
            },
            "unhealthy": {
                "http_failures": 0,
                "http_statuses": [ 429, 500, 503 ],
                "tcp_failures": 0,
                "timeouts": 0
            }
        }
    },
    "slots": 10
}
```

如果上游的所有目标都不健康，Kong将回应对上游的请求`503 Service Unavailable`。

注意：

1. 运行状况检查仅在[活动目标](https://docs.konghq.com/1.1.x/admin-api#target-object)上运行，不会修改Kong数据库中目标的活动状态(active status)。
2. 不健康的目标不会从负载均衡器中移除，因此在使用散列算法时不会对平衡器布局产生任何影响（它们只是被跳过）。
3. [DNS警告](https://docs.konghq.com/1.1.x/loadbalancing#dns-caveats)和[负载均衡警告](https://docs.konghq.com/1.1.x/loadbalancing#balancing-caveats)注意事项也适用于健康检查。如果为目标使用主机名，请确保DNS服务器始终返回名称的完整IP地址集，并且不限制响应。**如果不这样做可能会导致健康检查无法执行。**

## 健康检查方式

### 主动健康检查

顾名思义，主动健康检查会积极主动对目标进行健康检查。当在上游实体中启用主动健康检查时，Kong将定期向上游的每个目标的已配置路径发出HTTP或HTTPS请求。这允许Kong根据[检测结果](https://docs.konghq.com/1.1.x/health-checks-circuit-breakers/#healthy-and-unhealthy-targets)自动启用和禁用平衡器中的目标。

不论目标健康或不健康时，可以单独配置活动健康检查的周期性。如果其中一个的间隔值`interval`设置为零，则在相应的方案中禁用检查。当两者都为零时，将完全禁用主动健康检查。

> 注意:主动健康状况检查目前仅支持HTTP/HTTPS目标。它们不适用于分配给服务的上游协议属性设置为“tcp”或“tls”的。

### 被动健康检查（断路器circuit breakers）

被动健康检查，也称为断路器(circuit breakers)，是根据Kong（HTTP/HTTPS/TCP）代理的请求执行的检查，并且不会产生额外的流量。当目标变得无响应时，被动健康检查程序将检测到该目标并将目标标记为不健康。环状负载均衡将开始跳过此目标，因此不再将流量路由到该目标。

一旦解决了目标问题并且它已准备好再次接收流量，Kong管理员可以通过Admin API端点手动通知运行状况检查器应该再次启用目标：
```
curl -i -X POST http://localhost:8001/upstreams/my_upstream/targets/10.1.2.3:1234/healthy
HTTP/1.1 204 No Content
```
此命令将广播群集范围的消息，以便将“healthy”状态传播到整个[Kong群集](https://docs.konghq.com/1.1.x/clustering)。这将导致Kong节点会重置在Kong节点中所有程序中的健康检查状况计数器，从而允许环状负载均衡再次将流量路由到目标。

被动健康检查的优点是不会产生额外的流量，但是它们无法再自动将目标标记为健康：“circuit is broken”，并且系统管理员需要再次重新启用目标。

## 优缺点对比总结

- 主动健康检查可以在环状负载均衡再次恢复健康状态时自动重新启用环形平衡器中的目标。被动健康检查不能。
- 被动健康检查不会为目标产生额外的流量。而主动健康检查则会有。
- 主动健康检查程序要求在目标中具有可靠状态响应的已知URL，以将其配置为探测端点（可能与`“/”`一样简单）。被动健康检查不要求这样的配置。
- 通过为主动健康检查程序提供自定义探测端点，应用程序可以确定自己的运行状况指标并生成要由Kong使用的状态代码。即使目标继续提供被动健康检查器看起来健康的流量，它也能够响应具有故障状态的活动探测器，基本上可以放心接收新的流量。

可以组合这两种模式。例如，可以启用被动运行状况检查以仅根据其流量监控目标运行状况，并仅在目标运行状况不佳时使用主动运行状况检查，以便自动重新启用它。

## 启用和禁用健康检查

### 启用主动健康检查

### 启用被动健康检查

### 关闭健康检查




















