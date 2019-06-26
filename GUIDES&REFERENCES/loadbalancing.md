# 负载均衡

> 本文原文链接：https://docs.konghq.com/1.1.x/loadbalancing/

## 简介

Kong为多个后端服务提供了多种负载均衡请求：一种简单的基于DNS的方法，以及一个更加动态的环装负载均衡，它还允许service注册，而无需DNS服务器。

## 基于DNS的负载均衡

使用基于DNS的负载均衡时，后端服务的注册是在Kong之外完成的，而Kong只接收来自DNS服务器的更新。

如果名称解析为多个IP地址，则使用包含主机名（而不是IP地址）的主机定义的每个服service将自动使用基于DNS的负载均衡，前提是主机名未解析为`upstream`名称或名称在的DNS主机文件。

DNS记录`ttl`的设置（生存时间）确定刷新信息的频率。使用`ttl`为0时，将使用自己的DNS查询解析每个请求。显然这会有性能损失，但更新/更改 的延迟将非常低。

### A 记录

一条A记录包含一个或多个IP地址。因此，当主机名解析为A记录时，每个后端服务必须具有自己的IP地址。

由于没有权重`weight`信息，所有条目在负载均衡器中将被视为等权重，并且均衡器将执行直接循环。


### SRV 记录

SRV记录包含其所有IP地址的权重和端口信息。后端服务可以通过IP地址和端口号的唯一组合来识别。因此，单个IP地址可以在不同端口上托管同一服务的多个实例。

由于权重`weight`信息可用，每个条目将在负载均衡器中获得自己的权重，并且它将执行加权循环。

同样，任何给定的端口信息都将被来自DNS服务器的端口信息覆盖。如果服务具有`host=myhost.com`和`port=123`属性，并且`myhost.com`解析为`127.0.0.1:456`的SRV记录，则该请求将代理到`http://127.0.0.1:456/somepath`，因为端口`123`将被`456`覆盖。

### DNS 优先

DNS解析器将按顺序开始解析以下记录类型：

1. 上一次成功解决的类型
2. SRV 记录
3. A 记录
4. CNAME 记录

此项可通过[dns_order配置属性]()进行配置。https://docs.konghq.com/1.1.x/configuration/#dns_order

### DNS注意事项

- 每当刷新DNS记录时，都会生成一个列表以正确处理加权。尽量保持权重为彼此的倍数，以保持算法的性能，例如，17和31的2个权重将导致具有527个条目的结构，而权重16和32（或其最小的相对对应物1和2）将导致仅具有3个条目的结构，尤其是具有非常小（或甚至0）的`ttl`值。
- 在这些情况下，某些名称服务器不返回所有条目（由于UDP数据包大小）（例如Consul返回最多3个），给定的Kong节点将仅使用名称服务器提供的少数上游服务实例。在这种情况下，上游实例池可能会加载不一致，因为由于名称服务器提供的信息有限，Kong节点实际上没有察觉到某些实例。要减轻这种使用，请使用其他名称服务器，使用IP地址而不是名称，或确保使用足够的Kong节点仍然使用所有上游服务。
- 当名称服务器返回`3 name error`时，即对Kong的有效响应。如果这是个意外，请首先验证正在查询的名称正确性，然后再检查您的名称服务器配置。
- 从DNS记录（A或SRV）初始选择IP地址不是随机的。因此，当使用`ttl`为0的记录时，名称服务器应该随机化记录条目。

## 环状负载均衡

使用环状负载均衡时，Kong将处理后端服务的添加和删除，并且不需要DNS更新。Kong将会负责服务注册。可以使用单个HTTP请求添加/删除节点，并立即开始/停止接收流量。

配置环状负载均衡是通过`upstream`和`target`实体完成的。

- `target`：具有后端服务所在的端口号的IP地址或主机名，例如。“192.168.100.12:80”。每个目标都会获得额外的权重`weight`，以指示它获得的相对负载。IP地址可以是IPv4和IPv6格式。
- `upstream`：一个'虚拟主机名'，可以在`route`主机字段中使用，例如，名为`weather.v2.service`的上游将获得来自具有`host=weather.v2.service`的服务的所有请求。

### 上游 Upstream

每个Upstream都有自己的环状负载均衡器。每个`upstream`可以附加许多`target`条目，代理到“虚拟主机名”的请求将在目标上进行负载平衡。环状负载均衡器具有预定数量的插槽(slots)，并且基于目标权重，插槽被分配给上游的目标。

