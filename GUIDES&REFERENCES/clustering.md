# 集群

## 简介

Kong群集允许您通过添加更多计算机来处理更多传入请求，从而水平的扩展系统。它们将共享相同的配置，因为它们都指向同一个数据库。指向**同一数据存储区**的Kong节点将成为同一Kong集群的一部分。

您需要在群集前面安装负载均衡器，以便在可用节点之间分配流量。

## Kong的集群能做什么，不能做什么

**拥有一个Kong集群并不意味着您的客户流量将在您的Kong节点之间进行负载均衡。** 您仍需要在Kong节点前面安装负载均衡器来分配流量。相反，Kong群集意味着这些节点将共享相同的配置。

出于性能原因，Kong在代理请求时避免数据库连接，并将数据库的内容缓存在内存中。缓存的实体包括服务(Services)，路由(Routes)，消费者(Consumers)，插件(Plugins)，证书(Credentials)等......由于这些值在内存中，因此其中一个节点的通过Admin API进行的任何更改都需要广播到其他节点。

本文档描述了这些缓存实体如何失效以及如何为您的用例配置Kong节点，介于性能和一致性之间。

## 单节点Kong集群

连接到数据库（Cassandra或PostgreSQL）的单个Kong节点创建一个节点的Kong群集。通过此节点的Admin API应用的任何更改都将立即生效。

考虑单个Kong节点`A`。如果我们删除以前注册的服务：
```
curl -X DELETE http://127.0.0.1:8001/services/test-service
```

然后任何对A的后续请求将立即返回404 Not Found，因为节点将其从本地缓存中清除：
```
curl -i http://127.0.0.1:8000/test-service
```

## 多节点Kong集群

在多个Kong节点的集群中，连接到同一数据库的其他节点不会立即被通知节点`A`删除了服务。虽然服务不再存在于数据库中（它被节点`A`删除），但它仍然在节点`B`的内存中。

所有节点执行定期后台作业以与可能已由其他节点触发的更改同步。可以通过以下方式配置此作业的频率：

- db_update_frequency (默认值 : 5 秒)

每个`db_update_frequency`秒，所有正在运行的Kong节点将轮询数据库以进行任何更新，并在必要时从其缓存中清除相关实体。

如果我们从节点`A`删除服务，则此更改在节点`B`中将无效，直到节点`B`下一次数据库轮询，将在几秒钟之后在`db_update_frequency`发生（尽管可能更快发生）。

最终这使得Kong保证了集群一致性。

## 什么会被缓存

所有核心实体如服务(Services)，路由(Routes)，消费者(Consumers)，插件(Plugins)，证书(Credentials)都由Kong缓存在内存中，并通过轮询机制来更新他们是否失效。

此外，Kong还缓存了数据库中没有的。这意味着如果您配置一个没有插件的服务，Kong将缓存此信息。例如：

```
# node A
curl -X POST http://127.0.0.1:8001/services \
    --data "name=example-service" \
    --data "url=http://example.com"

curl -X POST http://127.0.0.1:8001/services/example-service/routes \
    --data "paths[]=/example"
```

请注意，我们使用`/services/example-service/routes`作为快捷方式：我们可以使用`/routes`路径，但是我们需要将`service_id`作为参数传递，并使用新服务的UUID。）

对节点`A`和`B`的代理端口的请求将缓存此服务，并且事实上没有配置插件：

```
# node A
curl http://127.0.0.1:8000/example
HTTP 200 OK
...
```
```
# node B
curl http://127.0.0.2:8000/example
HTTP 200 OK
...
```

现在，假设我们通过节点A的Admin API为此服务添加一个插件：
```
# node A
curl -X POST http://127.0.0.1:8001/services/example-service/plugins \
    --data "name=example-plugin"
```

由于此请求是通过节点`A`的Admin API发出的，因此节点`A`将在本地使其缓存失效，并且在后续请求中，它将检测到此API已配置插件。

但是，节点`B`尚未运行数据库轮询，并且仍然缓存此API没有可运行的插件。直到节点`B`运行其数据库轮询操作才会这样。

