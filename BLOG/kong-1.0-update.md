# Kong 1.0.0 升级指南

注意：以下是1.0.x的升级指南。
如果您要升级到Kong的早期版本，请阅读Kong repo中的[UPGRADE.md](https://github.com/Kong/kong/blob/master/UPGRADE.md)文件。

本指南将告知您在升级时应了解的重大更改，并指导您完成正确的步骤，以便在不同的升级方案中获得不需要停止服务的迁移。

## 升级到 1.0.0

此版本（1.0.0） 是Kong的主要版本，包括许多新功能以及重大变化。  
这个版本中引入了新的插件架构格式，Admin API 终端的更改，数据库迁移，Nginx配置更改以及已删除的配置属性。  
在此版本中，将删除 API 及其相关的Admin API 终端。  
本节将重点介绍在升级之前需要注意的重大更改，并将介绍建议的升级路径。我们建议您查阅完整的[1.0.0更新日志](https://github.com/Kong/kong/blob/master/CHANGELOG.md)，以获取更改和新功能的完整列表。

## 1.突破性修改

### 依赖

- 所需的OpenResty版本是1.13.6.2，但是对于完整的功能集，包括具有相互TLS的流路由和服务网格功能，您需要Kong的[openresty-patches](https://github.com/kong/openresty-patches)。
- 所需的最低OpenSSL版本为1.1.1。如果您手动构建，请确保使用相同的OpenSSL版本编译所有依赖项（包括LuaRocks模块）。如果您从我们的某个分发包中安装Kong，则不会受此更改的影响。

### 配置

- 删除了`custom_plugins` 指令（自0.14.0起不推荐使用）。请改用`plugin`，您不仅可以使用插件来启用自定义插件，还可以禁用自带的捆绑插件。
- `cassandra_lb_policy`的默认值从`Round Robin`更改为`Request Round Robin`。
- Kong为其流路由生成了一个新的模板文件`nginx-kong-stream.conf`，该文件包含在其顶级Nginx配置文件的`stream`块中。如果您使用自定义Nginx配置并希望使用流路由，则可以使用`kong prepare`生成此文件。
- Nginx配置文件已更改，这意味着如果使用自定义模板，则需要更新它：

```
diff --git a/kong/templates/nginx_kong.lua b/kong/templates/nginx_kong.lua
index d4e416bc..8f268ffd 100644
--- a/kong/templates/nginx_kong.lua
+++ b/kong/templates/nginx_kong.lua
@@ -66,7 +66,9 @@ upstream kong_upstream {
     balancer_by_lua_block {
         Kong.balancer()
     }
+> if upstream_keepalive > 0 then
     keepalive $;
+> end
 }

 server {
@@ -85,7 +87,7 @@ server {
 > if proxy_ssl_enabled then
     ssl_certificate $;
     ssl_certificate_key $;
-    ssl_protocols TLSv1.1 TLSv1.2;
+    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
     ssl_certificate_by_lua_block {
         Kong.ssl_certificate()
     }
@@ -200,7 +202,7 @@ server {
 > if admin_ssl_enabled then
     ssl_certificate $;
     ssl_certificate_key $;
-    ssl_protocols TLSv1.1 TLSv1.2;
+    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;

     ssl_session_cache shared:SSL:10m;
     ssl_session_timeout 10m;
```


### 核心

- 将删除API实体和相关概念，例如`/apis`终端。自0.13.0起，这些已被弃用。而是使用`Routes`配置终端，`Services`以配置上游服务。
- 删除旧的DAO实现（kong.dao），其中包括旧的模式验证库。这对插件开发人员有影响，如下所示。
	- 转换为新DAO实现的最后剩余实体是Plugins，Upstreams和Targets。这会对下面列出的Admin API产生影响。

### 插件

kong 1.0.0标志着插件开发套件（PDK）1.0.0版的推出。与版本0.14相比，PDK没有进行重大更改，但现在可以删除一些可能由自定义插件使用的较旧的非PDK功能。

- 插件现在使用新DAO实现引入的新模式格式，用于插件模式（在`schema.lua`中）和自定义DAO实体（`daos.lua`）。为了简化插件的转换，1.0中的插件加载器包含了一个为`schema.lua`的自动转换器，对于许多插件来说应该足够了（在1.0.0rc1中，我们的自带捆绑插件使用了自动转换器;它们们现在使用的是新格式）。
	- 如果您在schema.lua中使用旧格式的插件无法加载，请检查自动转换器生成的消息的错误日志。如果无法自动转换字段，则可以通过向格式的字段表转换添加`new_type`条目来逐步转换模式文件。例如，请参阅[1.0.0rc1中的key-auth架构](https://github.com/Kong/kong/blob/1.0.0rc1/kong/plugins/key-auth/schema.lua#L39-L54)。`new_type`注释被Kong 0.x忽略。
	- 如果您的自定义插件使用自定义DAO对象（如果它包含`daos.lua`文件），则需要将其转换为新格式。代码也需要相应调整，用`kong.db`代替`singletons.dao`或`kong.dao`的使用（注意，这个模块暴露了与旧DAO实现不同的API）。
- 现已删除了在0.14.0中由PDK替换其功能的ome Kong模块：
	- `kong.tools.ip`：改为用PDK中的`kong.ip`。
	- `kong.tools.public`：由PDK的各种功能取代。
	- `kong.tools.responses`：由PDK中的`kong.response.exit`取代。您可能还使用`kong.log.err`来记录内部服务器错误。
- `kong.api.crud_helpers`模块已被删除。如果需要自定义自动生成的终端，请使用`kong.api.endpoints`。

### Admin API

- 删除API实体后，将删除`/apis`终端；因此，接受`api_id`的其他终端不再这样做。请改用Routes和Services。
- 现在，所有实体终端都使用新的Admin API实现。这意味着他们的请求和响应现在使用相同的语法，该语法已在终端（例如`/routes`和`/services`）中使用。
	- 所有端点现在使用相同的语法将其他实体作为`/routes`引用（例如，`“service”：{“id”：“...”}`而不是`“service_id”：“...”`），包括请求和响应。
		- 此更改会影响`/plugins`以及特定于插件的终端。
	- 数组类型的值不再指定为以逗号分隔的列表。必须将其指定为JSON数组或使用新Admin API实现的url-formencoded数组表示法支持的各种格式（`a[1]=x&a[2]=y, a[]=x&a[]=y, a=x&a=y`）
		- 此更改会影响`/upstreams`终端的属性。
	- 更新终端的错误响应使用新的标准化格式。
	- 由于被移动到新的Admin API实现，支持PUT的所有终端都使用适当的语义。
	- 有关更多详细信息，请参阅[Admin API参考](https://docs.konghq.com/1.0.x/admin-api)。

## 2.弃用通知

此版本中没有弃用通知。

## 3.建议的升级路径

### 初步检查

如果您的群集运行的版本低于0.14，则需要先升级到0.14.1。不支持从0.14之前的群集直接升级到Kong 1.0。如果您仍然使用已弃用的API实体来配置终端和上游服务（通过`/apis`），而不是使用路由Routes（通过'/routes'）和服务Service（通过`/services`），现在是时候这样做了。如果您在数据存储区中使用`/apis`配置了任何实体，则kong 1.0将拒绝运行迁移。创建等效的路由和服务并删除您的API。请注意，Kong不会自动执行此操作，因为为每个API创建一对路由和服务这样天真的操作将错过路由和服务带来的改进点;路由和服务的理想映射取决于您的微服务架构。

如果您使用除与Kong自带捆绑的插件以外的其他插件，请确保在升级之前它们与Kong 1.0兼容。有关插件兼容性的信息，请参阅上面有关插件的部分。

### 从0.14开始逐步迁移

Kong 1.0引入了一个新的，改进的迁移框架。它支持无停机，蓝/绿迁移模型，可从0.14.x升级。完整迁移现在分为两个步骤，这两个步骤通过命令`kong migrations up`和`kong migrations finish`完成。

对于从0.14群集到1.0群集的无停机时间迁移，我们建议采用以下一系列步骤：

- 第一步：下载1.0，并将其配置为指向与0.14群集相同的数据存储。执行`kong migrations up`
- 第二步：现在，0.14和1.0节点都可以在同一数据存储上同时运行。开始配置1.0节点，但是先不要使用其Admin API。更好的操作是向0.14节点发出Admin API请求。
- 第三步：逐渐将流量从0.14节点转移到1.0集群中。监控您的流量，确保一切顺利。
- 第四步：当您的流量完全迁移到1.0群集时，停用0.14节点。
- 第五步：从1.0集群中，运行：`kong migrations finish`。从现在开始，将无法再启动指向同一数据存储区的0.14个节点。仅在您确信迁移成功时才运行此命令。从现在开始，您可以安全地向1.0节点发出Admin API请求。

在任何一步，您都可以运行` kong migrations list`来获取迁移状态的报告。它将列出是否缺少迁移，如果有待处理的迁移（已经在kong迁移步骤中启动，之后需要在kong迁移完成步骤中完成）或者是否有新的迁移可用。流程的状态代码也会相应更改：

- `0` - 迁移是最新的
- `1` - 检查迁移状态失败（例如数据库已关闭）
- `3` - 数据库需要引导：你应该运行`kong migrations bootstrap`来安装在新的数据存储上。
- `4` - 有待处理的迁移：一旦您的旧群集被解除，您应该运行kong迁移完成（上面的步骤5）。
- `5` - 有新的迁移：您应该开始迁移序列（从上面的步骤1开始）。

### 从1.0 Release Candidates迁移

该过程与上面列出的0.14升级过程相同，但在第1步中，您应该运行`kong migrations --force。`

### 补丁版本的升级路径

同一次要版本的Kong的当前或未来补丁版本之间的升级没有迁移（例如1.0.0到1.0.1,1.0.1到1.0.4等）。

假设Kong已在您的系统上运行，请从任何可用的[安装方法](https://getkong.org/install/)获取最新版本并继续安装它，覆盖以前的安装。


如果您计划对配置进行修改，那么这是一个好时机。然后，运行迁移以升级数据库模式

```
$ kong migrations up [-c configuration_file]
```

如果命令成功，并且没有运行迁移（没有输出），那么您只需要[重新加载Kong](https://getkong.org/docs/latest/cli/#reload)：

```
$ kong reload [-c configuration_file]
```

提醒：`kong reload`利用ngnix的`reload`来无缝启动一个新的worker。在那些旧worker被终止之前接管旧的worker。通过这种方式，Kong将通过新配置提供新请求，而不会丢弃现有的服务连接。

### 在新数据存储上安装1.0

为了在新的数据存储上安装，Kong 1.0引入了`kong migrations bootstrap`命令。可以运行以下命令从新数据存储区准备新的1.0集群：

```
$ kong migrations bootstrap [-c config]
$ kong start [-c config]
```