可以使用Admin API上的简单HTTP请求来添加和删除目标。这个操作相对低成本。更改上游本身更加昂贵，因为当插槽数量发生变化时需要重建平衡器。

自动重建平衡器的唯一情况是清理目标历史记录时;除此之外，它只会在有变化时重建。

在平衡器内有位置（从1到若干个插槽`slots`），它们随机分布在环上。随机性是在运行时调用环状负载均衡器所必需的。轮子（位置）上的简单循环将在目标上提供分布均匀的加权循环，同时在插入/删除目标时也具有低成本操作。

每个目标使用的插槽数量应该（至少）大约为100，以确保插槽正确分布。例如，对于预期最多8个目标，`upstream`应定义至少`slot`=800，即使初始设置仅具有2个目标。

这里的权衡是，插槽数越多，随机分布越好，但更改的成本越高（添加/删除目标）

有关添加和操作`upstream`的详细信息，请参见[Admin API参考的上游部分](https://docs.konghq.com/1.1.x/admin-api#upstream-object)。

### 目标 Target

由于`upstream`维护更改历史记录，因此只能添加目标，不能修改或删除目标。要更改目标，只需为目标添加新条目，然后更改权重`weight`值。最后一个条目是将要使用的条目。因此，设置`weight=0`将禁用目标，从而有效地将其从平衡器中删除。有关添加和操作目标的详细信息，请参阅Admin API参考的目标部分。

当非活动条目比活动条目多10倍时，将自动清除目标。清除将涉及重建平衡器，因此比仅添加目标条目成本更高。

`target`也可以具有主机名而不是IP地址。在这种情况下，名称将被解析，所有找到的条目将分别添加到环状负载均衡器，例如，给`api.host.com:123`添加`weight=100`。名称“api.host.com”解析为具有2个IP地址的A记录。然后将两个ip地址添加为目标，每个都获`weight=100`和端口123。注意：权重用于单个条目，而不是整个！

如果它解析为SRV记录，那么DNS记录中的`port`和`weight`字段也将被拾取，并且将覆盖给定端口`123`并且`weight=100`。

平衡器将遵守DNS记录的`ttl`设置并重新查询，在到期时更新平衡器。

例外：当DNS记录的`ttl=0`时，主机名将作为单个目标添加，具有指定的权重。每次代理请求此目标后，它将再次查询名称服务器。

### 负载均衡算法

默认情况下，环状负载均衡器将使用加权循环方案。替代方案是使用基于hash的算法。哈希的输入可以是`none`，`consumer`，`ip`，`header`或`cookie`。设置为`none`时，将使用加权循环方案，并且将禁用散列。

有两个选项，主要和后备，以防主要失败（例如，如果主要设置为消费者，但没有`consumer`被认证）。

不同的哈希选项：

- `none`:不要使用散列，而是使用加权循环（默认）。
- `consumer`:使用使用者ID作为哈希输入。如果没有可用的消费者ID，则此选项将回退到凭证ID（如果是外部身份验证，如ldap）。
- `ip`:远程（始发）IP地址将用作输入。使用此选项时，请查看用于确定实际IP的配置设置。
- `header`:使用指定的头eader（在`hash_on_header`或`hash_fallback_header`字段中）作为哈希的输入。
- `cookie`:使用指定路径（在`hash_on_cookie_path`字段中，默认为`“/”`）的指定cookie名称（在`hash_on_cookie`字段中）作为哈希的输入。如果请求中不存在cookie，则响应将设置该cookie。因此，如果`cookie`是主要的散列机制，则`hash_fallback`设置无效。

散列算法基于“consistent-hashing”（或“ketama principle”），确保通过更改目标（添加，删除，失败或更改权重）修改平衡器时，只有最小数量的散列损失发生。这将最大化上游的缓存命中。

有关确切设置的详细信息，请参阅[Admin API参考的上游部分](https://docs.konghq.com/1.1.x/admin-api#upstream-object)。

### 负载均衡注意事项

环形负载均衡器设计用于单个节点以及群集。对于加权循环算法没有太大区别，但是当使用基于散列的算法时，重要的是所有节点构建完全相同的环平衡器以确保它们全部相同。为此，必须以确定的方式构建平衡器。

- 不要在平衡器中使用主机名，因为平衡器可能/将慢慢偏离，因为DNS ttl仅具有第二精度，并且更新由实际请求名称确定。最重要的是一些名称服务器没有返回所有条目的问题，这加剧了这个问题。因此，在Kong群集中使用散列方法时，仅通过其IP地址添加目标实体，而不是通过名称添加目标实体。
- 在选择哈希输入时，请确保输入具有足够的方差以获得分布均匀的哈希。哈希值将使用CRC-32摘要计算。例如，如果您的系统有数千个用户，但只有少数消费者，按平台定义（例如，3个消费者：Web，iOS和Android），然后选择消费者哈希输入是不够的，通过将哈希设置为ip来使用远程IP地址将在输入中提供更多变化，从而在哈希输出中提供更好的分布。但是，如果许多客户端将在同一NAT网关后面（例如在呼叫中心），则`cookie`将提供比`ip`更好的分发。

## 蓝绿部署

使用环装负载均衡器可以轻松地为服务进行[蓝绿色部署](http://blog.christianposta.com/deploy/blue-green-deployments-a-b-testing-and-canary-releases/)。切换目标基础结构仅需要服务上的`PATCH`请求，以更改其`host`值。

设置“Blue”环境，运行地址服务的版本1：

```
# 创建一个 upstream
curl -X POST http://kong:8001/upstreams \
    --data "name=address.v1.service"

# 添加两个 targets 到 upstream
curl -X POST http://kong:8001/upstreams/address.v1.service/targets \
    --data "target=192.168.34.15:80"
    --data "weight=100"
curl -X POST http://kong:8001/upstreams/address.v1.service/targets \
    --data "target=192.168.34.16:80"
    --data "weight=50"

# 创建一个Service 目标到 Blue upstream
curl -X POST http://kong:8001/services/ \
    --data "name=address-service" \
    --data "host=address.v1.service" \
    --data "path=/address"

# 最后, 添加一个 Route 作为一个端点到 Service
curl -X POST http://kong:8001/services/address-service/routes/ \
    --data "hosts[]=address.mydomain.com"
```

主机header设置为`address.mydomain.com`的请求现在由Kong代理到两个定义的目标;
2/3的请求将转到`http://192.168.34.15:80/address`(`weight = 100`），而1/3将转到`http://192.168.34.16:80/address`(`weight = 50`）。

在部署地址服务的第2版之前，请设置“Green”环境：

```
# 新建一个 Green upstream 到 地址service v2
curl -X POST http://kong:8001/upstreams \
    --data "name=address.v2.service"

# 添加一个 targets 到upstream
curl -X POST http://kong:8001/upstreams/address.v2.service/targets \
    --data "target=192.168.34.17:80"
    --data "weight=100"
curl -X POST http://kong:8001/upstreams/address.v2.service/targets \
    --data "target=192.168.34.18:80"
    --data "weight=100"
```

要激活 Blue/Green  开关，我们现在只需要更新服务：

```
# 更改 Service从 Blue 到 Green upstream, v1 到 v2
curl -X PATCH http://kong:8001/services/address-service \
    --data "host=address.v2.service"
```

将主机header设置为`address.mydomain.com`的传入请求现在由Kong代理到新目标；1/2的请求将会到`http://192.168.34.17:80/address `(`weight=100`)，剩下1/2的请求将会到`http://192.168.34.18:80/address` (`weight=100`)。

与往常一样，通过Kong Admin API进行的更改是动态的，并将立即生效。
不需要重新加载或重新启动，也不会丢弃正在进行的请求。

## 金丝雀（灰度）发布

使用环装负载均衡器， target 权重可以精细调整，允许平稳，受控制的[金丝雀（灰度）发布](http://blog.christianposta.com/deploy/blue-green-deployments-a-b-testing-and-canary-releases/)。

使用一个非常简单的两个target目标示例：

```
# 第一个 target at 1000
curl -X POST http://kong:8001/upstreams/address.v2.service/targets \
    --data "target=192.168.34.17:80"
    --data "weight=1000"

# 第二个 target at 0
curl -X POST http://kong:8001/upstreams/address.v2.service/targets \
    --data "target=192.168.34.18:80"
    --data "weight=0"
```

通过重复请求，但每次都改变权重，流量将慢慢地路由到另一个目标。
例如，将其设置为10％：

```
# 第一个 target at 900
curl -X POST http://kong:8001/upstreams/address.v2.service/targets \
    --data "target=192.168.34.17:80"
    --data "weight=900"

# 第二个 target at 100
curl -X POST http://kong:8001/upstreams/address.v2.service/targets \
    --data "target=192.168.34.18:80"
    --data "weight=100"
```

通过Kong Admin API进行的更改是动态的，并将立即生效。
不需要重新加载或重新启动，也不会丢弃正在进行的请求。





