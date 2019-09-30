![image](https://user-images.githubusercontent.com/2004103/57691648-59208500-7677-11e9-9b6f-21ee0eb5a4dd.png)

Kong是一个云原生，快速，可扩展和分布式微服务抽象层（也称为API网关，API中间件或某些情况下的Service Mesh）。作为2015年的开源项目，其核心价值在于高性能和可扩展性。

由于对项目的积极维护，Kong被广泛用于从初创公司到全球5000强以及政府机构的生产中。

本文档是基于 https://docs.konghq.com/1.1.x/ `1.1.x` 版本，目前官网已经更新至 `1.3.x` 版本，如果使用的其他版本，请查看：

- https://docs.konghq.com/1.0.x/
- https://docs.konghq.com/1.2.x/
- https://docs.konghq.com/1.3.x/

**文档说明：http://www.102no.com/archives/1595**

# 安装文档目录

- **官方支持**

   - **包安装**
      * [使用 Docker 安装](INSTALL/docker.md)
      * [在 Ubuntu 上安装](INSTALL/ubuntu.md)
      * [在 CentOS 上安装](INSTALL/centos.md)
      * [在 macOS 上安装](INSTALL/macos.md)
      * [在 Vagrant 上安装](INSTALL/vagrant.md)
   - **云安装**
      * [在 Kubernetes 上安装 Kong 和 Kong Enterprise](INSTALL/kubernetes.md)
   - **源安装**
      * [使用源码安装](INSTALL/source.md)
      
      
# 开发文档目录

* **快速入门**
    * [简介](GETTING-STARTED/introduction.md)
    * [五分钟快速开始](GETTING-STARTED/quickstart.md)  
    * [配置一个服务](GETTING-STARTED/configuring-a-service.md)   
    * [启用插件](GETTING-STARTED/enabling-plugins.md)  
    * [添加消费者](GETTING-STARTED/adding-consumers.md)   
* **开发指南**
    * [配置](GUIDES&REFERENCES/configuration.md)    
    * [CLI](GUIDES&REFERENCES/cli.md)    
    * [代理](GUIDES&REFERENCES/proxy.md)    
    * [认证](GUIDES&REFERENCES/auth.md)       
    * [负载均衡](GUIDES&REFERENCES/loadbalancing.md)  
    * [健康检查和断路器](GUIDES&REFERENCES/health-checks-circuit-breakers.md)   
    * [集群](GUIDES&REFERENCES/clustering.md)  
    * [日志](GUIDES&REFERENCES/logging.md)  
    * [网络&防火墙](GUIDES&REFERENCES/network.md)  
    * [保证 Admin API 安全](GUIDES&REFERENCES/secure-admin-api.md)  
    * [插件开发](GUIDES&REFERENCES/plugin-development/)
        * [简介](GUIDES&REFERENCES/plugin-development/README.md)
        * [文件结构](GUIDES&REFERENCES/plugin-development/file-structure.md)
        * [实现自定义逻辑](GUIDES&REFERENCES/plugin-development/custom-logic.md)
        * [插件配置](GUIDES&REFERENCES/plugin-development/plugin-configuration)
        * [访问数据存储区](GUIDES&REFERENCES/plugin-development/access-the-datastore.md)
        * [存储自定义实体](GUIDES&REFERENCES/plugin-development/custom-entities.md)
        * [缓存自定义实体](GUIDES&REFERENCES/plugin-development/entities-cache.md)
        * [扩展Admin API](GUIDES&REFERENCES/plugin-development/admin-api.md)
        * [编写单元测试](GUIDES&REFERENCES/plugin-development/tests.md)
        * [安装/卸载插件](GUIDES&REFERENCES/plugin-development/distribution.md)
    * [插件开发套件(PDK)](GUIDES&REFERENCES/PDK/pdk.md)
        * [kong.client](GUIDES&REFERENCES/PDK/kong-client.md)
        * [kong.ctx](GUIDES&REFERENCES/PDK/kong-ctx.md)
        * [kong.ip](GUIDES&REFERENCES/PDK/kong-ip.md)
        * [kong.log](GUIDES&REFERENCES/PDK/kong-log.md)
        * [kong.node](GUIDES&REFERENCES/PDK/kong-node.md)
        * [kong.request](GUIDES&REFERENCES/PDK/kong-request.md)
        * [kong.response](GUIDES&REFERENCES/PDK/kong-response.md)
        * [kong.router](GUIDES&REFERENCES/PDK/kong-router.md)
        * [kong.service](GUIDES&REFERENCES/PDK/kong-service.md)
        * [kong.service.request](GUIDES&REFERENCES/PDK/kong-service-request.md)
        * [kong.service.response](GUIDES&REFERENCES/PDK/kong-service-response.md)
        * [kong.table](GUIDES&REFERENCES/PDK/kong-table.md)
* **Admin Api**
    * 无DB配置
    * [支持的 Content Types](ADMIN-API/supported-content-types.md)
    * [信息路由](ADMIN-API/information-routes.md)
    * [标签](ADMIN-API/tags.md)
    * [Service对象](ADMIN-API/service-object.md)
    * [Router对象](ADMIN-API/route-object.md)
    * [Consumer对象](ADMIN-API/consumer-object.md)
    * [插件对象](ADMIN-API/plugin-object.md)
    * [证书对象](ADMIN-API/certificate-object.md)
    * [SNI对象](ADMIN-API/sni-object.md)
    * [Upstream对象](ADMIN-API/upstream-object.md)
    * [Target对象](ADMIN-API/target-object.md)

   
# 插件文档目录

- **认证**
    * [Basic Authentication 基础认证插件](HUB/basic-auth.md)
    * [HMAC Authentication 认证插件](HUB/hmac-auth.md) 
    * [JWT 插件](HUB/jwt.md)
    * [Key Authentication 密钥认证插件](HUB/key-auth.md)
    * [LDAP Authentication 认证插件](HUB/ldap-auth.md)
    * [OAuth 2.0 Authentication 认证插件](HUB/oauth2.md)
    * [Session 插件](HUB/session.md)
- **安全**
    * [CORS 插件](HUB/cors.md)
    * [IP Restriction 插件](HUB/ip-restriction.md)
    * [Bot Detection 机器人检测插件](HUB/bot-detection.md)
- **日志**
    * [File Log 插件](HUB/file-log.md)
    * [TCP Log 插件](HUB/tcp-log.md)
    * [UDP Log 插件](HUB/udp-log.md)
    * [HTTP Log 插件](HUB/http-log.md)
- **变更**
    * [Correlation ID 关联 ID插件](HUB/correlation-id.md)
    * [Request Transformer 请求变更插件](HUB/request-transformer.md)
    * [Response Transformer 响应变更插件](HUB/response-transformer.md)
- **传输限制**
    * [ACL 插件](HUB/acl.md)
    * [Proxy Caching 代理缓存插件](HUB/proxy-cache.md)
    * [Rate Limiting 速率限制插件](HUB/rate-limiting.md)
    * [Response Rate Limiting 响应率限制插件](HUB/response-ratelimiting.md)
    * [Request Termination 请求终止插件](HUB/request-termination.md)
    * [Request Size Limiting 请求大小限制插件](HUB/request-size-limiting.md)
- **无服务**
   * [AWS Lambda 插件]
   * [Serverless Functions 插件]

- **分析与监测**
    * [Datadog 插件](HUB/datadog.md)
    * [Zipkin 插件](HUB/zipkin.md)
    * [Prometheus 插件](HUB/prometheus.md)
- **部署**
    * [Kubernetes Sidecar 注入插件](HUB/kubernetes-sidecar-injector.md)

## 其他文章

- [Kong 1.0 GA 版本正式发布(更新详情)](BLOG/kong-1.0.md)
- [Kong 1.0.0 升级指南](BLOG/kong-1.0-update.md)
- [Kong 1.3发布！支持原生gRPC代理，上游双向TLS认证，以及更多功能](BLOG/kong-1.3.md)

**译者注：**
翻译这个文档的原因是自己正好在学习这个kong，一方面也是锻炼自己的英语能力，所以采用的是人工+机翻结合的方式，如果有遇到翻译的不够通顺，或者对于翻译的语句有歧义的地方，麻烦一定点击官网英文文档 https://docs.konghq.com/ 查看，并且欢迎提 PR 提修改意见。另，由于kong的文档本身也在不断增加和完善当中，如果有遇到没有即使更新翻译的状况欢迎提issue，我会不断补充的。

**todo：**
- 目前文档中的超链接都是链接的英文原文，后续会慢慢改成中文内链。
- 会在每一页文档里面附上单独的英文原文链接，以便做对照。
- ~~会添加kong自带的插件文档。~~




