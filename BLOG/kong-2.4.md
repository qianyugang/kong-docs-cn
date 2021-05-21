# Kong 2.4 发布了！

原文链接：https://konghq.com/blog/kong-gateway-oss-2-4-released/

Hello Kong Nation 👋 ! 我们又回来了，带来了Kong Gateway (OSS)的另一个新版本。请继续阅读最新的发布信息。

## 插件

### 支持 JavaScript

JavaScript凭借其框架、库和开发工具的生态系统，已经巩固了其作为最常用编程语言的地位，这已经不是什么秘密。在Kong Gateway（OSS）的2.4 版本中，我们将进一步开放插件开发，为JavaScript 开发人员提供一个工具集，以设计新的、原创的和有创意的Kong Gateway插件。这个测试版的JavaScript PDK提供了在请求处理生命周期的各个环节实现自定义逻辑的能力。这些都是通过利用Node.js 运行时与Kong Gateway（OSS）一起实现的。如果你想提前了解一下开发JavaScript插件的情况，请查看[这里的文档](https://docs.konghq.com/gateway-oss/2.4.x/external-plugins)。

Kong还有一个包含各种插件的的插件中心，展示了Kong和Kong的社区开发的插件。为[Plugin Hub](https://docs.konghq.com/hub/) 做贡献，确保你的创新插件被发布到更广泛的社区中去!

### 自由的日志格式

Kong Gateway (OSS)的开发者经常面临着一个困难的任务，就是需要确定在下游系统中使用的准备或格式化日志的最合适的方式。

在2.4版本中，我们引入了一个强大的新功能，可以将Kong Gateway（OSS）的日志转化为任何需要的格式，以便为您的组织的系统捕获、索引和关联日志。开发人员现在可以通过删除字段、创建具有特定 timestamps/唯一ID的新字段，甚至将日志重新排列成特定工具所需的格式来格式化日志。通过直接在Kong Gateway（OSS）中最有用的方式转换日志，可以消除对额外数据转换工具的依赖。

在格式化日志时，也可以使用Lua代码动态地修改字段，这为按照管理员最需要的规范生成日志提供了的可能性。

该功能使用新的PDK方法[kong.log.set_serialize_value](https://docs.konghq.com/gateway-oss/2.4.x/pdk/kong.log/)，以及新的[沙盒功能](https://docs.konghq.com/gateway-oss/2.4.x/configuration/#untrusted_lua)，两者都是在Kong Gateway（OSS）2.3中引入的。支持以下插件：[file-log](https://docs.konghq.com/hub/kong-inc/file-log)、[Loggly](https://docs.konghq.com/hub/kong-inc/loggly)、[Syslog](https://docs.konghq.com/hub/kong-inc/syslog)、[tcp-log](https://docs.konghq.com/hub/kong-inc/tcp-log/)、[udp-log](https://docs.konghq.com/hub/kong-inc/udp-log)和[http-log](https://docs.konghq.com/hub/kong-inc/http-log)。

## 混合模式

### 放宽兼容性检查

在Kong Gateway（OSS）2.0中，我们引入了一种叫做[「混合模式」](https://docs.konghq.com/gateway-oss/2.3.x/hybrid-mode/)的部署方法，也被称为控制平面/数据平面（CP/DP）分离。这种模式的主要好处之一是便于Kong管理：管理员只需要与CP节点互动，就可以控制和监测整个Kong集群的状态。在这个最新的版本中，我们已经放宽了许多[版本要求](https://docs.konghq.com/gateway-oss/2.4.x/hybrid-mode/#version-compatibility)，因此管理员可以在一个经过测试的、更舒适的时间表上升级集群。

- DP现在能够连接到最多领先两个小版本的CP。
- 如果1）主要版本不匹配、2）DP比CP更新、3）CP中缺少插件，则不允许DP进行连接。设置这个防护是为了防止管理员向后兼容的破坏性更改。

## 更多其他更新

- 对于Kong Gateway (OSS) 2.4， OpenResty 的版本需要升级到1.19.3.1。并且包含的补丁集也发生了变化，包括最新发布的lua-kong-nginx-module。如果您正在从我们的发行版软件包中安装Kong，则不会受到此更改的影响。
- beta版的Protobuf插件通信协议可以代替MessagePack与非lua插件通信。开发者将会看到Go插件性能的提升。
- Zipkin插件现在支持Jaeger风格的uber-trace-id和OT header类型，以及允许在Zipkin请求跟踪中插入自定义标签。
- 作为定期维护的一部分，OpenSSL库被提升到1.1.1k，现在支持Postgres 13，最低TLS版本是v1.2

更改和相关PRs的完整列表请查看这里的[更新日志](https://github.com/Kong/kong/blob/master/CHANGELOG.md)。

## 感谢

我们❤️pull requests，我们一直在努力工作，让开发人员尽可能容易地做出贡献。特别感谢:@nvx， @pariviere @ishg， @Asafb26， @WALL-E和@jeremyjpj0916 - 我们很重视你们花时间做出的贡献。



