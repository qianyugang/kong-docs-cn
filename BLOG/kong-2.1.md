# Kong 2.1 正式发布！

**原文链接：** https://konghq.com/blog/kong-gateway-2-1-released/

我们很高兴地宣布，我们的旗舰[开源API网关](open source API gateway)2.1系列的第一个版本!

自从1月份Kong 2.0发布以来，我们已经发布了很多补丁，但我们也一直在忙着编写新特性!这个版本包含了很多新功能，从P99延迟的改进到gRPC的新特性，对您喜爱的插件的改进等等。以下是其中的亮点:

此外，[Kong企业版](https://konghq.com/products/kong-enterprise/)的发布时间与社区版保持一致，这一点我们非常努力。Kong Enterprise 2.1，包含了Kong Gateway 2.1的所有功能，今天也提供了[测试版](Beta)!您可以[点击此处](http://docs.konghq.com/enterprise/2.1.x/release-notes/)这里了解更多关于Kong Enterprise及其附加功能。

## 异步负载平衡器更新

Kong 的主要目标之一不仅是提供高性能，而且是可预测的、稳定的性能。造成性能不稳定的一个常见原因是，当应用程序需要重新配置自身时，会出现延迟峰值。在之前的版本中，我们将所有对Kong内部内存结构的路由和服务的更新都异步进行，从而改善了我们观察到的P99延迟数。

从Kong Gateway 2.1开始，负载均衡器的重新配置异步进行。这意味着对上游和目标实体所做的配置更改将不会再导致明显的延迟峰值。

就像路由器和服务更新一样，您可以在严格(synchronous)模式和最终一致(asynchronous)模式之间进行配置——实际上，这些配置已经统一用于路由器和负载均衡器。

## 新的 gRPC 插件

Kong Gateway 2.1引入了两个专门针对gRPC流量的新插件，以扩展我们对gRPC的支持:

- [grpc-web](https://github.com/Kong/kong-plugin-grpc-web)：这个插件允许通过[gRPC-web](https://github.com/grpc/grpc-web)协议访问gRPC服务。首先，这意味着使用[gRPC-Web](https://github.com/grpc/grpc-web)库的JS浏览器应用程序。
- [grpc-gateway](https://github.com/Kong/kong-plugin-grpc-gateway) ：这个插件允许您通过HTTP REST接口公开gRPC服务。它以JSON格式转换请求和响应，允许通过普通HTTP请求访问上游gRPC服务。

## 插件的全面改进

Kong Gateway 2.1的许多插件提供了新的功能:

- Zipkin：增加了可配置性和对跟踪标准的支持，增加了对B3和W3C头的支持。
- Rate-Limiting：由自定义标题和Postgres自动清除的速率限制。
- OAuth2：持久刷新token，PKCE和客户哈希秘钥。
- AWS-Lambda：支持定制Lambda端点，这对于测试环境特别有用。
- Prometheus：支持从上流跟踪运行状况检查信息，以及显著的性能改进
- Serverless：能够在任何请求处理阶段注入用户定义的Lua函数，为您提供了极大的灵活性，可以编写各种“微插件”作为代码片段，并将它们注入到您的代理路径中，而无需部署自定义插件
- LDAP：虚拟凭证现在可以用作速率限制标准
- 各种身份验证插件现在发出统一的X-Credential-Identifier 头，因此，无论使用何种身份验证方法，客户端服务都可以检查标识符。

## Postgres只读副本支持

如果将Kong与Postgres一起使用，那么现在还可以配置只读Postgres副本。配置完成后，Kong将通过只读副本执行读操作，而不是通过主读写连接执行读操作。这允许您将Kong集群的数据库负载分散到只读副本中，以获得更好的性能。

## Kong Gateway 2.1的其他改进和修复

- 动态upstream keepalive 池：当Kong通过TLS将流量代理到虚拟服务(托管在同一个IP/端口上)时，这一改变绕过了NGINX的限制，并防止了虚拟主机的混乱。Keepalive池现在还考虑SNI和客户端证书，而不仅仅是IP和端口。此外，这个改变允许为上游保持活动的连接指定一个不确定的最大请求数量和空闲超时阈值，这个功能之前已经被NGINX 1.15.3删除了。
- TLS验证参数的每个服务定制：这为安全服务的配置提供了更大的灵活性，使得使用相互TLS (mTLS)的服务特别方便。
- 混合模式和声明式配置的改进：2.0版本以来,Kong 支持混合模式,您可以有单独的Kong 节点专用控制平面节点和数据库访问和管理API(配置和无代理)或数据平面节点(只接受节点运行数据库,接受它的配置而不是从控制平面节点)。Kong Gateway 2.1包括改善混合模式体验的更新:
    - 支持PKI mtl混合模式
    - 证书到期和CA为混合模式约束检查证书
    - 以声明式配置格式进行更新，允许导入带有或不带散列密码的凭据——这对所有[无db模式](https://docs.konghq.com/latest/db-less-and-declarative-config/)用户也是一个受欢迎的添加!
- 一些API添加到插件开发工具包：我们为插件开发人员提供的API——plugin Development Kit (PDK)不断得到增强，添加了新的模块和方法，包括更多用于TLS控制的函数、改进的L4支持等等。查看最新的[PDK文档](https://docs.konghq.com/latest/pdk/)了解详细信息!
- bug 修复：除了2.0中已经包含的所有修复之外。在x系列中，Kong Gateway 2.1包括了一些需要引入额外功能的修复，因此，通过语义版本化，被包括在2.1.0中:
    - 通过引入摘要字段正确索引大型CA证书数据。
    - 现在已将Authorization值从已记录的标题列表中删除
    - ACL插件现在返回HTTP状态401未经授权而不是403禁止。

## 关注社区贡献

Kong Gateway 2.1的一些新功能是我们的GitHub开源社区贡献的代码(26k stars，还在不断增加中!)我们想通过大声疾呼来感谢这些贡献：

- @Abhishekvrshny：Cassandra读写操作的可配置一致性级别。
- @ealogar：可配置的负TTL缓存对象。
- @amberheilman：OAuth2的一些改进，包括PKCE支持、可选的客户端机密散列和持久刷新令牌的能力。
- @carnei-ro：Prometheus运行状况指标和自定义标头的速率限制。

有你们让我们的社区让这个项目变得更强更好。

## Kong Nation

一如既往，请随时向我们的社区论坛[Kong Nation](https://discuss.konghq.com/)提出任何问题。您的反馈可以让我们更好地理解关键任务用例，并不断改进Kong。

Happy Kong!

