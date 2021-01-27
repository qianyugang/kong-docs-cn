# Kong 2.3 正式发布！

原文链接：https://konghq.com/blog/kong-gateway-2-3-released/

嘿，所有的 Kong 用户，你们好! 我们很高兴地宣布我们的旗舰级开源API网关 -- Kong Gateway 2.3社区版正式发布！

2.3版本带来了几个令人兴奋的新功能，以及一些重大的安全改进。 正如我们在2.1和2.2版本中所做的那样，我们也发布了企业版2.3网关的Beta版本，同时整合了开源2.3网关的所有功能。你可以在[这里](here)了解更多关于Kong Enterprise和它的附加功能。

您可以[下载并安装](download and install it)它，并立即开始使用新功能，以下是对新功能的概览！

## Kong 支持 UTF8

从2.3版本开始，Kong 开始接受UTF-8字符的路由和服务名称。 我们知道，Kong 的使用者遍布全世界多个国家，能够在本地字符集中支持网关是很重要的。所以，现在，如果想给一个路由使用俄语，日语，中文，或任何数量的其他语言的字符集的名称，你可以使用2.3。 (是的，表情符号现在也可以在路由和服务名称中使用😊)

## 安全改进

随着 Kong Nation 的不断发展，我们认识到并非所有用户在部署 Kong 实例之前都会阅读所有关于保护 Kong 实例的文档。随着新用户数量的激增，我们希望确保Kong在默认情况下是安全的。Kong 2.3通过一系列的改进，在默认和设计上更加安全。像大多数「默认安全 」状态的变化一样，令人遗憾的是，将会给一些用户带来断裂性的变化，所以请继续阅读，了解如何处理升级以及需要注意的事项。

Kong的 [serverless functions](https://docs.konghq.com/hub/kong-inc/serverless-functions/) 允许管理员定义任意的Lua代码来执行，就像任何无服务器函数一样。因为它们之前是附着在Kong进程上的，所以我们已经警告用户应该[保护 Admin 端口](https://docs.konghq.com/latest/secure-admin-api/)的安全。如果你想更加谨慎，可以在配置中禁用插件，以进一步确保Gateway的安全。从2.3开始，我们通过添加 -> 并启用 -> 新的沙箱功能，在产品内部更加谨慎。默认情况下，无服务器功能只允许Kong PDK、OpenResty ngx API和Lua标准库进入沙箱。如果你知道自己在做什么，可以使用几个新的配置控件。

1. `untrusted_lua` 可以设置为「关闭」(不允许加载任何不受信任的/管理员提供的Lua代码)，「沙箱」(允许，但对Lua代码进行沙箱处理)，或 「开启」(允许，但不进行沙箱处理)。默认设置为 「沙箱」，这对新用户来说更加安全。假设你是一个现有的用户，并希望保持旧的行为。在这种情况下，你可以将这个参数设置为 「开启」，但要特别注意确保Gateway的管理员端口不会暴露在潜在的攻击者面前。
2. `untrusted_lua_sandbox_requires` 可以用来为 Kong 沙盒提供额外的模块。因为这是一个全局设置，所以在添加模块之前要非常小心，因为添加 "io"这样的模块可能会导致沙盒无效。
3. `untrusted_lua_sandbox_environment`可以用来为沙盒提供额外的 Lua 变量。

2.3 中的其他安全改进包括，Kong 生成的 SSL 私钥现在默认有 `600` 个文件系统权限。此外，OpenSSL已经从1.1.1h提升到1.1.1i，以修复该依赖的 [CVE-2020-1971](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-1971)。我们已经对网关进行了广泛的审查。虽然这个CVE对核心网关没有直接的可利用性，但我们正在提升版本，以提高任何可能依赖OpenSSL功能的插件的安全性。

## 新的插件功能

- HTTP Log plugin [HTTP日志插件](https://docs.konghq.com/hub/kong-inc/http-log/)已经改进，允许向HTTP请求添加头信息。这将有助于和一些监察、观测系统集成，包括Splunk、Elastic Stack（"ELK"）以及其他系统。

- Key Authentication plugin [密钥认证插件](https://docs.konghq.com/hub/kong-inc/key-auth/)有两个新的配置参数：`key_in_header` 和 `key_in_query`。这两个参数都是布尔值，告诉Kong是否接受（`true`）或拒绝（`false`）在头或查询字符串中传递的信息。两者都默认为 `true`。

- Request Size Limiting plugin [请求大小限制插件](https://docs.konghq.com/hub/kong-inc/request-size-limiting/)有一个新的配置参数`require_content_length`，它使插件在读取请求体之前确保存在一个有效的`Content-Length`头。

## 其他更新

Kong 2.3 引入了一些额外的新功能以及修复，包括：

- Kong 2.3现在会检查控制平面和任何数据平面之间的**版本兼容性**，以确保数据平面和任何插件在混合模式下与控制平面兼容。
- 证书现在有`cert_alt`和`key_alt`字段来指定替代证书和密钥对。
- **go-pluginserver的stderr和stdout**现在写入了Kong的日志，允许Golang的原生`log.Printf()`。
- `client_max_body_size` 和 `client_body_buffer_size`**现在已支持配置了**。这两个参数过去是硬编码的，设置为10m。
- **自定义插件现在也可以使用新功能**，`kong.node.get_hostname`返回Kong节点的主机名，`kong.cluster.get_id`返回了一个唯一的全局集群ID（如果在声明式配置中运行，则为nil），`kong.log.set_serialize_value()`现在可以用来设置自定义插件中日志序列化的格式。

## Kong Nation 以及 线上活动

一如既往，欢迎在我们的社区论坛[Kong Nation](https://discuss.konghq.com/)上提出任何问题。您的反馈让我们能够更好地了解关键任务的使用案例，从而不断改进 Kong。

如果你想了解我们未来开发版本的所有情况，请加入我们每月的[线上活动](https://konghq.com/online-meetups/)，在这里，Konger们会介绍最新和最棒的东西，并经常会偷偷预览即将推出的好东西。

Happy Konging!


