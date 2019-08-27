# 微服务 API 网关 Kong 1.0 GA 版本正式发布(更新详情)
**原文地址：**[https://github.com/Kong/kong/blob/master/CHANGELOG.md#100](https://github.com/Kong/kong/blob/master/CHANGELOG.md#100) ，（如有翻译的不准确或错误之处，欢迎留言指出）

这个是一个非常重要的版本，引入了对Service Mesh和Stream Routing支持的新功能，以及新的迁移框架，它还包括插件开发工具包（Plugin Development Kit）的1.0.0版本，它包含大量其他功能和修复，如下所示。此外，Kong 1.0中包含的所有插件都更新为使用PDK 1.0版。

像往常一样，主要版本升级需要数据库迁移和Nginx配置文件的更改（如果您自定义了默认模板），在计划升级Kong集群之前，请花几分钟时间阅读[1.0升级指南](https://github.com/Kong/kong/blob/master/UPGRADE.md)，了解有关更改和迁移的更多详细信息。

作为主要版本，在Kong 0.x中标记为已弃用的所有实体和概念现已在Kong 1.0中删除，已弃用的功能将保留在[Kong 0.15](https://github.com/Kong/kong/blob/master/CHANGELOG.md#0150)中，Kong 0.x系列的最终版本，同时发布到Kong 1.0。

## 重大更新

Kong 1.0包括0.15的所有重大更改，以及删除已弃用的概念：

### 核心：

- API实体和相关概念（ 例如/apis ）将被删除（自0.13版本，2018年三月起不推荐使用）。请改用路由和服务。
- 删除旧的DAO实现以及旧的schema 验证库（apis是使用它的最后一个实体），在自定义插件中使用新的 schema format。
- 为了简化插件的转换，1.0中的 plugin loader 包含 best-effort 的模式自动翻译器，对于许多插件来说应该足够了。
- 在0.14.x版本的Upstreams中，Targets 和 Plugins 仍然使用旧的 DAO 和Admin API实现。在0.15.0和1.0.0上，所有核心实体都使用新的`kong.db` DAO，并且他们的端点已升级到新的Admin API（有关详细信息，请参阅下文）。[#3689](https://github.com/Kong/kong/pull/3689), [#3739](https://github.com/Kong/kong/pull/3739), [#3778](https://github.com/Kong/kong/pull/3778)
- 新的迁移框架( migration framework),[#3802](https://github.com/Kong/kong/pull/3802)
- `luaossl` 版本跳提升到20181207[#4067](https://github.com/Kong/kong/pull/4067)
- 新 `kong.resty.getssl` 模块 [#3681](https://github.com/Kong/kong/pull/3681)
- 时间戳现在允许毫秒精度[#3660](https://github.com/Kong/kong/pull/3660)
- `OpenSSL` 已经提升到至 1.1.1a [#4005](https://github.com/Kong/kong/pull/4005)
- `luasec` 提升到 to 0.7
- PDK函数 `kong.request.get_body`  现在将返回`nil`，`err`，`mime`，当body是有效的JSON但是既不是对象也不是数组[#4063](https://github.com/Kong/kong/pull/4063)

New Admin API引入的更改摘要:

- 分页已包含在所有“multi-record”端点中，分页控制字段与0.14.x中的不同。
- 现在通过URL路径更改（`/consumers/x/plugins`）而不是querystring字段（`/plugins?consumer_id = x`）进行过滤。
- Array values不能与逗号分隔的字符串相交。它们必须是JSON请求上的“正确”JSON值，或者在form-url-encoded或multipart请求上使用新语法。
- 错误消息已经从头开始重新设计，更加一致，准确和提供信息。
- PUT方法已经使用幂等行为重新实现，并且已添加到一些没有它的实体中。

有关New Admin API的更多详细信息请访问官方文档[https://docs.konghq.com/](https://docs.konghq.com/)

### 配置

- 删除了`custom_plugins`指令（自2018年7月的0.14.0起不推荐使用）。请改用`plugins`。

### 插件

- 删除了galileo插件（自0.13.0起不推荐使用）
- 在0.14.0中引入插件开发工具包（PDK）之前，插件作者偶尔使用的一些内部模块现已被删除：
	- `kong.tools.ip` 模块已被删除。请改用PDK中的`kong.ip`。
	- `kong.tools.public` 模块已被删除。请使用PDK中的各种等效功能。
	- `kong.tools.responses` 模块已被删除。请改用PDK中的 `kong.response.exit`。您可能还想使用`kong.log.err`来记录内部服务器错误。
	- `kong.api.crud_helpers`模块已删除（自0.13.0中引入新DAO以来已弃用）。如果需要自定义自动生成的端点，请使用`kong.api.endpoints`。
- 在插件模式中，`no_route`＆`no_service`＆`no_consumer`注释被制作为相应字段的#decection[#3739](https://github.com/Kong/kong/pull/3739);在0.15中，它们在`schema.lua` table 中作为`ad-hoc`字段提供，作为旧的`no_consumer`选项。
- 所有自带的插件模式和自定义实体都已更新为新的`kong.db`，并且他们的API已更新为New Admin API，因此得到了改进，但是仍有不同的行为，如上一节所述[#3766](https://github.com/Kong/kong/pull/3766), [#3774](https://github.com/Kong/kong/pull/3774), [#3778](https://github.com/Kong/kong/pull/3778), [#3839](https://github.com/Kong/kong/pull/3839)
- 所有插件迁移都已转换为新的迁移框架。自定义插件需要使用0.15以上的新迁移框架。

## 附加

### Service Mesh 和 Stream Routes

- 这些新功能需要修补版本的OpenResty，但Kong仍然可以在非修补的OpenResty for HTTP（S）API网关方案中正常工作
- 通过`stream_listen`配置选项支持TCP和TLSStream Routes [#4009](https://github.com/Kong/kong/pull/4009)
- 新的`origins`配置属性允许覆盖来自kong的主机 [#3679](https://github.com/Kong/kong/pull/3679)
- Kong实例现在可以创建共享内部Certificate Authority,，用于Service Mesh SSL流量  [#3906](https://github.com/Kong/kong/pull/3906), [#3861](https://github.com/Kong/kong/pull/3861),
- `transparent` 监听允许使用 `iptables` 设置`Service Mesh` [#3884]
- 插件的`run_on`字段用于控制它们在Service Mesh环境中的行为方式 [#3930](https://github.com/Kong/kong/pull/3930), [#4066](https://github.com/Kong/kong/pull/4066)	
- 这里新加一个叫做`preread`的新阶段。这是流量路由完成的地方。

### 核心

- 路由现在有一个`name`字段 [#3764]
- 在新的DAO和Admin API中实现了TTL支持。特别是，PostgreSQL获得了一种新的更高效的TTL实现 [#3603](https://github.com/Kong/kong/pull/3603), [#3638](https://github.com/Kong/kong/pull/3638)
- 通过减少数据库访问量来提高路由器重建的性能 [#3782](https://github.com/Kong/kong/pull/3782)
- Schema 改进：
	- Subschemas 子模式 [#3630](https://github.com/Kong/kong/pull/3630)
	- 新的实体验证器：`distinct`，`ne`，`is_regex`，`contains`，`gt`
	- 实体检查仅在必要时运行 [#3848](https://github.com/Kong/kong/pull/3848)
	- 条件验证器可以根据需要标记字段 [6d1707c4s](https://github.com/Kong/kong/commit/6d1707c4)
	- 记录字段的部分更新 [05adc40f](https://github.com/Kong/kong/commit/05adc40f)
	- 向schema添加具有默认值的新字段不再需要迁移 [#3756](https://github.com/Kong/kong/pull/3756)
- PDK改进:
	- 新的`kong.node`模块 [#3826](https://github.com/Kong/kong/pulls/3826)
	- 新的 `kong.response.get_path_with_query` 模块 [#3842](https://github.com/Kong/kong/pull/3842)
	- PDK getters and setters for Service, Route, Consumer & Credential [#3916](https://github.com/Kong/kong/pull/3916)
	- `kong.response.get_source`返回`error`错误 [#4006](https://github.com/Kong/kong/pull/4006)
	- `kong.response.exit`可以在`header_filter`阶段使用，但只能没有body [#4039](https://github.com/Kong/kong/pull/4039)
- Cluster-wide mutex 集群范围的互斥锁  [#3685](https://github.com/Kong/kong/pull/3685)
- 向Admin API添加多部分支持： [#3776](https://github.com/Kong/kong/pull/3776)
- 改进了插件迭代器的速度 [#3794](https://github.com/Kong/kong/pull/3794)
- 在活动运行状况检查中添加对HTTPS的支持 [#3815](https://github.com/Kong/kong/pull/3815)

### 配置

- 新字段 `dns_valid_ttl` [#3730](https://github.com/Kong/kong/pull/3730)
- 新字段 `pg_timeout` [#3808](https://github.com/Kong/kong/pull/3808)
- 设置为0时，可以禁用 `upstream_keepalive` (感谢 [@pryorda](https://github.com/pryorda)! ) [#3716](https://github.com/Kong/kong/pull/3716)
- 新的`transparent`后缀也适用于`proxy_listen`指令

### 插件

- http-log插件现在接受缓冲日志记录 [#3604](https://github.com/Kong/kong/pull/3604)
- 大多数插件逻辑都是用PDK重写的，而不是使用内部kong函数或ngx调用 [#3845](https://github.com/Kong/kong/pull/3845)
- 新的run_on选项用于控制插件在Service Mesh环境中的执行位置 [#3930](https://github.com/Kong/kong/pull/3930), [#4066](https://github.com/Kong/kong/pull/4066)
- 通常，插件对故障/意外输入更具弹性  [#4006](https://github.com/Kong/kong/pull/4006), [#3947](https://github.com/Kong/kong/pull/3947), [#4038](https://github.com/Kong/kong/pull/4038)
- AWS现在支持使用`is_proxy_integration`进行Lambda代理集成[#3427](https://github.com/Kong/kong/pull/3427/)。感谢[@aloisbarreras](https://github.com/aloisbarreras) 的补丁。

## 修复项

### 核心

- 嵌套记录由metaschema验证
- `kong.db.errors` 接收当前策略的名称
- 新DAO具有正确的CRUD事件[#3659](https://github.com/Kong/kong/pull/3659)并且仅触发更新事件一次[#4095](https://github.com/Kong/kong/pull/4095)
- SNI正确分页[#3722](https://github.com/Kong/kong/pull/3722)
- null和默认值处理得更好 [#3772](https://github.com/Kong/kong/pull/3772), [#3710](https://github.com/Kong/kong/pull/3710), [#3910](https://github.com/Kong/kong/pull/3910)
- 使用`admin API`上的`application / x-www-form-urlencoded`推断参数效果更好 [#3770](https://github.com/Kong/kong/pull/3770)
- 现在正确处理 `$ request_uri` 为 `nil` [#3842](https://github.com/Kong/kong/pull/3842)
- 可以更准确地检测Cassandra中的主键冲突 [#3865](https://github.com/Kong/kong/pull/3865)
- Datastax Enterprise 6.X不会抛出错误 , 感谢([@gchristidis](https://github.com/gchristidis)) [#3873](https://github.com/Kong/kong/pull/3873)
- Conditionals 可以在模式中正确处理结构化数据 [#3936](https://github.com/Kong/kong/pull/3936)
- 最近创建的上游为其初始目标列表返回 `[] `而不是`{} `[#4058](https://github.com/Kong/kong/pull/4058)
- `postgres`策略正确创建数组索引表达式 [#4078](https://github.com/Kong/kong/pull/4078)
- 在某些情况下，路由器不再注入额外的`/` [#3780](https://github.com/kong/kong/pull/3780)
- 在我们的模板中打开TLSv1.3以解决OpenSSL中的错误 [#4046](https://github.com/Kong/kong/pull/4046)
- 几个错别字，风格和语法修复 by [@saideepd](https://github.com/saideepd), [@gy741](https://github.com/gy741), [@arpitpandey0209](https://github.com/arpitpandey0209), [@joelvisroman](https://github.com/joealvisroman), [@vkmrishad](https://github.com/vkmrishad), [@mr-yamraj](https://github.com/mr-yamraj), [@geekysrm](https://github.com/geekysrm), [@Mehvix](https://github.com/Mehvix), [@vyaspranjal33](https://github.com/vyaspranjal33), [@iTechTR](https://github.com/iTechTR), [@shyamjalan](https://github.com/shyamjalan), and [@steffinstanly](https://github.com/@steffinstanly).

### 插件

- 记录字段在插件架构中不可为空 [#3778](https://github.com/Kong/kong/pulls/3778)
- 修复了一些问题，其中一些插件可能包含Lapis的默认HTML响应 [#4077](https://github.com/Kong/kong/pull/4077)
- cors:
	- 当 `Access-Control-Allow-Credentials` 启用的时候 set 'Vary: Origin'（感谢[@marckhouzam](https://github.com/marckhouzam)） [#3675](https://github.com/Kong/kong/pull/3765)
	- 对于预检请求，返回HTTP 200而不是204 (感谢 [@aslafy-z](https://github.com/aslafy-z)) [#4029](https://github.com/Kong/kong/pull/4029))
	- 现在可以安全地验证 flat strings 。[0eaa9acd](https://github.com/Kong/kong/commit/0eaa9acd)
- acl:
	- 编辑ACL时会重置缓存 [#3839](https://github.com/Kong/kong/pull/3839)
	- 缓存正确用于 intermediary  [#4040](https://github.com/Kong/kong/pull/4040)
- correlation-id:当access阶段被跳过的时候会报错 [#3924](https://github.com/Kong/kong/issues/3924)
- aws-lambda: HTTP / 2不允许去掉header [ #f2ee98e2](https://github.com/Kong/kong/commit/f2ee98e2)
- ratelimiting & response-ratelimiting:修复了不必要的redis调用问题：`redis:select` 可以关闭连接。(感谢 [@fffonion](https://github.com/fffonion) [#3973](https://github.com/Kong/kong/pull/3973)


















