# Kong Gateway 3.0正式发布！

原文链接：https://konghq.com/blog/kong-gateway-3-0

Kong Gateway 3.0是一个重要的里程碑版本，它引入了我们原生云API平台的下一个发展。Kong Gateway 3.0的企业版和开源版现在都可以从各个发行渠道获得。
 
在Kong Gateway 3.0中，我们引入了许多功能强大的功能，可带来以下主要好处：

- **更强的安全性和治理能力：**符合 FIPS 140-2 的安全机密存储的合规要求(跨网关操作和插件)
- **灵活性和可扩展性：**客户可以选择他们的插件执行顺序，添加对WebSocket通信的本地支持，深度集成OpenTelemetry。
- **简单的API管理：**Kong Manager UI的新功能增强了用户体验。引入一个功能强大的新路由引擎，优化了复杂路由的表达，同时也提高了运行性能。
- **显著的性能改进：**与Kong 2.8.1.4相比，在高复杂性的路由场景，吞吐量提高37%，延迟至少降低27%、很大概率(99%的情况下)降低47%，内存消耗减少了9%。



# Tracing 和 OpenTelemetry

了解Kong Gateway如何执行是部署的关键一环，我们很高兴地宣布在Kong Gateway 开源版和企业版中都提供了广泛的跟踪支持。有两种方法可以开始。可以使用开箱即用的 OpenTelemetry 插件直接将OTel发送到任何兼容的后端，或发送到 OpenTelemetry 收集器。我们一直在用 Honeycomb 测试 Kong Gateway，它很管用。

这是一个代理一个请求到 mockbin.org 的跟踪：
![](https://kongwp.imgix.net/wp-content/uploads/2022/09/image-1.png?auto=compress%2Cformat&fit=scale&h=177&w=2048)
*图1:将单个请求代理到mockbin.org的跟踪*

然后同样的请求，一旦启用速率限制插件(使用Redis)：
![](https://kongwp.imgix.net/wp-content/uploads/2022/09/image-2.png?auto=compress%2Cformat&fit=scale&h=201&w=2048)
*图2:启用速率限制插件的相同请求*

第二个选择是使用Kong的跟踪插件开发工具包(PDK)来挂钩所有关键事件。这就是 OpenTelemetry 插件的工作方式，它可以完全控制如何收集和抽样跟踪信息，以及如何将数据导出到其他系统。

无论您选择哪种选择，了解Kong Gateway的表现是关键。确定在每个请求上花费的时间可以帮助您优化更高的性能，从而优化用户体验。
 

# Websockets (Beta) (企业版)

# 秘钥管理(GA)

我们最初在 Kong Gateway 2.8 中发布了 Secrets Management 测试版，我们很高兴地宣布，在本版本中已正式支持。

Secrets Management 允许您将敏感信息安全地存储在外部存储中(用于OSS的环境变量、AWS Secrets Manager 和用于企业的HashiCorp Vault)中，Kong可以在运行时访问这些外部存储。通过将敏感值作为机密存储，可以确保它们不以明文形式通过平台、在`Kong.conf`或声明性配置文件、日志或 Kong Manager UI 中可见。

此外，使用 Secrets Management 可以为开发、预发布和生产环境提供特定的值，同时使用完全相同的声明性配置文件配置每个环境。

开始Secrets Management 是很容易的，在之前设置明文密码的任何地方，将其替换为一个保险库路径，例如:

```
{vault://hcv/redis/password}
```

Kong将检测到此引用，并在运行的时候安全地解析。

要更深入地了解秘密管理，请关注我们即将发布的博客，该博客将介绍如何在使用代理缓存高级插件时在 HashiCorp Vault 中存储 Redis 密码。 
  
  
# FIPS 140-2 Compliance(企业版)

# 插件排序(企业版)

# 新的路由引擎

这个新功能还是有一些技术含量，Kong Gateway 3.0附带了一个全新的「表达式」路由引擎，可以使用该引擎将请求路由到上游 api。

假设想要路由GET和POST请求，但仅当它们是HTTP请求时。如果不用使用 JSON 来配置路由，可以写一个如下所示的表达式:
 
```
net.protocol == "https" && (http.method == "GET" || http.method == "POST")
```

这是一个简单的示例，但是假设希望路由与特定主机匹配的请求，并包含包含主机名的头信息。这是很难预想的，所以让我们来看看它是什么样子的：

```
(http.host == "example.com" && http.headers.x_example_version == "v2" ) ||

(http.host == "store.example.com" && http.headers.x_store_version == "v1") 
```

只有当主机为`example.com`且header头`x-example-version`头的值是`v2`，或者host为`store.example.com`且header头`x-store-version`头为`v1`时，此路由才会匹配。这是Kong Gateway 3.0新路由引擎灵活性的一个很好的例子。如果在2.x中实现相同的功能将要创建两个单独的路由。

新路由器不仅表现力更强，性能也更好，大型路由配置现在可以增量地重新加载，而不是每次配置更改时都重新构建整个路由器。这使得P99时间在我们的测试中从1.5s减少到0.1s。

最后，介绍一下2.x中的JSON路由器。在这个版本中依旧可以使用，因为目前需要支持现有的路由规则，所以在3.0中保留了现有的路由器。你可以在 `kong.conf` 中将 `router_flavor` 设置为`traditional`，那么路由匹配会和2.x版本一样。

# Kong Manager 3.0(企业版)

# 弃用项和删除项

Kong对稳定性的承诺意味着我们在一个主要版本的所有发行版中都保持向后兼容性。Kong Gateway 3.0让我们有机会弃用一些功能，并删除其他功能，以提高产品的质量。

以下是已弃用或删除的项目:

- Kong Gateway不再使用启发式来猜测一条路径是否正确。Path是一个正则表达式模式。从3.0开始，所有的正则表达式路径都必须以“~”前缀开头，所有不以“~”开头的路径都将被视为纯文本。从2.x升级到3.0.x，迁移过程应该会自动转换正则表达式路径。
- 3.0版本弃用对`nginx-opentracing`模块的支持，将在4.0版本时移除。并使用新的跟踪PDK和OpenTracing模块作为替换
- Amazon Linux 1 和 Debian Jesse 不再是官方支持的操作系统。
- 目标端点上的POST请求不再能够更新现有实体。他们只能创造新的。如果您有使用POST请求修改/目标的脚本，在更新到Kong Gateway 3.0之前，将它们更改为对适当端点的PUT请求。
- Prometheus 插件默认禁用高基数度量。这样 Prometheus 在清除统计信息时会减少数据库的负载。
 

# 额外亮点


- 插件版本一致：要确定你之前运行的是哪个版本的插件是很困难的。从Kong Gateway 3.0开始，插件版本与网关版本保持一致，这样人们就可以确切地知道他们运行的是哪个版本的插件
- Slim/UBI 镜像：我们已经将Docker构建的基本镜像切换为debian-slim 和 rhel-ubi。这意味着镜像更小，安装的软件包更小，从而获得更安全的镜像。
- 系统证书颁发机构：Kong 现在默认使用安装在主机操作系统上的任何CA证书。这允许您在一个地方为所有软件管理证书颁发机构
- LDAP认证：LDAP 认证插件可以通过对 LDAP 服务进行认证来保护服务。Kong Gateway 3.0 增加了基于组成员资格的授权支持。例如「只有 FinanceDev 团队的成员才能访问这个API」。
 

