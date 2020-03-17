# Kong 2.0 发布！

从上一次主要开源版本发布以来，经过整整一年的发展，我们很荣幸地宣布旗舰开源API网关的下一个章节 - Kong Gateway 2.0全面上市！

## 混合模式部署（Hybrid Mode Deployment）

混合模式也称为Control Plane/Data Plane分离（CP / DP），它可以将Kong的代理有效，安全地部署在任何地方，然后可以从单个点（Control Plane）控制整个群集。在这种模式下，Data Plane节点不连接到数据库。而是根据需要由控制平面管理和推送其配置。此功能可显着提高大型Kong群集的安全性和性能，同时降低运营成本。要开始混合模式部署，请参考[混合模式文档](https://docs.konghq.com/2.0.x/hybrid-mode)。

![](https://2tjosk2rxzc21medji3nfn1g-wpengine.netdna-ssl.com/wp-content/uploads/2020/01/WX20200121-021513@2x-1024x536.png)

## 支持 golang的PDK

Lua是用于编写Kong插件的实际使用的语言。虽然Lua的性能良好且非常易于嵌入，但它在开发人员体验，第三方库和普遍欢迎方面都达不到要求。在2019年Kong Summit峰会期间，我们透露了对Go的Go插件支持，从而使开发人员可以使用Go完全开发其插件。

为了帮助开发人员入门，我们还准备了[Go Plugin Development Guide](Go Plugin Development Guide)和[Go Plugin Development Kit（PDK）](Go Plugin Development Kit (PDK))文档。我们迫不及待想看看开发人员将与他们一起做什么！

## ACME (Let’s Encrypt) 加密支持

在过去的几年中，我们看到了行业中端到端加密的强劲推动。如今，由于服务具有自动配置和管理TLS证书的功能，因此服务的HTTPS加密已被视为一种商品，而不是一种奢侈。我们很自豪地宣布，由于新的[自动证书管理环境（ACME）](https://ietf-wg-acme.github.io/acme/draft-ietf-acme-acme.html)v2协议支持和Let's Encrypt集成，在Kong Gateway 2.0中，端到端HTTPS比以往更加容易。只需启用插​​件，Kong便会负责整个证书管理生命周期。有兴趣尝试可以查看[ACME插件文档](https://docs.konghq.com/hub/kong-inc/acme/index.html)。

## 其他改进

请注意，以上列表仅涉及此版本中的部分功能/修复！有关更改的完整列表，我们建议您也阅读[2.0.0更改日志](https://github.com/Kong/kong/blob/master/CHANGELOG.md#200)。

### Prometheus 插件性能

由于我们的工程团队一直在进行一些巧妙的调整，因此Prometheus插件现在可以以几乎两倍的速度（按每秒请求数）运行。

### 扩展支持 NGINX Directive 注入

为`http`和`stream`子系统添加了新的注入上下文，从而减少了编写自定义NGINX模板的需要，并为用户提供了更好的升级兼容性。

## Kubernetes 兼容性

最新的[Kong for Kubernetes](https://github.com/Kong/kubernetes-ingress-controller) 0.7版本与开箱即用的Kong Gateway 2.0兼容。立即开始使用Kong for Kubernetes！

### 升级路径

随着2.0的发布，我们还发布了Kong Gateway 1.5，它充当了较旧版本的Kong Gateway和带有API实体到服务/路由迁移工具的新2.x系列之间的桥梁。

不支持从0.x版本的Kong Gateway直接升级到2.x。而是，这些用户应先从0.x升级到1.5，然后再升级到2.0.0。

从现在开始，我们正式放弃对0.x版本的支持。

## 下一步

不用说，Kong 员工和我们出色的社区贡献者为此发布付出了多少工作。 Kong Gateway 2.0.0现已开始下载，我们鼓励所有人尝试一下。与往常一样，请通过Kong与我们分享有关[Kong Nation](Kong Nation)的反馈，并查看我们将来的[社区活动](https://konghq.com/community/)以与我们建立联系。

Happy Kong!


