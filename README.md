![image](https://user-images.githubusercontent.com/2004103/57691648-59208500-7677-11e9-9b6f-21ee0eb5a4dd.png)

Kong是一个丛云到本地的、快速的、可伸缩的分布式微服务抽象层(也称为API网关、API中间件或某些情况下的服务网格)。作为一个开源项目，它的核心价值是高性能和可扩展性。

由于对项目的积极维护，Kong被广泛用于从初创公司到全球5000强以及政府机构的生产中。

如果有遇到翻译的不够通顺，或者对于翻译的语句有歧义的地方，麻烦点击官网英文文档 https://docs.konghq.com/ 查看，并且欢迎提 PR 提修改意见。

# 目录

* [**快速入门**](GETTING-STARTED)
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
* [**Admin Api**](ADMIN-API)
    * 无DB配置
    * [支持的 Content Types](ADMIN-API/supported-content-types.md)
    * [信息路由](ADMIN-API/information-routes.md)
    * [标签](ADMIN-API/tags.md)
    * [Service对象](ADMIN-API/service-object.md)
    * [Router对象](ADMIN-API/route-object.md)
    * [Consumer对象](ADMIN-API/consumer-object.md)
    * 插件对象
    * 认证对象
    * SNI对象
    * Upstream对象
    * Target对象

