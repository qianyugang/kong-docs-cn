# Kong 2.6 正式发布啦！

原文链接：https://konghq.com/blog/kong-gateway-oss-2-6-released/

Hello Kong的开发者和用户们！在开源社区和Kong公司核心工程师的共同努力下，今天我们非常自豪地发布了Kong Gateway (OSS) 2.6 版本。请继续阅读更多发布信息。

## 引擎优化

就在今年，我们刚刚庆祝了 Kong Gateway (OSS) 成立六周年，Kong 为全世界各地的网关在关键负载上进行组织和编排。Kong Gateway成为世界上最受欢迎的API网关的主要原因之一是它无与伦比的性能，包括它的轻量级占用空间、它处理每秒数量级高的请求和比前一代网关更低的延迟的能力。为了确保我们的用户和商业客户所期望的高性能标准得到充分实现，2.6版本包括:对我们的性能基准测试系统的增强，对底层负载平衡器功能的重大重构，以及对Gateway性能本身的一些改进——下面重点介绍:

- 减少不必要的`ngx.var`读取。#7840
- 加载更多索引变量。#7849
- 在平衡器中优化了表的创建。#7852
- 减少 `ngx.update_time` 的调用。#7853
- 使用只读副本读取PostgreSQL元模式。#7454
- URL转义检测不需要和已经存在的情况。#7742
- 通过索引加速变量加载。#7818
- 在平衡器中删除了不必要的get_phase调用#7854

性能改进之后的初步测试结果看起来效果很显著🎉。当使用这个性能基准测试组合2.6的多个测试运行时，与之前的2.5版本相比，网关显示平均每秒请求(RPS)增加了12%，平均延迟从2ms减少到1.25ms。

![](https://2tjosk2rxzc21medji3nfn1g-wpengine.netdna-ssl.com/wp-content/uploads/2021/09/Screen-Shot-2021-09-27-at-9.48.57-PM.png.webp)




## 插件开发

- AWS-Lambda:本插件现在将尝试通过使用`AWS_REGION`和`AWS_DEFAULT_REGION`环境变量来检测AWS区域(当插件配置中没有指定时)。这允许在每个Kong节点的基础上指定一个“区域”，因此增加了在Kong所在的相同区域调用Lamda的能力。#7765。参考“AWS区域作为环境变量”一节
- Datadog:host和port配置选项可以通过环境变量`KONG_DATADOG_AGENT_HOST`和`KONG_DATADOG_AGENT_PORT`进行配置。这允许开发人员在每个Kong节点上设置不同的目的地，使多DC配置更容易，并且在Kubernetes中允许将Datadog代理作为守护进程集运行。# 7463。参考“每个Kong节点设置主机和端口”章节
- Prometheus:添加了一个新的度量`data_plane_cluster_cert_expiry_timestamp`以公开数据平面的cluster_cert过期时间戳，以改进混合模式下的监控。参考“1.4.x新增功能”
- Request Termination:一个新的触发器配置选项，这使得插件只激活任何header或query参数名称类似于触发器的请求。这是一个很好的调试辅助工具，不会影响正在处理的实际流量。另外还有一个新的`request-echo`配置选项。如果设置了，插件将返回传入请求的副本。当Kong在一个或多个其他代理或LB的后面，可以简化故障排除流程，特别是当与新的“触发”选项结合的时候。#6744。请参考“参数”表中的描述。
- GRPC-Gateway:类型为`.google.protobuf`的字段在gRPC侧的时间戳现在在REST端上被转换为ISO8601字符串。#7538和URI参数，如`…?foo.bar=x&foo. bar。Baz =y`现在被解释为结构化字段，等价于`{"foo": {"bar": "x"， " Baz ": "y"}}`。更多细节见“用法”的底部

完整的修改列表和相关的PRs请查看[CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md#260)。



## 感谢

社区集体受益于个人贡献者的专业知识、关心和关注。怀着感激之情，特别感谢感谢2.6版本的贡献者:@rallyben，@git-torrent， @EpicEric，@jiachinzhao，@flrgh，@agile6v，@utix。



