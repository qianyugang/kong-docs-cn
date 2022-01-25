# Kong 2.7 已经准备就绪！

今天，我们将要迎来Kong Gateway的另一个值得关注的进步 - 2.7 版的全面发布！Kong Gateway 和 Kong Gateway OSS 2.7 版下载都可以在您最喜欢的分发渠道上下载。

此版本的 Kong Gateway 包含许多重要功能，可作为解决三个关键领域的基础：

- 规模：大规模管理 API 使用者组，并将这些组公开为「API层」。
- 安全性：安全地存储秘钥（在Gateway操作和插件中使用），以保证重要的密钥不被未经授权方使用。
- 合规性：使企业能够利用Kong作为一种面向未来的技术，在实现FIPS合规性的道路上。 

此次发布的Kong Gateway 2.7引入了新的功能，在所有这三个领域都取得了重大进展。在这篇文章的其余部分，我们将逐一介绍这些领域，并探讨Kong Gateway 2.7版本中的新功能。我们还将讨论在Kong Manager用户界面中引入的新的生产力改进，以配置我们最受欢迎的插件，[Kong OpenID Connect（OIDC）插件](https://docs.konghq.com/hub/kong-inc/openid-connect/)。

## 规模 - API消费者组 API Consumer Groups

许多用户部署Kong Gateway来保护他们的API。保护可以采取多种形式，如认证、授权、速率限制、IP范围限制或其他机制。能够在组的基础上实施类似的保护，是我们更加一致性的要求之一。

例如，开发人员可能想要创建用户（或「消费者」）的「层级」，例如「黄金」、「白银」或「青铜」——每个层级都有不同的速率限制。虽然在Kong Gateway中，通过将特定的费率限制配置附加到给定层级中的每个消费者，这种方法的功能是有限的。

从Kong Gateway 2.7开始，我们引入了消费者群体或 [「消费者组」](https://docs.konghq.com/gateway/2.7.x/admin-api/consumer-groups/reference)的正式概念。现在，你可以把消费者分配到 「黄金层级」组或 「白银层级」组，然后给每个层的速率限制配置，如 「每秒10个请求」，有效地使速率限制适用于消费者集合/组。然后，你将把这些组分配给你的网关配置中的特定路由/服务。

一个消费者也可以被分配到多个组。这意味着，你可以将一个用户分配到一个组，如 「黄金层级，每秒10个请求 」的二维码生成服务（"gold_limited_light_cpu"），也可以分配到一个组，如 「白银，每分钟2个请求 」的OCR（"gold_limited_heavy_cpu"），然后分割你的API来使用这些组中的每个。请看下面的图表。

![Diagram 1: Consumer Groups for Rate Limiting Advanced Plugin](https://2tjosk2rxzc21medji3nfn1g-wpengine.netdna-ssl.com/wp-content/uploads/2021/12/Diagram-1-Consumer-Groups-for-Rate-Limiting-Advanced-Plugin-1536x860.jpg.webp)

这一新功能通过将相关消费者集中在一个地方来简化配置，并通过在数据库或声明性配置中创建相关消费者组来提高 Kong Gateway 的性能。有关更多信息，请查看[消费者组示例](https://docs.konghq.com/gateway/2.7.x/admin-api/consumer-groups/examples)。限速高级插件实例是我们朝着消费群体方向迈出的第一步。将来，我们希望将此功能扩展到其他插件，敬请期待！

## 安全 – 秘钥管理

秘钥在Kong Gateway操作或插件配置中使用的一组认证和授权凭证。秘钥的一些例子可能包括用户名/密码、API令牌、数据库凭证、私钥。从操作人员的角度来看，像这样的敏感信息应该保持安全，避免未经授权的使用，并在需要时以加密格式存储。在《Kong Gateway 2.7》中，我们在这方面做了一些补充，包括:

- 扩展了钥匙圈和数据加密机制，以确保更多的插件和它们的相关配置（可能包含秘钥）可以利用该机制对静态数据进行加密。换句话说，更多的插件可以让他们的秘钥得到保护。

- 在Kong的混合部署模式下，能够为数据层的`config.cache.json.gz` 配置缓存进行静态加密。查看`kong.conf` 中的[新设置](https://docs.konghq.com/gateway/2.7.x/reference/configuration/#data_plane_config_cache_mode)中名为`data_plane_config_cache_mode`的新配置 - 将其设置为 `encrypted`，可以安全地存储配置缓存，作为一个可选项。

## 合规 - 通往FIPS合规企业的之路

我们已经开始替换Kong Gateway的加密基础，将网关(OpenSSL)中的主库替换为经过FIPS 140-2验证的库(BoringCrypto又名BoringSSL)，并将在新的一年开始发布企业级版本。这是迈向FIPS 140-2兼容的一步，而且还有更多计划！

## 其他增加项

确定开始使用OpenID Connect所需的最低配置集是一项相当具有挑战性的任务，特别是对于那些刚接触该协议的开发者。在2.7版本中，Kong Manager为配置OIDC插件和Kong Gateway提供了一个更加精简和有组织的方法。通过展示使用 OIDC 进行设置和运行的最常见方法（同时仍有能力根据需要添加更多的自定义配置），你可以更快速地与身份提供者建立单点登录。关于使用OpenID Connect和Kong的OIDC插件的更多信息，请访问我们的[文档](https://docs.konghq.com/gateway/2.7.x/configure/auth/oidc-use-case/)。

![](https://2tjosk2rxzc21medji3nfn1g-wpengine.netdna-ssl.com/wp-content/uploads/2021/12/Diagram-2-New-and-Improved-OIDC-Plugin-Configuration.png.webp)

## 探索更多发布内容

- 对跑[基于SNI的TLS流量路由](https://docs.konghq.com/gateway/2.7.x/reference/proxy/#proxy-tls-passthrough-traffic)的新支持 - 也称为SNI Proxy 
- Kong Gateway现在可以在[Debian 10和11](https://docs.konghq.com/gateway/2.7.x/install-and-run/debian/)上使用了。
- 当使用 [OpenID Connect](https://docs.konghq.com/gateway/2.7.x/configure/auth/kong-manager/oidc-mapping) 来保护 Kong Manager 管理员时，现在会在首次登录时创建并根据他们的组成员身份分配角色。

在这个版本中，我们继续[改进插件](https://docs.konghq.com/gateway/changelog/#plugins)迭代器的性能，简化Kong核心上下文的读/写，减少重新加载无数据库配置的延时。

关于Kong插件的功能、修复和更新的完整列表，可以在Kong Gateway的[CHANGELOG](https://docs.konghq.com/gateway/changelog)和[Kong Gateway OSS](https://github.com/Kong/kong/blob/master/CHANGELOG.md)找到。

Kong Gateway 2.7 今天可以[免费下载](https://konghq.com/install/) - 全新/干净安装！让我们知道您对 [Kong Nation](https://discuss.konghq.com/) 的看法。如果您已经安装了 Kong Gateway，您可以按照[升级指南](https://docs.konghq.com/gateway/latest/install-and-run/upgrade-enterprise/#main)升级到 2.7。要了解有关此版本的更多信息，请加入我们[即将举行的网络研讨会](https://konghq.com/webinars/protect-apis-services/)。

Kong Gateway版本更新只有在Kong员工、客户和社区成员的大量合作下才能实现。社区用户的积极支持使这个版本获得了成功，我们表示非常感谢!








