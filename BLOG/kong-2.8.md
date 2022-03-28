# Kong 2.8 已经发布：提高安全性，简化API管理

今天，我们激动地宣布，Kong Gateway 2.8发布啦，它进一步简化了API管理，并提高提高跨任何基础架构的服务安全性。Kong 对客户和社区的持续承诺，通过提供下一代服务连接平台，在现代架构中智能地代理各类信息。

Kong Gateway 2.8的开源和商业版本现在都可以从各个分销渠道下载或购买使用。

# 秘钥管理( Beta ）【Kong开源版/Kong企业版】

在Kong Gateway 2.8发布的新功能中，首先是一个名为秘钥管理管理的新功能集，目前还是测试版。

在我们开始之前，先定义一下「secret」的含义。在这种情况下，一个秘钥是正确的网关操作所需的敏感信息。秘钥可能是核心网关配置的一部分，例如，数据库连接信息，或者作为与网关服务的api关联的配置的一部分。一些最常见的秘密类型包括:

- 特殊帐户凭据
- 密码
- 证书
- API密钥


# 从「分散秘钥」转向集中化管理

通过Kong的秘钥管理，客户可以利用他们自己的集中管理的秘钥管理基础设施。有助于遵守IT安全策略，并确保网关操作所需的敏感信息是最新的，并由适合的使用者来掌握。


# 提高整体安全性

有了Kong的秘钥管理功能，运营商和开发者可以在开发、测试和部署api时独立工作。随着运营商将更多的基础设施(如new一个数据库)在线化，以支持不断变化的应用程序需求，敏感信息首先根据IT安全治理需求添加到集中式秘密管理器(如[HashiCorp Vault](https://www.vaultproject.io/))。这些秘钥将作为变量在Kong Gateway配置中引用，从而使Kong部署更加便携和安全。

配置秘钥管理后，Kong Gateway数据平面将向第三方秘钥管理器(如[AWS secrets Manager](https://aws.amazon.com/secrets-manager/)和Hashicorp Vault)请求秘钥，并在数据平面上解析秘钥的值。通过使用具有直观语法的简单变量，开发人员可以在声明性的配置、OpenAPI规范和CI/CD管道中引用秘钥的值，以便在运行时仅在需要的地方临时解除对秘钥值的引用，例如，Kong数据平面。

![秘钥管理](https://2tjosk2rxzc21medji3nfn1g-wpengine.netdna-ssl.com/wp-content/uploads/2022/03/Secrets-Management.png.webp)

通过Kong的新秘钥管理功能，在整个API管理生命周期中使用的任务关键密钥和网关部署都是集中管理的，可审计的，并防止未经授权的使用。这个秘密管理功能包括以下功能:

- 使用预先构建的「Connectors」到AWS Secrets Manager 和Hashicorp Vault，甚至使用环境变量访问和存储秘钥。
- 使用一个简单和直观的变量使用到Kong的配置中。
- 在Kong数据平面上自动解析秘钥，秘钥的值只存在于内存中，并在整个部署过程中被混淆。


《Kong Gateway 2.8》的秘钥管理功能目前已提供公测版本。企业客户可以使用AWS秘密管理器和Hashicorp Vault集成。有关可用性和功能的详细信息，请查看此处的[文档](https://docs.konghq.com/gateway/2.8.x/plan-and-deploy/security/secrets-management)。

# Kong Manager 新增过滤/分类功能【Kong企业版】

（略）

# 双向TSL认证Forward Proxy高级插件【Kong企业版】

（略）


# 其他亮点

在插件前端，我们添加了一些新功能：

- 我们已经为我们流行的[OpenID Connect (OIDC)插件](https://docs.konghq.com/hub/kong-inc/openid-connect/)添加了对Distributed Claims 的支持，它被一些OIDC提供商使用，比如Azure Active Directory和其他。

- 我们收到了一个社区合并请求，要求在[限速插件](https://docs.konghq.com/hub/kong-inc/rate-limiting/)上增加配置Redis用户名的能力(感谢[27ascii!](https://github.com/27ascii))我们已经合并了这个功能，不仅在速率限制插件中，而且在我们的[速率限制高级插件](https://docs.konghq.com/hub/kong-inc/rate-limiting-advanced/)、[响应速率限制插件](https://docs.konghq.com/hub/kong-inc/response-ratelimiting/)、[OIDC插件](https://docs.konghq.com/hub/kong-inc/openid-connect/)和[代理缓存高级插件](https://docs.konghq.com/hub/kong-inc/proxy-cache-advanced/)中添加了这个功能。


作为一个独立且值得关注的版本，[decK](https://docs.konghq.com/deck/)在[v1.11](https://github.com/kong/deck/blob/main/CHANGELOG.md#v1110)中得到了增强，改善了声明式配置体验:

- 首先，decK现在支持核心实体的[默认值](https://docs.konghq.com/deck/1.11.x/guides/defaults/)，并在schema端点的帮助下支持插件。总的来说，这将降低管理Kong Gateway所需的配置文件的复杂性。
- 其次，在validate命令中添加了一个`--online`标志，它将对Kong API执行验证，而不会影响Kong Gateway的状态。使用该标志将有助于捕获配置问题之前，试图通过[deck sync](https://docs.konghq.com/deck/1.11.x/reference/deck_sync/)设置网关。

# 开始使用Kong Gateway 2.8吧

相关功能，修复和更新的完整列表，请查看[这里](https://docs.konghq.com/gateway/changelog)，Kong Gateway OSS查看[这里](https://github.com/Kong/kong/blob/master/CHANGELOG.md)

现在就开始使用Kong Gateway 2.8 - 商业版和开源版都可以[免费下载](https://konghq.com/install/)!如果你已经安装了Kong Gateway，升级到2.8是很容易的，可以查看[升级指南](https://docs.konghq.com/gateway/latest/install-and-run/upgrade-enterprise/#main)。别忘了让我们知道你对[Kong Nation](https://discuss.konghq.com/)的看法!

请继续关注我们即将发布的博文，我们将更多地讨论Kong Gateway 2.8的秘钥管理能力。










