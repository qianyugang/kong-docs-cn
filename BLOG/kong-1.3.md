# Kong 1.3发布！支持原生gRPC代理，上游双向TLS认证，以及更多功能

> 原文地址：https://konghq.com/blog/kong-1-3-released/

今天，我们很高兴地宣布推出Kong 1.3！我们的工程团队和出色的社区为此版本提供了许多功能和改进。基于1.2版本的成功，Kong 1.3是Kong的第一个版本，它本身支持gRPC代理，上游相互TLS身份验证，以及一系列新功能和性能改进。

请阅读以下内容，了解有关Kong 1.3的新功能，改进和修复的更多信息，以及如何利用这些令人兴奋的变化。
请花几分钟时间阅读我们的[更新日志](https://github.com/Kong/kong/blob/1.3.0/CHANGELOG.md#130)以及[升级路径](https://github.com/Kong/kong/blob/1.3.0/UPGRADE.md#upgrade-to-13)以获取更多详细信息。

## 原生gRPC代理

我们观察到越来越多的用户转向微服务架构，并听到用户表达他们对本机gRPC代理支持的兴趣。Kong 1.3通过支持gRPC本地代理来解决这个问题，为支持gRPC的基础架构带来更多控制和可见性。

### 主要优点：

- 简化运营流程。
- 为gRPC服务添加A / B测试，自动重试和断路，以提高可靠性和正常运行时间。
- 更多的可观测性
- 针对gRPC服务的日志记录，分析或Prometheus集成？Kong让你满意。

### 主要功能：

- 新协议：Route和Service实体的`protocol`属性现在可以设置为`grpc`或`grpcs`，这对应于通过明文HTTP/2(h2c)的gRPC和通过TLS HTTP/ 2(h2)的gRPC。

## 上游双向TLS认证

Kong长期以来一直支持与上游服务的TLS连接。
在1.3中，我们添加了对Kong的支持，以提供特定证书，同时与上游握手以提高安全性。

### 主要优点：

- 能够使用证书与上游服务握手使得Kong在需要强大的身份验证保证的行业中更加出色，例如金融和医疗保健服务。
- 安全性更好
- 通过提供可信证书，上游服务将确定传入请求是由Kong转发的，而不是恶意客户端。
- 对开发人员更友好
- 您可以使用Kong将需要相互TLS身份验证的服务转换为与开发人员无关的方法(例如OAuth)。

### 主要功能：

- 新配置属性：`Service`实体具有新字段`client_certificate`。如果设置，当Kong尝试与服务握手时将使用相应的证书。

## Sessions 插件

在Kong 1.3中，我们开放了[Sessions插件](https://github.com/Kong/kong-plugin-session)（之前仅在[Kong Enterprise](https://konghq.com/kong-enterprise/)中提供）供所有用户使用。
结合其他身份验证插件，它允许Kong记住之前已经过身份验证的浏览器用户。
您可以在[此处阅读详细的文档](https://docs.konghq.com/hub/kong-inc/session/)。

## NGINX CVE修复

Kong 1.3附带NGINX HTTP/2模块（[CVE-2019-9511](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-9511)，[CVE-2019-9513](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-9513)，[CVE-2019-9516](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-9516)）的修复程序。
我们还发布了Kong 1.0.4,1.1.3,1.2.2来修补旧版Kong中的漏洞，以防不能立即升级到1.3。

## OpenResty Version Bump

OpenResty的版本已经发布到最新的OpenResty版本 - [1.15.8.1](https://openresty.org/en/ann-1015008001.html)，该版本基于Nginx 1.15.8。
此版本的OpenResty在关闭上游keepalive连接，ARM64架构支持和LuaJIT GC64模式时带来了更好的性能。
最引人注目的变化是，由于LuaJIT编译器生成更多本机代码，OpenResty更有效地存储请求上下文数据，因此使用密钥身份验证在基线代理基准测试中，Kong现在运行速度提高约10％。
![](https://quip.com/blob/SHPAAAnUJ6J/u3CLa2gdWXVrKGn86hZdhw?a=ciuW3AoK5D202gwY9eqIe2YhcYMEqafpa8ufn3rQeoYa)

## Kong 1.3的其他新功能

### 按任何请求 header 路由

- Kong的路由器现在能够通过任何请求头（不仅是`Host`）匹配路由。
- 这允许对服务之间路由传入流量的方式进行精细控制。
- 请[参阅此处的文档](https://docs.konghq.com/1.3.x/proxy/#request-header)

### 最少连接负载平衡

- Kong现在可以将流量发送到连接数最少的上游服务。
- 在某些用例中改善上游负载分配。
- 请[参阅此处的文档](https://docs.konghq.com/1.3.x/admin-api/#update-or-create-upstream)

### 数据库导出

- 新添加的`kong config db_export` CLI命令可用于创建数据库内容转储到YAML文件中，该文件适用于声明性配置或稍后导回数据库。
- 这样可以更轻松地创建声明性配置文件。
- 这使得Kong配置的备份和版本控制变得更加容易
- 请[参阅此处的文档](https://docs.konghq.com/1.3.x/cli/#kong-config)

### 主动关闭上游keepalive连接

- 在旧版本的Kong中，上游连接永远不会被Kong关闭。这可能导致竞争条件，因为Kong可能会尝试重新使用keepalived连接，而上游尝试关闭它。
- 如果您在Kong `error.log`中看到“upstream prematurely closed connection”错误，则此版本应显着减少甚至消除部署中的此错误。
- 添加了新的配置指令来控制此行为，请阅读完整的[更新日志](https://github.com/Kong/kong/blob/1.3.0/CHANGELOG.md#130)以了解更多信息。

### 更多的监听标志支持

- 特别是`reuseport`标志，如果Kong worker数量很大，可用于改善负载分配和延迟抖动。
- 还添加了`deferred`和`bind`标志支持。您可以查看NGINX listen指令文档以了解使用它们的效果。

## 其他改进和错误修复

Kong 1.3还包含有关存储CA证书（没有私钥的证书），Admin API接口和更多PDK功能的新实体的改进。
我们还修复了很多错误。由于此版本中有大量新功能，因此我们无法在此博客文章中介绍所有这些内容，而是鼓励您在此处阅读完整的[更新日志](https://github.com/Kong/kong/blob/1.3.0/CHANGELOG.md#130)。

我们还在`kong.conf`模板中添加了一个新的部分，以更好地解释注入NGINX指令的功能。
对于具有仅添加几个NGINX指令的自定义模板的用户，我们建议切换使用注入的NGINX指令，以获得更好的可升级性。

与往常一样，[Kong 1.3的文档可在此处获得](https://docs.konghq.com/)。
此外，如上所述，我们将在后续帖子和[社区电话](https://konghq.com/community-call/)中讨论1.3中的主要功能，敬请期待！

感谢我们的用户，贡献者和核心维护者社区，感谢您对Kong的开源平台的持续支持。
请试试Kong 1.3，一定要[告诉我们您的想法](https://discuss.konghq.com/)！

## Kong社区

像往常一样，随时可以就我们的社区论坛[Kong Nation](https://discuss.konghq.com/)提出任何问题。
从您的反馈中学习将使我们能够更好地理解任务关键用例并不断改进Kong。









