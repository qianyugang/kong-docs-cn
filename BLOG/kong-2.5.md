# Kong 2.5 正式发布了！

原文链接：https://konghq.com/blog/kong-gateway-oss-2-5/

哈喽，Kong的使用者们，我们已经制作了一个崭新版本的Kong Gateway（OSS）2.5，现在支持所有渠道上使用。请继续阅读更多发布信息。

## 性能提升

### 一个全新的测试框架

想象一下，你正在访问一个银行网站，以便在假期期间向朋友和家人转账。如果电汇在一定的秒数内没有发送或完全失败，作为用户，您可能会关闭浏览器，去找其他的方法。

在构建健康的生产系统和api时，了解性能对消费你的服务的客户的作用至关重要，否则你可能会将客户输给他们的竞争对手。为了了解性能，我们在2.5版本中发布了一个新的[性能测试框架](https://docs.konghq.com/gateway-oss/2.5.x/performance-testing-framework/)，它提供了一种有效的方式来进行 Kong Gateway （OSS）的性能基准测试。 

该框架用于评估Kong Gateway（OSS）本身与捆绑或自定义插件的性能，以及绘制框架图来调试性能瓶颈。该框架内置在Kong Gateway (OSS)现有的集成测试方法中，使得开发性能测试更加容易。请查看[Kong Repository](https://github.com/Kong/kong/tree/master/spec/04-perf)中的示例，以便入门。

如果你正在进行容量规划/评估如何建立正确的Kong Gateway（OSS）环境以满足你的部署要求，那么性能测试框架将帮助您了解Gateway在特定EC2实例上每秒的请求。通过这种方式，可以准确地估计硬件需求并节省成本。或者，如果你想了解带有自定义插件的Kong Gateway（OSS）的特定配置如何在你的环境中运行，可以使用框架来测量 Gateway 管理的上游api的延迟。一旦构建Kong Gateway（OSS）和运行测试的方法，在自己的硬件上运行性能测试框架就很简单了。请留意我们计划很快发布的博客，告诉你如何做到这一点!

在Kong Gateway (OSS) [Github Repository](https://github.com/Kong/kong)上，我们已经开始使用[Github Actions](https://github.com/Kong/kong/blob/master/.github/workflows/perf.yml)整合框架——让维护者能够在单个 pull 请求或发布分支上触发性能测试。维护Kong Gateway(OSS)需要在性能和丰富的特性集之间不断权衡。有了这个性能框架，维护人员就有能力绘制随时间变化的性能趋势，从而确保每次提交都能保持Kong Gateway（OSS）社区所期望的高性能标准。

## 混合模式

### 加强基础工作

在混合模式下，Kong Gateway (OSS)扮演数据平面的角色，动态地为您的api委派请求流量，同时扮演控制平面的角色，在多个Kong Gateway数据平面上同步网关配置。作为Kong Gateway (OSS)最流行的部署模型之一，我们已经开始在2.5中为即将到来的一些高级特性打下基础!请看下面的混合模式部署模型的最新增强功能。

混合模式新增功能如下：

- Kong Gateway现在在数据平面上公开了一个上游健康检查端点（使用状态API），以便更好地观察。更多信息请参见[数据平面上的只读状态API端点](https://docs.konghq.com/gateway-oss/2.5.x/hybrid-mode/#readonly-status-api-endpoints-on-data-plane)。[#7429](https://github.com/Kong/kong/pull/7429)
- 控制平面在混合模式下检查数据平面的兼容性时，现在更加宽松了。更多信息请参见混合模式指南中的[版本兼容性](https://docs.konghq.com/gateway-oss/2.5.x/hybrid-mode/#version_compatibility)部分。[#7488](https://github.com/Kong/kong/pull/7488)
- 控制计划现在可以向新的数据计划发送更新，即使控制计划失去与数据库的连接，以获得更好的弹性。[#6938](https://github.com/kong/kong/pull/6938)
- 当在混合模式下运行时，Kong 现在会自动将 `cluster_cert` ( `cluster_mtls=shared`) 或 `cluster_ca_cert` ( `cluster_mtls=pki`) 添加到 `lua_ssl_trusted_certificate`。在此之前，混合模式用户需要手动配置`lua_ssl_trusted_certificate`，作为Lua验证控制平面证书的要求。这将使设置数据平面的速度更快一些。更多信息请参见混合模式指南中的启动数据平面节点。[#7044](https://github.com/kong/kong/pull/7044)
- 一些bug[修复](https://github.com/Kong/kong/blob/master/CHANGELOG.md#fixes)。



## 插件开发

以下插件做了改进更新：

- **hmac-auth**: HMAC认证插件现在支持签名字符串中的`@request-target`字段。在此之前，，该插件使用`request-line`参数，其中包含HTTP请求方法、请求URI和HTTP版本号。签名中包含HTTP版本号导致对同一目标的请求使用不同的请求方法(如HTTP/2)产生不同的签名。新增加的`request-target`字段在计算哈希值时只包括小写的请求方法和请求URI，从而避免了这些问题。有关更多信息，参阅HMAC[HMAC认证](https://docs.konghq.com/hub/kong-inc/hmac-auth)文档。[#7037](https://github.com/kong/kong/pull/7037)
- **syslog**：Syslog插件现在包括设施配置选项，这是插件对来自不同来源的错误信息进行分组的一种方式。更多信息请参见Syslog文档中的[Parameters](https://docs.konghq.com/hub/kong-inc/syslog/#parameters)部分对设施参数的描述。[#6081](https://github.com/kong/kong/pull/6081)
- **Prometheus**：插件现在可以在控制平面上显示连接的数据平面的状态。新指标包括以下内容：`data_plane_last_seen`、`data_plane_config_hash`和`data_plane_version_compatible`。当数据平面在整个集群中的配置不一致时，这些指标可以用于故障排除。更多信息请参见Prometheus插件文档中的[Available Metrics](https://docs.konghq.com/hub/kong-inc/prometheus/#available-metrics)部分。[#98](https://github.com/Kong/kong-plugin-prometheus/pull/98)
- **Zipkin**：Zipkin插件现在包括以下标签：`kong.route`、`kong.service_name`、`kong.route_name`。更多信息请参见Zipkin插件文档中的[Spans](https://docs.konghq.com/hub/kong-inc/zipkin/#spans)部分。[#115](https://github.com/Kong/kong-plugin-zipkin/pull/115)


完整的修改列表和相关的PRs请查看[CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md)。

## 感谢

社区集体受益于个人贡献者的专业知识、关心和关注。怀着感激和特别感谢的心情，我们想表彰以下对2.5版本的贡献者。@jideel， @ealogar， @yamaken1343， @onematchfox， @maxipavlovic @yamaken1343， @ocean-moist， @lockdown56， @hnlq715和@jackkav。


