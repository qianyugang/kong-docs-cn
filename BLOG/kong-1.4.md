# Kong 1.4 发布！自动检测Cassandra Topology 更改，自定义Host Header以及更多功能！

> 原文地址：https://konghq.com/blog/kong-gateway-1-4-released-auto-detect-cassandra-topology-changes-custom-host-header-much/

我们很高兴地宣布1.4系列的第一个版本已经发布！
我们的工程团队和出色的社区成员在此版本中添加了许多新功能，改进和修复。

请阅读以下内容，了解Kong Gateway 1.4中最相关的更改以及如何充分利用这些新增功能。
有关完整的详细信息，请参阅[更改日志](https://github.com/Kong/kong/blob/1.4.0/CHANGELOG.md#140)；有关如何从以前的Kong版本进行升级的说明，请参阅[升级路径](https://github.com/Kong/kong/blob/1.4.0/UPGRADE.md#upgrade-to-140)。

## 自动检测Cassandra Topology 更改

从Kong Gateway 1.4开始，将自动检测对Apache Cassandra群集拓扑所做的任何更改，从而避免Kong重新启动。

## 如何利用此新功能：

新的配置`cassandra_refresh_frequency`设置在检查Cassandra集群拓扑结构更改之前，Kong必须等待多长时间。默认频率是每60秒检查一次，但是可以根据需要增加、减少甚至禁用这个值。

## 上游的Hostname属性

Kong中定义的任何上游现在都可以使用一个名为`hostname`的可选属性，该属性定义在通过Kong服务器代理连接时将使用的`Host` header。

## 主要优点：

服务器通常会监听与解析名称不同的服务器名称，并且此新属性可以保证Kong在代理连接和积极检查主机的运行状况时将使用正确的名称。

## DAO属性的新变更

新的属性转换已添加到DAO模式中，使开发人员能够添加在插入或更新数据库条目时运行的函数

## 新的状态接口

通过新的状态接口，插件可以将端点添加到已经存在的/status端点，从而公开不敏感的健康数据，从而避免公开Kong的管理API。

## 主要优点

- 用户可以同时公开Kong的健康数据并保护Kong的Admin API。
- 对于使用禁用的管理界面运行的Kong节点，执行基于HTTP的运行状况检查更加容易。

## Kong Gateway 1.4中的其他新功能

### 新的Admin API响应header`X-Kong-Admin-Latency`

- 这个新的响应header报告了对Kong的Admin API的每个请求处理了多长时间。

### 新的配置选项`router_update_frequency`

- 这个新的配置选项允许设置检查路由器和插件更改的频率。
- 这样可以避免在频繁更改Kong路由或插件时性能下降。
- 此选项使管理员可以选择延迟路由器和插件配置更改的可用性，还是增加数据库负载。

### 限速插件中的Service-level 支持

- 除了使用者，凭证和IP级别外，限速插件现在还具有服务级别的支持。

## Kong Gateway 1.4中的其他改进和错误修复

Kong Gateway 1.4还改善了限速插件内存的使用，使用共享字典的TTL终止了其`local`策略计数器，以避免在内存中保留不必要的计数器。

此版本中存在一些重要的错误修复，例如服务网格弃用的开始，它将被替换为Kuma（[kuma.io](http://kuma.io/)）向前发展。
已知服务网格会导致向上游的HTTPS请求忽略`proxy_ssl *`指令，因此在Kong Gateway的下一个主要版本中将停止使用该服务网格。
在此版本中，默认情况下禁用此功能，以避免出现此问题，并且仍可以使用新的配置选项`service_mesh`启用它。

另一个相关的修复与使用日志插件记录NGINX产生的错误有关，该错误过去曾错误地将某些请求属性报告为请求方法，并且现在可以正常工作。

我们还解决了一个问题，即在删除所有Kong workers时，目标不能在所有Kong员工中正确更新的情况下，在频繁使用情况下，将流量与这些被删除目标进行了平衡。

与往常一样，此处提供Kong Gateway 1.4的[文档](https://docs.konghq.com/)。
此外，我们将在后续帖子和[社区电话](https://konghq.com/community-call/)中讨论1.4中的关键功能，敬请期待！

感谢我们的用户，贡献者和核心维护者社区，感谢您对Kong开源平台的持续支持。

请尝试一下Kong Gateway 1.4，并确保[让我们知道您的想法](https://discuss.konghq.com/)！

## Kong社区

像往常一样，随时在我们的社区论坛[Kong Nation](https://discuss.konghq.com/)上提问。
从您的反馈中吸取教训，将使我们能够更好地了解关键任务用例并不断改进Kong。

Happy Konging!