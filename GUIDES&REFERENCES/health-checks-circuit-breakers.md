# 健康检查和断路器

> 本文原文链接：https://docs.konghq.com/1.1.x/health-checks-circuit-breakers/

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

要启用主动健康检查，您需要在[Upstream对象](https://docs.konghq.com/1.1.x/admin-api#upstream-objects)配置中指定`healthchecks.active`下的配置项。您需要指定必要的信息，以便Kong可以对目标执行定期探测，以及如何解释结果信息。您可以使用`healthchecks.active.type`字段指定是执行HTTP探测还是HTTPS探测（将其设置为“http”或“https”），或者只是测试与给定主机和端口的连接是否成功（将其设置为“tcp”）。

要配置探针，您需要指定：

- `healthchecks.active.http_path` - 向目标发出HTTP GET请求时应使用的路径。默认值是`/`
- `healthchecks.active.timeout` - 探针的HTTP GET请求的连接超时限制。默认值为1秒。
- `healthchecks.active.concurrency` - 在活动运行状况检查中同时检查的目标数。

您还需要为间隔指定正值，以便运行探针：

- `healthchecks.active.healthy.interval` - 健康目标的活动健康检查之间的间隔（以秒为单位）。
- `healthchecks.active.unhealthy.interval` - 值为零表示不应执行健康目标的活动探测。

允许您调整主动健康检查的行为，无论您是希望健康和不健康目标的探测器以相同间隔运行，或者一个比另一个更频繁。

如果您使用的是HTTPS运行状况检查，则还可以指定以下字段：

- `healthchecks.active.https_verify_certificate` - 使用HTTPS执行活动运行状况检查时是否检查远程主机的SSL证书的有效性。
- `healthchecks.active.https_sni` - 使用HTTPS执行活动运行状况检查时用作SNI（服务器名称标识）的主机名。当使用IP配置目标时，这尤其有用，因此可以使用正确的SNI验证目标主机的证书。

请注意，失败的TLS验证将增加“TCP failures”计数器;“HTTP failures”仅指HTTP状态代码，无论探测是通过HTTP还是HTTPS完成的。

最后，您需要通过设置运行状况计数器上的各种阈值来配置Kong应该如何解释探测器，一旦达到该阈值将触发状态更改。
计数器阈值字段是：

- `healthchecks.active.healthy.successes` - 活动探针中的成功次数（由`healthchecks.active.healthy.http_statuses`定义）以考虑目标健康。
- `healthchecks.active.unhealthy.tcp_failures` - 在活动探测器中考虑目标不健康的TCP故障或TLS验证失败的数量。
- `healthchecks.active.unhealthy.timeouts` - 活动探测器中用于考虑目标不健康的超时次数。
- `healthchecks.active.unhealthy.http_failures` - 活动探测器中的HTTP故障数（由`healthchecks.active.unhealthy.http_statuses`定义）以考虑目标运行状况不佳。

### 启用被动健康检查

被动健康检查没有探针，因为他们通过解析从目标流出的持续流量来工作。这意味着要启用被动检查，您只需配置其计数器阈值：

- `healthchecks.passive.healthy.successes` - 代理流量的成功次数（由`healthchecks.passive.healthy.http_statuses`定义）以考虑目标健康，如被动健康检查所观察到的那样。当启用被动检查时，这需要是积极的，以便健康的流量重置不健康的计数器。
- `healthchecks.passive.unhealthy.tcp_failures` - 通过被动运行状况检查观察到的代理流量中考虑目标不健康的TCP故障数。
- `healthchecks.passive.unhealthy.timeouts` - 通过被动运行状况检查观察到的代理流量中考虑目标不健康的超时次数。
- `healthchecks.passive.unhealthy.http_failures` - 代理流量（由`healthchecks.passive.unhealthy.http_statuses`定义）中的HTTP故障数，以考虑目标不健康，如被动运行状况检查所观察到的那样。

### 关闭健康检查

在`healthchecks`胚置中指定的所有计数器阈值和间隔中，将值设置为零意味着禁用该字段表示的功能。将探测间隔设置为零会禁用探测。
同样，您可以通过将其计数器阈值设置为零来禁用某些类型的检查。例如，要在执行健康检查时不考虑超时，可以将两个超时字段（用于主动和被动检查）设置为零。这使您可以对健康检查程序的行为进行细粒度控制。

总之，要完全禁用上游的活动运行状况检查，您需要将`healthchecks.active.healthy.interval`和`healthchecks.active.unhealthy.interval`都设置为0。

默认情况下，`healthchecks`中的所有计数器阈值和间隔均为零，这意味着在新创建的上游中默认情况下完全禁用运行状况检查。