结论：所有CRUD操作都会触发缓存失效。创建（`POST`，`PUT`）将使缓存的数据库未命中无效，并且更新/删除（`PATCH`，`DELETE`）将使缓存的数据库命中无效。

## 如何配置数据库缓存？

您可以在Kong配置文件中配置3个属性，其中最重要的是`db_update_frequency`，它确定了你的Kong节点在性能与一致性权衡方面的立场。Kong提供了一致性的默认值，以便让您在避免“意外”的同时试验其聚类功能。在准备生产环境设置时，应考虑调整这些值以确保遵守性能约束。

### 1.db_update_frequency (default: 5s)

此值确定Kong节点将为无效事件轮询数据库的频率。较低的值意味着轮询作业将更频繁地执行，但是您的Kong节点将会迅速跟上您应用的更改。值越高意味着您的Kong节点将花费更少的时间来运行轮询作业，并将专注于代理您的流量。

**注意**：更改在集群中传播的时间最多为`db_update_frequency`秒。

### 2.db_update_propagation (default: 0s)

如果数据库本身最终是一致的（即：Cassandra），则必须配置此值。这是为了确保更改有时间跨数据库节点传播。设置后，Kong节点从其轮询作业接收失效事件将延迟清除`db_update_propagation`秒的缓存。

如果连接到最终一致数据库的Kong节点没有延迟事件处理，它可以清除其缓存，只是再次缓存未更新的值（因为更改尚未通过数据库传播）！

您应该将此值设置为数据库集群传播更改所用时间的估计值。

注意：设置此值后，更改将通过群集传播到`db_update_frequency + db_update_propagation`秒。

### 3.db_cache_ttl (default: 0s)

Kong将缓存数据库实体（命中和未命中）的时间（以秒为单位）。如果Kong节点错过了无效事件，则此生存时间值可作为安全措施，以避免它在过时的数据上运行。到达TTL时间时，将从其缓存中清除该值，并再次缓存下一个数据库结果。

默认情况下，不会根据此TTL使数据无效（默认值为0）。这通常很好：Kong节点依赖于无效事件，这些事件在db存储级别处理（Cassandra/PosgreSQL）。如果您担心Kong节点可能因任何原因错过失效事件，则应设置TTL。否则，节点可能会在其缓存中以过时值运行一段未定义的时间，直到手动清除缓存或重新启动节点。

### 4.When using Cassandra

如果使用Cassandra作为Kong数据库，则必须将`db_update_propagation`设置为非零值。由于Cassandra最终本质上是一致的，这将确保Kong节点不会过早地使其缓存无效，只能再次获取并捕获不是最新的实体。如果您在使用Cassandra时未配置此值，Kong将向您显示警告日志。

此外，您可能希望将`cassandra_consistency`配置为`QUORUM`或`LOCAL_QUORUM`之类的值，以确保Kong节点缓存的值是数据库中的最新值。

## 通过Admin API与缓存交互

如果由于某种原因，您希望调查缓存的值，或者手动使Kong缓存的值无效（缓存命中或未命中），则可以通过Admin API `/cache` 端点执行此操作。

### 检查缓存的值

- Endpoint
    ```
    GET /cache/{cache_key}
    ```
- 返回
	如果缓存了具有该键的值：
    ```
    HTTP 200 OK
    ...
    {
        ...
    }
    ```
    否则：
    ```
    HTTP 404 Not Found
    ```

注意：为Kong缓存的每个实体检索`cache_key`目前是一个未记录的过程。管理API的未来版本将使此过程更容易。

### 清除缓存的值

- Endpoint
    ```
    DELETE /cache/{cache_key}
    ```
- 返回
	```
    HTTP 204 No Content
	...
    ```
    
注意：为Kong缓存的每个实体检索cache_key目前是一个未记录的过程。
管理API的未来版本将使此过程更容易。
    
### 清除节点的缓存

- Endpoint
    ```
    DELETE /cache
    ```
- 返回
	```
    HTTP 204 No Content
    ```
    
注意：要小心在运行良好的生产运行节点上使用此端点。
如果节点正在接收大量流量，同时清除其缓存将触发对数据库的许多请求，并可能导致[dog-pile effect](https://en.wikipedia.org/wiki/Cache_stampede)。





